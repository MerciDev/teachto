import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/see/subjects.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class NewTask extends StatefulWidget {
  final String? name;
  final String subjectId;
  const NewTask({super.key, required this.subjectId, this.name});

  @override
  NewTaskState createState() => NewTaskState();
}

class NewTaskState extends State<NewTask> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _creationDateController = TextEditingController();
  bool _isExam = false;

  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? "";
    _creationDateController.text =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
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
            const Text("New Task"),
          ],
        ),
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
                  TextField(
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
                  DateTimeField(
                    format: DateFormat("dd/MM/yyyy HH:mm"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Due Date",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (DateTime? value) {
                      setState(() {
                        _dueDate = value;
                      });
                    },
                    onShowPicker: (context, currentValue) async {
                      return await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: currentValue ?? DateTime.now(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _saveTask,
                    child: const Text("Save Task",
                        style: TextStyle(color: Colors.white)),
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

  void _saveTask() async {
    try {
      CollectionReference tasks = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subjectId)
          .collection('tasks');

      String formattedDueDate = _dueDate != null
          ? DateFormat("dd/MM/yyyy HH:mm").format(_dueDate!)
          : "00/00/0000 00:00";

      await tasks.add({
        'name': (_nameController.text.isEmpty
            ? "Unnamed Task"
            : _nameController.text),
        'description': (_descriptionController.text.isEmpty
            ? ""
            : _descriptionController.text),
        'creationDate': (_creationDateController.text.isEmpty
            ? DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now())
            : _creationDateController.text),
        'dueDate': formattedDueDate,
        'isExam': _isExam
      });

      // ignore: use_build_context_synchronously
      navigateToReplace(context, const SubjectsListPage());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving task: $e');
      }
    }
  }
}
