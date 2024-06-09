
import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/see/subjects.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NewSubject extends StatefulWidget {
  const NewSubject({super.key});

  @override
  NewSubjectState createState() => NewSubjectState();
}

class NewSubjectState extends State<NewSubject> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pColorController = TextEditingController();
  final TextEditingController _sColorController = TextEditingController();
  final TextEditingController _subscribersController = TextEditingController();
  List<String> subscribers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _pColorController.dispose();
    _sColorController.dispose();
    _subscribersController.dispose();
    super.dispose();
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
            const Text("New Subject"),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: "Subject Name",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pColorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: "Primary Color",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _sColorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      labelText: "Secondary Color",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildSubscribersField(),
                  _buildSubscribersList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _saveSubject,
                    child: const Text("Save Subject", style: TextStyle(color: Colors.white)),
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

  Widget _buildSubscribersField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _subscribersController,
            decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: "Add Subscriber",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addSubscriber(),
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
          title: Text(subscribers[index]),
          trailing: Wrap(
            spacing: 12,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editSubscriber(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => setState(() => subscribers.removeAt(index)),
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
    TextEditingController editController = TextEditingController(text: subscribers[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Subscriber"),
          content: TextField(
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

  void _saveSubject() async {
    try {
      CollectionReference subjects = FirebaseFirestore.instance.collection('subjects');
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
          
      DocumentReference newSubjectRef = await subjects.add({
        'name': (_nameController.text.isEmpty?"Desconocido":_nameController.text),
        'pColor': (_pColorController.text.isEmpty?"#A3E4D7":_pColorController.text),
        'sColor': (_sColorController.text.isEmpty?"#76D7C4":_sColorController.text),
        'subscribers': subscribers,
      });

      await users.doc(FirebaseAuth.instance.currentUser?.uid).update({
        'c_subjects': FieldValue.arrayUnion([newSubjectRef.id])
      });

      // ignore: use_build_context_synchronously
      navigateToReplace(context, const SubjectsListPage());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving subject: $e');
      }
    }
  }
}
