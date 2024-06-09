import 'dart:io';

import 'package:cenec_app/resources/classes/models.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final model.Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea',
            style: Theme.of(context).textTheme.displayMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.name, style: Theme.of(context).textTheme.headlineMedium),
            const Divider(),
            Text('Descripción: ${task.description}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text('Tipo de Tarea: ${task.isExam ? "Examen" : "Tarea Regular"}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text('Fecha de Creación: ${task.creationDate}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Text('Fecha de Entrega: ${task.dueDate}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: CheckButton(task: task),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file,color: Colors.black,),
                label: const Text("Subir Archivo",style: TextStyle(color: Colors.white),),
                onPressed: () => pickAndUploadFile(),
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.blueAccent)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickAndUploadFile() async {
    // Seleccionar el archivo
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final path = result.files.single.path!;
    final fileName = result.files.single.name;

    // Subida del archivo a Firebase Storage
    final file = File(path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('uploads')
        .child(task.uid)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(fileName);
    ref.putFile(file);
  }
}

class CheckButton extends StatefulWidget {
  final model.Task task;

  const CheckButton({super.key, required this.task});

  @override
  CheckButtonState createState() => CheckButtonState();
}

class CheckButtonState extends State<CheckButton> {
  late bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _determineInitialCheck();
  }

  void _determineInitialCheck() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var subjectQuery = await FirebaseFirestore.instance
        .collection('subjects')
        .where('subscribers', arrayContains: userId)
        .get();
    for (var subject in subjectQuery.docs) {
      var tasksSnapshot = await subject.reference.collection('tasks').get();
      for (var doc in tasksSnapshot.docs) {
        model.Task task = model.Task.fromFirestore(doc.data())..uid = doc.id;
        if (widget.task.uid == task.uid) {
          widget.task.subjectUid = subject.id;}}
        }

    String status = await widget.task.getStatusByUser(userId);
    print(status);
    _isChecked = status == "completed";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future:
          getStatus(), // Llama a la función getStatus() que es Future<String>
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un loader mientras se espera la respuesta
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          String status = snapshot.data!;
          return ElevatedButton.icon(
              icon: Icon(
                status == "completed" ? Icons.check : Icons.hourglass_empty,
                color: Colors.black,
              ),
              label: Text(
                status == "completed"
                    ? "Tarea Completada"
                    : (status == "pending" ? "Pendiente" : "Sin entregar"),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _updateTaskStatus(),
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  minimumSize: const Size(200, 50),
                  backgroundColor: status == "completed"
                      ? Colors.lightGreen
                      : (status == "pending"
                          ? Colors.amber
                          : Colors.redAccent)));
        }
      },
    );
  }

  Future<void> _updateTaskStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DateTime dueDate = widget.task.dueDate ?? DateTime.now();
    DateTime now = DateTime.now();

    if (now.isAfter(dueDate)) {
      String newStatus = _isChecked ? "unsubmitted" : "completed";
      await widget.task.setStatusForUser(userId, newStatus);
    } else {
      String newStatus = _isChecked ? "pending" : "completed";
      await widget.task.setStatusForUser(userId, newStatus);
    }

    _isChecked = !_isChecked;
    setState(() {});
  }

  Future<String> getStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String status = await widget.task.getStatusByUser(userId);
    return status;
  }
}
