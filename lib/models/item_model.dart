import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String barcode;
  String name;
  String brandName;
  double price;
  double weight;
  String imageUrl;
  String category;
  String? description;
  String storeId;

  // Constructor
  ItemModel({
    required this.barcode,
    this.name = "",
    this.brandName = "",
    this.price = 0,
    this.weight = 0,
    this.imageUrl = "",
    this.category = "",
    this.description = "",
    this.storeId = "",
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brandName': brandName,
      'price': price,
      'weight': weight,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'storeId': storeId,
    };
  }

  // Create from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      barcode: json['barcode'],
      name: json['name'] ?? '',
      brandName: json['brandName'] ?? '',
      price: json['price'] ?? 0.0,
      weight: json['weight'] ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      storeId: json['storeId'] ?? '',
    );
  }

  // Create from Firestore DocumentSnapshot
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ItemModel(
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? '',
      brandName: data['brandName'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      weight: data['weight']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      storeId: data['storeId'] ?? '',
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'brandName': brandName,
      'price': price,
      'weight': weight,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'storeId': storeId,
    };
  }

  // Copy with updated fields
  ItemModel copyWith({
    String? barcode,
    String? name,
    String? brandName,
    double? price,
    double? weight,
    String? imageUrl,
    String? category,
    String? description,
    String? storeId,
  }) {
    return ItemModel(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brandName: brandName ?? this.brandName,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      description: description ?? this.description,
      storeId: storeId ?? this.storeId,
    );
  }
}

final testItem = ItemModel(
  barcode: '8901063035027',
  name: 'Milk Bikis',
  brandName: 'Britannia',
  price: 30,
  weight: 0.5,
  imageUrl:
      'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcQ6a35LLqf8AOdEbrbOGXJJ6YTFyjIhTxBKK09B5ynEx_JlB5pCprzp_4w_H8qYdB5KbCy9uvrfHFJCNXqo2Q6sp5rrHcyN',
  category: 'Snacks',
  description: 'Delicious milk-based biscuits.',
);

Future<void> addItem(ItemModel item) async {
  print('Adding item: ${item.name} to Store with docId: ${item.storeId}');
  final storeRef = FirebaseFirestore.instance
      .collection('stores')
      .doc(item.storeId);
  final itemsCollectionRef = storeRef.collection('items').doc(item.barcode);

  await itemsCollectionRef.set(item.toMap());
  print('Added: ${item.name} to Store with docId: ${item.storeId}');
}

Future<void> deleteItem(ItemModel item) async {
  final storeRef = FirebaseFirestore.instance
      .collection('stores')
      .doc(item.storeId);
  final itemsCollectionRef = storeRef.collection('items').doc(item.barcode);

  await itemsCollectionRef.delete();
  print(
    'Deleted item with barcode: ${item.barcode} from Store with docId: ${item.storeId}',
  );
}
