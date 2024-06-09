import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskDetails extends StatefulWidget {
  final String subjectId;
  final String taskId;
  const TaskDetails({super.key, required this.subjectId, required this.taskId});

  @override
  TaskDetailsState createState() => TaskDetailsState();
}

class TaskDetailsState extends State<TaskDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _creationDateController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  bool _isExam = false;

  bool _isEditable = false;
  Map<String, dynamic>? taskData;

  @override
  void initState() {
    super.initState();
    loadTaskData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _creationDateController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> loadTaskData() async {
    try {
      DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (taskSnapshot.exists) {
        setState(() {
          taskData = taskSnapshot.data() as Map<String, dynamic>;
        });
        _nameController.text = taskData!['name'] ?? "";
        _descriptionController.text = taskData!['description'] ?? "";
        _creationDateController.text = taskData!['creationDate'] ?? "";
        _dueDateController.text = taskData!['dueDate'] ?? "";
        _isExam = taskData!['isExam'] ?? false;
      } else {
        if (kDebugMode) {
          print('No such document!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading task: $e');
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
            const Text("Edit Task"),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon:
                _isEditable ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditable ? _editTask():null;
                _isEditable = !_isEditable;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteTask();
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
                children: [
                  Row(
                    children: [
                      Text("Task Id ${widget.taskId}", style: const TextStyle(color: Colors.white),),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.taskId));
                              },
                      ),
                    ],
                  ),
                  TextField(
                    enabled: _isEditable,
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Name",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Description",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: false,
                    controller: _creationDateController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Creation Date",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: _isEditable,
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Due Date",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    enabled: _isEditable,
                    title: const Text("Es examen",
                        style: TextStyle(color: Colors.black)),
                    value: _isExam,
                    onChanged: (bool? value) {
                      setState(() {
                        _isExam = value ?? false;
                      });
                    },
                    activeColor: Colors.grey,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editTask() async {
    try {
      CollectionReference tasks = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('tasks');

      await tasks.doc(widget.taskId).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDateController.text,
        'isExam': _isExam
      });

      if (kDebugMode) {
        print('Task updated successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
    }
  }

  void _deleteTask() async {
    try {
      DocumentReference subjectRef = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('tasks')
          .doc(widget.taskId);

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
