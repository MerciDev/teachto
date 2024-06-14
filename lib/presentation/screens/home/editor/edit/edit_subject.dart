import 'package:cenec_app/presentation/screens/home/editor/add/new_task.dart';
import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/edit/edit_task.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SubjectDetails extends StatefulWidget {
  final String subjectId;

  const SubjectDetails({super.key, required this.subjectId});

  @override
  SubjectDetailsState createState() => SubjectDetailsState();
}

class SubjectDetailsState extends State<SubjectDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pColorController = TextEditingController();
  final TextEditingController _sColorController = TextEditingController();
  final TextEditingController _subscribersController = TextEditingController();
  final TextEditingController _tasksController = TextEditingController();

  List<String> subscribers = [];
  List<String> tasks = [];

  bool _isEditable = false;
  Map<String, dynamic>? subjectData;

  @override
  void initState() {
    super.initState();
    loadSubjectData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pColorController.dispose();
    _sColorController.dispose();
    _subscribersController.dispose();
    _tasksController.dispose();
    super.dispose();
  }

  Future<void> loadSubjectData() async {
    try {
      DocumentSnapshot subjectSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .get();

      if (subjectSnapshot.exists) {
        setState(() {
          subjectData = subjectSnapshot.data() as Map<String, dynamic>;
        });
        _nameController.text = subjectData!['name'] ?? "";
        _pColorController.text = subjectData!['pColor'] ?? "";
        _sColorController.text = subjectData!['sColor'] ?? "";

        List<dynamic> loadedSubscribers = subjectData!['subscribers'] ?? [];
        subscribers = List<String>.from(loadedSubscribers);

        QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
            .collection('subjects')
            .doc(widget.subjectId)
            .collection('tasks')
            .get();

        tasks = tasksSnapshot.docs.map((doc) => doc['name'] as String).toList();
      } else {
        if (kDebugMode) {
          print('No such document!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading subject: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                navigateToReplace(context, const BaseEditorPage());
              },
            ),
            const Text("Edit Subject"),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon:
                _isEditable ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditable ? _editSubject() : null;
                _isEditable = !_isEditable;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteSubject();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              loadSubjectData();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Subject Id: ${widget.subjectId}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.subjectId));
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Subject name",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
                    controller: _pColorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Subject Primary Color",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
                    controller: _sColorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Subject Secondary Color",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildSubscribersField(),
                  _buildSubscribersList(),
                  const SizedBox(height: 20),
                  _buildTasksField(),
                  _buildTasksList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribersField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: _isEditable,
            controller: _subscribersController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Add Subscriber",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _isEditable ? _addSubscriber : null,
        ),
      ],
    );
  }

  Widget _buildSubscribersList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subscribers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(subscribers[index],
              style: const TextStyle(color: Colors.white)),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isEditable
                    ? () {
                        _editSubscriber(index);
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isEditable
                    ? () {
                        setState(() => subscribers.removeAt(index));
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _addSubscriber() {
    if (_subscribersController.text.isNotEmpty) {
      setState(() {
        subscribers.add(_subscribersController.text);
        _subscribersController.clear();
      });
    }
  }

  void _editSubscriber(int index) {
    TextEditingController editController =
        TextEditingController(text: subscribers[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Subscriber"),
          content: TextField(
            enabled: _isEditable,
            controller: editController,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  subscribers[index] = editController.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTasksField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: _isEditable,
            controller: _tasksController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "Add Task",
              labelStyle: const TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _isEditable ? _addTask : null,
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title:
              Text(tasks[index], style: const TextStyle(color: Colors.white)),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _isEditable
                    ? () {
                        _navigateToTaskEditPage(index);
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToTaskEditPage(int index) async {
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .doc(widget.subjectId)
        .collection('tasks')
        .get();

    List<String> taskIds = tasksSnapshot.docs.map((doc) => doc.id).toList();
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetails(
          subjectId: widget.subjectId,
          taskId: taskIds[index],
        ),
      ),
    );
  }

  void _addTask() {
    if (_tasksController.text.isNotEmpty) {
      navigateTo(context,
          NewTask(subjectId: widget.subjectId, name: _tasksController.text));
      setState(() {
        _tasksController.clear();
      });
    }
  }

  void _editSubject() async {
    try {
      DocumentReference subjectRef = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId);

      await subjectRef.update({
        'name': _nameController.text,
        'pColor': _pColorController.text,
        'sColor': _pColorController.text,
        'subscribers': subscribers,
        'tasks': tasks,
      });

      QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('tasks')
          .get();

      List<String> taskIds = tasksSnapshot.docs.map((doc) => doc.id).toList();

      for (String taskId in taskIds) {
        await addTaskToSubscribedUsers(widget.subjectId, taskId);
      }

      setState(() {
        _isEditable = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating subject: $e');
        if (e is FirebaseException && e.code == 'not-found') {
          print('Document does not exist!');
        }
      }
    }
  }

  void _deleteSubject() async {
    try {
      DocumentReference subjectRef = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId);

      await subjectRef.delete();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting subject: $e');
      }
    }
  }
}

Future<void> addTaskToSubscribedUsers(String subjectId, String taskId) async {
  try {
    CollectionReference subjectsCollection =
        FirebaseFirestore.instance.collection('subjects');
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Obtener la lista de suscriptores de la asignatura
    DocumentSnapshot subjectSnapshot =
        await subjectsCollection.doc(subjectId).get();
    Map<String, dynamic>? subjectData =
        subjectSnapshot.data() as Map<String, dynamic>?;

    // Verificar si el documento existe y contiene la lista de suscriptores
    if (subjectData != null && subjectData.containsKey('subscribers')) {
      List<dynamic> subscribers = subjectData['subscribers'];

      // Iterar sobre cada suscriptor y agregar la tarea no presentada si el usuario existe
      for (String subscriberId in subscribers) {
        // Verificar si el usuario existe en la colección de usuarios
        DocumentSnapshot userSnapshot =
            await usersCollection.doc(subscriberId).get();
        if (userSnapshot.exists) {
          // Agregar la ID de la tarea no presentada al usuario
          await usersCollection.doc(subscriberId).update({
            'unsubmittedTasks': FieldValue.arrayUnion(
                [taskId]), // Aquí se añade la ID del tarea
          });
        }
      }
    }

    if (kDebugMode) {
      print('Tarea añadida a los usuarios suscritos correctamente.');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al añadir la tarea a los usuarios suscritos: $e');
    }
  }
}
