import 'package:cenec_app/presentation/screens/home/courses/basic_task.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../resources/classes/models.dart';

class SubjectWidget extends StatefulWidget {
  final Subject subject;
  final String filter;
  final String sortOrder;

  const SubjectWidget(
      {super.key,
      required this.subject,
      required this.filter,
      required this.sortOrder});

  @override
  SubjectWidgetState createState() => SubjectWidgetState();
}

class SubjectWidgetState extends State<SubjectWidget> {
  bool _expanded = false;
  late Future<List<Task>> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = _loadTasks();
  }

  Future<List<Task>> _loadTasks() async {
    var tasksSnapshot =
        await widget.subject.reference.collection('tasks').get();
    List<Task> tasks = tasksSnapshot.docs.map((doc) {
      var data = doc.data();
      Task task = Task.fromFirestore(data)..uid = doc.id;
      return task;
    }).toList();

    // Filtrar las tareas según el filtro seleccionado
    if (widget.filter == 'completeds') {
      tasks = await _filterTasks(tasks, 'completed');
    } else if (widget.filter == 'pendings') {
      tasks = await _filterTasks(tasks, 'pending');
    } else if (widget.filter == 'unsubmitteds') {
      tasks = await _filterTasks(tasks, 'unsubmitted');
    }

    // Ordenar las tareas según el criterio seleccionado
    if (widget.sortOrder == 'creation_date') {
      tasks.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));
    } else if (widget.sortOrder == 'due_date') {
      tasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    }

    return tasks;
  }

  Future<List<Task>> _filterTasks(List<Task> tasks, String status) async {
    List<Task> filteredTasks = [];
    for (var task in tasks) {
      if (await getTaskStatus(task.uid) == status) {
        filteredTasks.add(task);
      }
    }
    return filteredTasks;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
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
          List<Task> tasks = snapshot.data!;
          return Card(
            color: widget.subject.pColor,
            child: ExpansionTile(
              title: Text(widget.subject.name,
                  style: Theme.of(context).textTheme.headlineMedium),
              subtitle: Text(
                  'Toque para ${_expanded ? 'ocultar' : 'ver'} tareas',
                  style: Theme.of(context).textTheme.bodyLarge),
              onExpansionChanged: (value) => _toggleExpanded(),
              children: [
                Container(
                  color: widget.subject.sColor,
                  child: Column(
                    children: tasks.map((task) {
                      return ListTile(
                        onTap: () {
                          navigateTo(context, TaskDetailPage(task: task));
                        },
                        title: Text(
                          task.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        subtitle: FutureBuilder<Widget>(
                          future: getTaskStatusWidget(task),
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

  Future<Widget> getTaskStatusWidget(Task? task) async {
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
          .doc(widget.subject.uid)
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

  Future<String> getTaskStatus(String taskId) async {
    var userTaskDocRef = FirebaseFirestore.instance
        .collection('subjects')
        .doc(widget.subject.uid)
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
}
