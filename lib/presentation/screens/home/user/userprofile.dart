import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/resources/classes/models.dart';
import 'package:cenec_app/presentation/screens/home/user/notifications.dart';
import 'package:cenec_app/presentation/screens/home/user/settings.dart';
import 'package:cenec_app/resources/classes/courses.dart';
import 'package:cenec_app/resources/widgets/basic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TaskEvent {
  final DateTime date;
  final Color color;
  final String task;

  TaskEvent(this.date, this.color, this.task);
}

class UserProfilePage extends StatefulWidget {
  final List<Course> courses;

  const UserProfilePage({super.key, required this.courses});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  List<DateTime> completedTasks = [];
  List<DateTime> pendingTasks = [];
  List<DateTime> unsubmittedTasks = [];
  bool isLoading = true;

  List<String> completedIds = [];
  List<String> pendingIds = [];
  List<String> unsubmittedIds = [];

  @override
  void initState() {
    super.initState();
    loadTaskData();
  }

  Future<void> loadTaskData() async {
    List<DateTime> completedTasksL = await filterTaskStatusList("completed");
    List<DateTime> pendingTasksL = await filterTaskStatusList("pending");
    List<DateTime> unsubmittedTasksL =
        await filterTaskStatusList("unsubmitted");

    List<String> completedIds = await getList("completedTasks");
    List<String> pendingIds = await getList("pendingTasks");
    List<String> unsubmittedIds = await getList("unsubmittedTasks");

    setState(() {
      completedTasks = completedTasksL;
      pendingTasks = pendingTasksL;
      unsubmittedTasks = unsubmittedTasksL;
      isLoading = false;
      completedIds = completedIds;
      pendingIds = pendingIds;
      unsubmittedIds = unsubmittedIds;
    });
  }

  Future<String> getUserType() async {
  var userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (userDoc.exists && userDoc.data()!.containsKey('type')) {
    return userDoc.data()!['type'] as String;
  }
  return 'student';
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Usuario',
                style: Theme.of(context).textTheme.displayMedium)),
        body: SafeArea(
          child: Column(
            children: [
              _buildUserSection(context),
              _buildAdditionalInfo(),
              _buildCalendar(context), // Ahora pasa solo 'courses'
            ],
          ),
        ),
      );
    }
  }

  Widget _buildUserSection(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: screenHeight * 0.2,
      decoration: BoxDecoration(
        color: Colors.blue[300],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _userInfoRow(context),
          _buttonBar(context),
        ],
      ),
    );
  }

  Widget _userInfoRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/examples/cafe.jpg'),
          ),
          const SizedBox(width: 20),
          FutureBuilder(
            future: _getUserEmail(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                return _userDetails(context, snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _userDetails(BuildContext context, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(userEmail, style: Theme.of(context).textTheme.displaySmall),
        Text(FirebaseAuth.instance.currentUser!.uid,
            style: Theme.of(context).textTheme.bodySmall),
        IconButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: FirebaseAuth.instance.currentUser!.uid));
            },
            icon: const Icon(Icons.copy))
      ],
    );
  }

  Widget _buttonBar(BuildContext context) {
  return FutureBuilder<String>(
    future: getUserType(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
        // Muestra el botón solo si el usuario es un profesor
        if (snapshot.data == 'teacher' || snapshot.data == 'admin') {
          return const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NavigationButton(
                    Icons.notifications, "Notificaciones", NotificationsPage()),
                NavigationButton(Icons.edit, "Editar", BaseEditorPage()),
                NavigationButton(Icons.settings, "Ajustes", SettingsPage()),
              ],
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NavigationButton(
                    Icons.notifications, "Notificaciones", NotificationsPage()),
                NavigationButton(Icons.settings, "Ajustes", SettingsPage()),
              ],
            ),
          );
        }
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}


  Widget _buildAdditionalInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: const Text(
        "Más información del usuario aquí",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    Map<DateTime, List<Task>> events = {};

    for (var course in widget.courses) {
      for (var task in course.tasks) {
        DateTime? dueDate = task.dueDate;
        if (dueDate != null) {
          if (events.containsKey(dueDate)) {
            events[dueDate]!.add(task);
          } else {
            events[dueDate] = [task];
          }
        }
      }
    }

    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(DateTime.now().year - 1),
          lastDay: DateTime(DateTime.now().year + 1),
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            titleTextStyle: Theme.of(context).textTheme.headlineMedium!,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              DateTime normalizedDate =
                  DateTime(date.year, date.month, date.day);

              Color markerColor = Colors.black;
              if (completedTasks.contains(normalizedDate)) {
                markerColor = Colors.green;
              }
              if (pendingTasks.contains(normalizedDate)) {
                markerColor = Colors.amber;
              }
              if (unsubmittedTasks.contains(normalizedDate)) {
                markerColor = Colors.red;
              }

              if (completedTasks.contains(normalizedDate) ||
                  pendingTasks.contains(normalizedDate) ||
                  unsubmittedTasks.contains(normalizedDate)) {
                return Container(
                  margin: const EdgeInsets.all(5.0),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                  width: 7,
                  height: 7,
                );
              }

              return null;
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      "Tareas para ${DateFormat('dd/MM/yyyy').format(selectedDay)}"),
                  content: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(
                      children: [
                        Text(
                          "Completadas",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.green),
                        ),
                        FutureBuilder<Task>(
                          future: getTaskByDate(selectedDay),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData &&
                                completedTasks
                                    .contains(snapshot.data?.dueDate)) {
                              Task task = snapshot.data!;
                              return Text(task.name);
                            } else {
                              return const Text("No hay tareas.");
                            }
                          },
                        ),
                        Text(
                          "Pendientes",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.amber),
                        ),
                        FutureBuilder<Task>(
                          future: getTaskByDate(selectedDay),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData &&
                                pendingTasks.contains(snapshot.data?.dueDate)) {
                              Task task = snapshot.data!;
                              return Text(task.name);
                            } else {
                              return const Text("No hay tareas.");
                            }
                          },
                        ),
                        Text(
                          "Sin Entregar",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.red),
                        ),
                        FutureBuilder<Task>(
                          future: getTaskByDate(selectedDay),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData &&
                                completedIds.contains(snapshot.data?.uid)) {
                              Task task = snapshot.data!;
                              return Text(task.name);
                            } else {
                              return const Text("No hay tareas.");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Future<String> _getUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.email ?? "Usuario";
}

