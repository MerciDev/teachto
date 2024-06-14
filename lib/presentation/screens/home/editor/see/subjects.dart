import 'package:cenec_app/presentation/screens/home/editor/add/new_subject.dart';
import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/edit/edit_subject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubjectsListPage extends StatefulWidget {
  const SubjectsListPage({super.key});

  @override
  SubjectsListPageState createState() => SubjectsListPageState();
}

class SubjectsListPageState extends State<SubjectsListPage> {
  late final Stream<List<QueryDocumentSnapshot>> _subjectsStream;

  @override
  void initState() {
    super.initState();
    _subjectsStream = _loadUserSubjects();
  }

  Stream<List<QueryDocumentSnapshot>> _loadUserSubjects() async* {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      List<dynamic> subjectIds = userDoc.data()?['c_subjects'] ?? [];
      yield* FirebaseFirestore.instance
          .collection('subjects')
          .where(FieldPath.documentId, whereIn: subjectIds)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      yield [];
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
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const BaseEditorPage()));
              },
            ),
            const Text("Subjects"),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NewSubject()));
            },
          ),
          const SizedBox(width: 50)
        ],
      ),
      body: Container(
        color: Colors.blueGrey,
        child: StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _subjectsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var docs = snapshot.data ?? [];
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data = docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              SubjectDetails(subjectId: docs[index].id)));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.subject,
                              size: 30, color: Theme.of(context).primaryColor),
                          Text(data['name'] ?? 'No Name',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: docs[index].id));
                              },
                              icon: const Icon(Icons.copy)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
