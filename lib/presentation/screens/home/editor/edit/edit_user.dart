
import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserDetails extends StatefulWidget {
  final String userId;
  const UserDetails({super.key, required this.userId});

  @override
  UserDetailsState createState() => UserDetailsState();
}

class UserDetailsState extends State<UserDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _completedController = TextEditingController();
  final TextEditingController _pendingController = TextEditingController();
  final TextEditingController _unsubmittedController = TextEditingController();

  List<String> completedTasks = [];
  List<String> pendingTasks = [];
  List<String> unsubmittedTasks = [];
  bool _isEditable = false;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _completedController.dispose();
    _pendingController.dispose();
    _unsubmittedController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
        });
        _nameController.text = userData!['name'];
        _emailController.text = userData!['email'];

        completedTasks = List<String>.from(userData!['completedTasks'] ?? []);
        pendingTasks = List<String>.from(userData!['pendingTasks'] ?? []);
        unsubmittedTasks = List<String>.from(userData!['unsubmittedTasks'] ?? []);
      } else {
        if (kDebugMode) {
          print('No such document!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<String?> findSubjectIdByTaskId(String taskId) async {
    QuerySnapshot subjectsSnapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .get();

    for (QueryDocumentSnapshot subjectDoc in subjectsSnapshot.docs) {
      Map<String, dynamic> subjectData = subjectDoc.data() as Map<String, dynamic>;
      List<String> taskIds = List<String>.from(subjectData['tasks'] ?? []);
      if (taskIds.contains(taskId)) {
        return subjectDoc.id;
      }
    }
    return null;
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
            const Text("Edit User"),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: _isEditable ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditable) {
                  _editUser();
                }
                _isEditable = !_isEditable;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteUser();
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
                      Text(
                        "User ID: ${widget.userId}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.userId));
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
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "User Name",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: false,
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editUser() async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      await userRef.update({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      setState(() {
        _isEditable = false;
      });

    } catch (e) {
      if (kDebugMode) {
        print('Error updating user: $e');
        if (e is FirebaseException && e.code == 'not-found') {
          print('Document does not exist!');
        }
      }
    }
  }

  void _deleteUser() async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

      await userRef.delete();
      Navigator.pop(context);

    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
    }
  }
}