Future<List<DateTime>> filterTaskStatusList(String filter) async {
  List<DateTime> filteredDateList = [];
  try {
    QuerySnapshot subjectsSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();

    final List<QueryDocumentSnapshot> subjectDocuments = subjectsSnapshot.docs;

    for (var subjectDocument in subjectDocuments) {
      List<dynamic> subscribers = subjectDocument['subscribers'];
      if (!subscribers.contains(FirebaseAuth.instance.currentUser?.uid)) {
        continue;
      }

      QuerySnapshot tasksSnapshot =
          await subjectDocument.reference.collection('tasks').get();

      final List<QueryDocumentSnapshot> taskDocuments = tasksSnapshot.docs;

      for (var taskDocument in taskDocuments) {
        QuerySnapshot userDataSnapshot =
            await taskDocument.reference.collection('userData').get();
        Task task = await getTask(taskDocument.id);

        final List<DocumentSnapshot> userDataDocuments = userDataSnapshot.docs;

        for (var userDataDocument in userDataDocuments) {
          String userId = userDataDocument.id;
          // Comparar el ID del documento con el ID del usuario
          if (userId == FirebaseAuth.instance.currentUser?.uid) {
            Map<String, dynamic> userData =
                userDataDocument.data() as Map<String, dynamic>;
            String status = userData['status'] as String;
            if (status == filter) {
              filteredDateList.add(DateTime(
                  task.dueDate!.year, task.dueDate!.month, task.dueDate!.day));
            }
          } else {
            if (kDebugMode) {
              print('El ID del documento no coincide con el ID del usuario');
            }
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al recuperar los temas y tareas: $e');
    }
  }

  return filteredDateList;
}

Future<List<String>> getAllTaskIds() async {
  List<String> tasksIdList = [];
  try {
    QuerySnapshot subjectSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();

    for (var subjectDoc in subjectSnapshot.docs) {
      Map<String, dynamic> data = subjectDoc.data() as Map<String, dynamic>;

      List<String> subscribers =
          (data.containsKey('subscribers') && data['subscribers'] != null)
              ? List<String>.from(data['subscribers'])
              : [];

      QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectDoc.id)
          .collection('tasks')
          .get();
      if (subscribers.contains(FirebaseAuth.instance.currentUser?.uid)) {
        for (var taskDoc in taskSnapshot.docs) {
          if (!tasksIdList.contains(taskDoc.id)) {
            tasksIdList.add(taskDoc.id);
          }
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching tasks: $e");
    }
  }
  return tasksIdList;
}

Future<String> getTaskStatus(String taskId) async {
  var userDocRef = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("tasks")
      .doc(taskId);
  var userDoc = await userDocRef.get();
  var userData = userDoc.data();
  return userData?['status'] ?? "Sin estado";
}

Future<Task> getTask(String uid) async {
  try {
    QuerySnapshot subjectSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();

    for (var subjectDoc in subjectSnapshot.docs) {
      QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectDoc.id)
          .collection('tasks')
          .get();

      for (var taskDoc in taskSnapshot.docs) {
        Task task = Task.fromFirestore(taskDoc.data() as Map<String, dynamic>);
        if (taskDoc.id == uid) {
          return task;
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching tasks: $e");
    }
  }
  return Task();
}

Future<Task> getTaskByDate(DateTime date) async {
  try {
    QuerySnapshot subjectSnapshot =
        await FirebaseFirestore.instance.collection('subjects').get();

    for (var subjectDoc in subjectSnapshot.docs) {
      QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectDoc.id)
          .collection('tasks')
          .get();

      for (var taskDoc in taskSnapshot.docs) {
        Task task = Task.fromSnapshot(taskDoc);
        if (DateTime(
                task.dueDate!.year, task.dueDate!.month, task.dueDate!.day) ==
            DateTime(date.year, date.month, date.day)) {
          return task;
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching tasks: $e");
    }
  }
  return Task(uid: "", name: "No hay tareas.");
}

Future<List<String>> getList(String restriction) async {
  List<String> filteredList = [];
  List<String> taskIdList = await getAllTaskIds();
  var userDocRef = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid);
  var userDoc = await userDocRef.get();
  var userData = userDoc.data();
  var filterList = List<String>.from(userData?[restriction] ?? []);
  for (var taskId in taskIdList) {
    if (!filterList.contains(taskId)) {
      filteredList.add(taskId);
    }
  }
  return filteredList;
}
