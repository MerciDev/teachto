import 'package:cenec_app/presentation/screens/home/courses/exam_widget.dart';
import 'package:cenec_app/resources/functions/notifications.dart';
import 'package:cenec_app/services/local_storage/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../resources/classes/models.dart';
import 'course_widget.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> {
  String _selectedFilter = 'all';
  String _selectedOrder = 'creation_date';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    if (LocalStorage.prefs.getBool('unsubmittedNotify') == true) {
      _checkForUnsubmittedTasks();
    }
    if (LocalStorage.prefs.getBool('pendingNotify') == true) {
      _checkForPendingTasks();
    }
  }

  Future<void> _checkForPendingTasks() async {
    var subjectSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();
    bool hasPendingTasks = false;

    for (var doc in subjectSnapshot.docs) {
      var taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(doc.id)
          .collection('tasks')
          .get();
      for (var taskDoc in taskSnapshot.docs) {
        var userTaskDocRef = FirebaseFirestore.instance
            .collection('subjects')
            .doc(doc.id)
            .collection('tasks')
            .doc(taskDoc.id)
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser?.uid);
        var userTaskDoc = await userTaskDocRef.get();
        if (userTaskDoc.exists && userTaskDoc.data()?['status'] == 'pending') {
          hasPendingTasks = true;
          break;
        }
      }
    }

    if (hasPendingTasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.showNotification(
          context,
          Icons.hourglass_empty,
          Colors.amber,
          'Tienes tareas pendientes',
          () {
            if (mounted) {
              setState(() {
                _selectedFilter = 'pendings';
              });
            }
          },
        );
      });
    }
  }

  Future<void> _checkForUnsubmittedTasks() async {
    var subjectSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();
    bool hasPendingTasks = false;

    for (var doc in subjectSnapshot.docs) {
      var taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(doc.id)
          .collection('tasks')
          .get();
      for (var taskDoc in taskSnapshot.docs) {
        var userTaskDocRef = FirebaseFirestore.instance
            .collection('subjects')
            .doc(doc.id)
            .collection('tasks')
            .doc(taskDoc.id)
            .collection('userData')
            .doc(FirebaseAuth.instance.currentUser?.uid);
        var userTaskDoc = await userTaskDocRef.get();
        if (userTaskDoc.exists &&
            userTaskDoc.data()?['status'] == 'unsubmitted') {
          hasPendingTasks = true;
          break;
        }
      }
    }

    if (hasPendingTasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNotification.showNotification(
          context,
          Icons.close,
          Colors.red,
          'Tienes tareas sin entregar',
          () {
            setState(() {
              _selectedFilter = 'unsubmitted';
            });
          },
        );
      });
    }
  }

  String getFilterText() {
    switch (_selectedFilter) {
      case 'completeds':
        return 'Tareas Completadas';
      case 'pendings':
        return 'Tareas Pendientes';
      case 'unsubmitteds':
        return 'Tareas Sin Entregar';
      case 'all':
      default:
        return 'Todas las Tareas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Mis Cursos',
            style: Theme.of(context).textTheme.displayMedium),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.7,
                child: SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).hoverColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)))),
                  selectedIcon: const Icon(Icons.arrow_forward_ios_rounded),
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'all',
                      label: Icon(Icons.menu),
                    ),
                    ButtonSegment<String>(
                      value: 'completeds',
                      label: Icon(Icons.check_rounded),
                    ),
                    ButtonSegment<String>(
                      value: 'pendings',
                      label: Icon(Icons.hourglass_empty),
                    ),
                    ButtonSegment<String>(
                      value: 'unsubmitteds',
                      label: Icon(Icons.clear_rounded),
                    ),
                  ],
                  selected: <String>{_selectedFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedFilter = newSelection.first;
                    });
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.3,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).hoverColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)))),
                  selectedIcon: const Icon(Icons.arrow_forward_ios_rounded),
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'creation_date',
                      label: Icon(Icons.date_range),
                    ),
                    ButtonSegment<String>(
                      value: 'due_date',
                      label: Icon(Icons.history),
                    ),
                  ],
                  selected: <String>{_selectedOrder},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedOrder = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getFilterText(),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              )
            ],
          ),
          ExamWidget(
            key: ValueKey('$_selectedFilter-$_selectedOrder'),
            filter: _selectedFilter,
            sortOrder: _selectedOrder,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('subjects').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay cursos disponibles'));
                }

                List<Subject> subjects = snapshot.data!.docs
                    .map((doc) => Subject.fromFirestore(doc))
                    .toList();
                subjects.retainWhere((subject) => subject.subscribers
                    .contains(FirebaseAuth.instance.currentUser?.uid));
                return ListView(
                  children: subjects
                      .map((subject) => SubjectWidget(
                            key: ValueKey(subject.uid),
                            subject: subject,
                            filter: _selectedFilter,
                            sortOrder: _selectedOrder,
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {});
            if (LocalStorage.prefs.getBool('unsubmittedNotify') == true) {
              _checkForUnsubmittedTasks();
            }
            if (LocalStorage.prefs.getBool('pendingNotify') == true) {
              _checkForPendingTasks();
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
