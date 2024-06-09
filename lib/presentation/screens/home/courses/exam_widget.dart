import 'package:cenec_app/presentation/screens/home/courses/basic_task.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../resources/classes/models.dart';

class ExamWidget extends StatefulWidget {
  final String filter;
  final String sortOrder;

  const ExamWidget({super.key, required this.filter, required this.sortOrder});

  @override
  ExamWidgetState createState() => ExamWidgetState();
}

class ExamWidgetState extends State<ExamWidget> {
  bool _expanded = false;
  late Future<List<Task>> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = _loadExamTasks();
  }

  Future<List<Task>> _loadExamTasks() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return []; // Retorna una lista vacía si el usuario no está autenticado
    }

    var subjectQuery = await FirebaseFirestore.instance
        .collection('subjects')
        .where('subscribers', arrayContains: userId)
        .get();
    List<Task> allExams = [];
    for (var subject in subjectQuery.docs) {
      var tasksSnapshot = await subject.reference.collection('tasks').get();
      for (var doc in tasksSnapshot.docs) {
        var task = Task.fromFirestore(doc.data())..uid = doc.id;
        String? taskStatus = await getTaskStatus(task.uid, subject.id);
          task.subjectUid = subject.id;
        if (task.isExam) {
          if (widget.filter == 'all' || 
          (widget.filter == 'completeds' && taskStatus == 'completed') ||
          (widget.filter == 'pendings' && taskStatus == 'pending') ||
          (widget.filter == 'unsubmitteds' && taskStatus == 'unsubmitted')) {
            allExams.add(task);
          }
        }
      }
    }
    return allExams;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: _taskFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          // No se muestra nada si no hay tareas
          return Container();
        } else {
          List<Task> exams = snapshot.data!;
          return Card(
            color: const Color.fromARGB(255, 65, 105, 225),
            child: ExpansionTile(
              title: Text("Exámenes",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white)),
              subtitle: Text(
                  'Toque para ${_expanded ? 'ocultar' : 'ver'} tus exámenes',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white)),
              onExpansionChanged: (value) => _toggleExpanded(),
              children: [
                Container(
                  color: const Color.fromARGB(255, 0, 71, 172),
                  child: Column(
                    children: exams.map((exam) {
                      return ListTile(
                        onTap: () {
                          navigateTo(context, TaskDetailPage(task: exam));
                        },
                        title: Text(
                          exam.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        subtitle: FutureBuilder<Widget>(
                          future: getTaskStatusWidget(exam, exam.subjectUid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Cargando...');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return snapshot.data ??
                                  const Text("Estado Desconocido");
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String> getTaskStatus(String taskId, examId) async {
    var userTaskDocRef = FirebaseFirestore.instance
        .collection('subjects')
        .doc(examId)
        .collection("tasks")
        .doc(taskId)
        .collection("userData")
        .doc(FirebaseAuth.instance.currentUser?.uid);
    var userTaskDoc = await userTaskDocRef.get();

    if (userTaskDoc.exists) {
      var userData = userTaskDoc.data();
      if (userData != null) {
        var state = userData['status'];
        if (state == 'completed') {
          return 'completed';
        } else if (state == 'pending') {
          return 'pending';
        } else if (state == 'unsubmitted') {
          return 'unsubmitted';
        }
      }
    }
    return 'unknown';
  }

  Future<Widget> getTaskStatusWidget(Task? task, String subjectUid) async {
    if (task == null) {
      return const Text('ID de tarea nulo',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    }
    try {
      var userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return const Text('Usuario no autenticado',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
      }

      var userTaskDocRef = FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectUid)
          .collection("tasks")
          .doc(task.uid)
          .collection("userData")
          .doc(userId);
      var userTaskDoc = await userTaskDocRef.get();

      if (userTaskDoc.exists) {
        var userData = userTaskDoc.data();
        if (userData != null) {
          var state = userData['status'];
          if (state == 'completed') {
            return const Text("Completada",
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold));
          } else if (state == 'pending') {
            var dueDate = task.dueDate ?? DateTime.now();
            return Text("Pendiente - ${getTimeRemaining(dueDate)}",
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold));
          } else if (state == 'unsubmitted') {
            return const Text("Sin entregar",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
          }
        }
        return const Text("Desconocido",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
      } else {
        return const Text("Sin Entregar",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener el estado de la tarea: $e");
      }
      return const Text("Error",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
    }
  }

  String getTimeRemaining(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = date.difference(now);

    if (difference.isNegative) {
      return "El tiempo ya ha pasado";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} días";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} horas";
    } else {
      return "${difference.inMinutes} minutos";
    }
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }
}
