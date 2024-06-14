import 'package:cenec_app/presentation/screens/home/editor/add/new_promotion.dart';
import 'package:cenec_app/presentation/screens/home/editor/base.dart';
import 'package:cenec_app/presentation/screens/home/editor/edit/edit_promotion.dart';
import 'package:cenec_app/resources/functions/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class PromotionsListPage extends StatefulWidget {
  const PromotionsListPage({super.key});

  @override
  PromotionsListPageState createState() => PromotionsListPageState();
}

class PromotionsListPageState extends State<PromotionsListPage> {
  late final Stream<List<QueryDocumentSnapshot>> _promotionsStream;

  @override
  void initState() {
    super.initState();
    _promotionsStream = _loadUserPromotions();
  }

  Stream<List<QueryDocumentSnapshot>> _loadUserPromotions() async* {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      List<dynamic> subjectIds = userDoc.data()?['c_promotions'] ?? [];
      yield* FirebaseFirestore.instance
          .collection('promotions')
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
                  navigateToReplace(context, const BaseEditorPage());
                },
              ),
              const Text("Promotions"),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                navigateTo(context, const NewPromotion());
              },
            ),
          ]),
      body: Container(
        color: Colors.blueGrey,
        child: StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _promotionsStream,
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
                Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      navigateTo(context,
                          PromotionDetails(promotionId: docs[index].id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.local_offer,
                              size: 30, color: Theme.of(context).primaryColor),
                          Text(data['title'] ?? 'No Name',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: docs[index].id));
                              },
                              icon: const Icon(
                                Icons.copy,
                              )),
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
