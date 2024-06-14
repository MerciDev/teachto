import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Subject {
  late String uid;
  final String name;
  final Color pColor;
  late Color sColor;
  final DocumentReference reference;
  final List<dynamic> subscribers;

  Subject(
      {this.uid = "",
      required this.name,
      required this.pColor,
      required this.reference,
      required this.sColor,
      required this.subscribers});

  static Subject fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    String pColorString = data['pColor'] as String? ?? '#A3E4D7';
    String sColorString = data['sColor'] as String? ?? '#76D7C4';
    List<dynamic> emptyList = [];
    return Subject(
      uid: doc.id,
      name: data['name'] ?? "",
      pColor: Color(int.parse('0xff${pColorString.substring(1)}')),
      sColor: Color(int.parse('0xff${sColorString.substring(1)}')),
      subscribers: data['subscribers'] ?? emptyList,
      reference: doc.reference,
    );
  }
}

class Task {
  late String uid;
  final String name;
  final String description;
  final DateTime? creationDate;
  final DateTime? dueDate;
  late bool isExam;
  late String subjectUid;

  Task(
      {this.uid = "",
      this.name = "Nombre Desconocido",
      this.description = "Sin Descripción",
      this.creationDate,
      this.dueDate,
      this.isExam = false,
      this.subjectUid = ""});

  static Task fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    DateTime? dueDate;
    if (data['dueDate'] != null) {
      String date = data['dueDate'];
      DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      try {
        dueDate = format.parse(date);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing dueDate: $e");
        }
        dueDate = DateTime.now(); // Fallback to current date on parse error
      }
    } else {
      dueDate = DateTime.now();
    }

    DateTime? creationDate;
    if (data['creationDate'] != null) {
      String date = data['creationDate'];
      DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      try {
        creationDate = format.parse(date);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing creationDate: $e");
        }
        creationDate =
            DateTime.now(); // Fallback to current date on parse error
      }
    } else {
      creationDate = DateTime.now();
    }
    return Task(
        uid: doc.id, // Using the document ID as the Task UID
        name: data['name'] ?? "Nombre Desconocido",
        description: data['description'] ?? "Sin Descripción",
        dueDate: dueDate,
        creationDate: creationDate);
  }

  static Task fromFirestore(Map<String, dynamic> data) {
    DateTime? dueDate;
    if (data['dueDate'] != null) {
      String date = data['dueDate'];
      DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      dueDate = format.parse(date);
    } else {
      dueDate = DateTime.now();
    }

    DateTime? creationDate;
    if (data['creationDate'] != null) {
      String date = data['creationDate'];
      DateFormat format = DateFormat("dd/MM/yyyy HH:mm");
      creationDate = format.parse(date);
    } else {
      creationDate = DateTime.now();
    }

    return Task(
        uid: data['uid'] ??
            "", // Asegurarse de manejar el caso cuando uid sea null
        name: data['name'] ??
            "", // Asegurarse de manejar el caso cuando name sea null
        description: data['description'] ??
            "", // Asegurarse de manejar el caso cuando description sea null
        dueDate: dueDate,
        isExam: data['isExam'] ?? false,
        creationDate: creationDate);
  }

  Future<String> getStatusByUser(String userId) async {
    String status = "unknown";

    try {
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectUid)
          .collection('tasks')
          .doc(uid)
          .collection('userData')
          .doc(userId)
          .get();

      if (userDataSnapshot.exists) {
        Map<String, dynamic> userData =
            userDataSnapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('status')) {
          status = userData['status'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener el estado: $e');
      }
    }

    return status;
  }

  Future<void> setStatusForUser(String userId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectUid)
          .collection('tasks')
          .doc(uid)
          .collection('userData')
          .doc(userId)
          .set({'status': status}, SetOptions(merge: true));

      if (kDebugMode) {
        print('Estado actualizado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar el estado: $e');
      }
    }
  }
}
