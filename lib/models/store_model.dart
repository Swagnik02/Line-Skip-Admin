import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String name;
  final String description;
  final String location;
  final bool hasTrolleyPairing;
  final String storeImage;
  final Timestamp createdAt;

  StoreModel({
    required this.name,
    required this.description,
    required this.location,
    required this.hasTrolleyPairing,
    required this.storeImage,
    required this.createdAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      hasTrolleyPairing: map['hasTrolleyPairing'] ?? false,
      storeImage: map['storeImage'] ?? '',
      createdAt: map['createdAt'] as Timestamp, // Ensure this is cast correctly
    );
  }
}
