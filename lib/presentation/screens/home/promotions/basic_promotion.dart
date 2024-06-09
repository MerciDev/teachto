import 'package:cenec_app/resources/classes/promotion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PromotionDetailPage extends StatelessWidget {
  final Promotion promotion;

  const PromotionDetailPage({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    // Calcula el precio con descuento
    final double discountedPrice =
        promotion.originalPrice * (1 - promotion.discountPercentage / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Oferta',
            style: Theme.of(context).textTheme.displayMedium),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                promotion.imagePath, // Asegúrate de que esta sea una URL válida
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Text(
                promotion.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                promotion.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Localizaciones Disponibles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: promotion.locations.map((location) {
                  return Text(
                    ' - $location',
                    style: const TextStyle(fontSize: 16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Modalidades Disponibles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: promotion.modalities.map((modality) {
                  return Text(
                    ' - $modality',
                    style: const TextStyle(fontSize: 16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Precio Total: ${promotion.originalPrice.toStringAsFixed(2)}€',
                    style: const TextStyle(
                        fontSize: 18, decoration: TextDecoration.lineThrough),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Descuento: ${promotion.discountPercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Precio con Descuento: ${discountedPrice.toStringAsFixed(2)}€',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FloatingActionButton(
                    onPressed: () {
                      for (var subjectId in promotion.subjectIds) {
                        addCourse(subjectId);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Comprar"),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> addCourse(String uid) async {
  DocumentReference subject =
      FirebaseFirestore.instance.collection('subjects').doc(uid);

  return subject.update({
    'subscribers':
        FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid])
  });
}
