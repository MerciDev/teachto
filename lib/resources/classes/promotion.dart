import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String title;
  final String imagePath;
  final String description;
  final List<String> locations;
  final List<String> modalities;
  final double originalPrice;
  final int discountPercentage;
  final double discountedPrice;
  final List<String> subjectIds;
  final List<String> tags;

  Promotion({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.locations,
    required this.modalities,
    required this.originalPrice,
    required this.discountPercentage,
    required this.subjectIds,
    required this.tags,
  }) : discountedPrice = originalPrice * (1 - discountPercentage / 100);

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Promotion(
      title: data['title'] ?? "",
      imagePath: (data['imagePath'] == "" || data['imagePath'] == null)
          ? "https://www.picserver.org/assets/library/2020-10-31/originals/example1.jpg"
          : data['imagePath'],
      description: data['description'] ?? "",
      locations: (data['locations'] != null)
          ? List<String>.from(data['locations'])
          : [],
      modalities: (data['modalities'] != null)
          ? List<String>.from(data['modalities'])
          : [],
      originalPrice: (data['originalPrice'] != null)
          ? data['originalPrice'].toDouble()
          : 0.0,
      discountPercentage: data['discountPercentage'] ?? 0,
      subjectIds: (data['subjectIds'] != null)
          ? List<String>.from(data['subjectIds'])
          : [],
      tags: (data['tags'] != null) ? List<String>.from(data['tags']) : [],
    );
  }

  static Future<List<Promotion>> getPromotions() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('promotions').get();
    return snapshot.docs.map((doc) => Promotion.fromFirestore(doc)).toList();
  }
}
