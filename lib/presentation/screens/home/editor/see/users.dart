import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/edit/edit_user.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

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
            const Text("Users"),
          ],
        ),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      navigateTo(context, UserDetails(userId: docs[index].id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            data['name'] ?? 'No Name',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: docs[index].id));
                            },
                            icon: const Icon(Icons.copy),
                          ),
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
