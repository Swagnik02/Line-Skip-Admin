import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String storeId;
  final String name;
  final String description;
  final String location;
  final String storeImage;
  final String storeUpiId;
  final String mobileNumber;
  final String ownerName;
  final bool hasTrolleyPairing;

  StoreModel({
    required this.storeId,
    required this.name,
    required this.description,
    required this.location,
    required this.storeImage,
    required this.storeUpiId,
    required this.mobileNumber,
    required this.ownerName,
    required this.hasTrolleyPairing,
  });

  factory StoreModel.fromMap(Map<String, dynamic> data) {
    return StoreModel(
      storeId: data['storeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      storeImage: data['storeImage'] ?? '',
      storeUpiId: data['storeUpiId'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      ownerName: data['ownerName'] ?? '',
      hasTrolleyPairing: data['hasTrolleyPairing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'description': description,
      'location': location,
      'storeImage': storeImage,
      'storeUpiId': storeUpiId,
      'mobileNumber': mobileNumber,
      'ownerName': ownerName,
      'hasTrolleyPairing': hasTrolleyPairing,
    };
  }

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      storeId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      storeImage: data['storeImage'] ?? '',
      storeUpiId: data['storeUpiId'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      ownerName: data['ownerName'] ?? '',
      hasTrolleyPairing: data['hasTrolleyPairing'] ?? false,
    );
  }
}
