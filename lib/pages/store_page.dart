import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/store_model.dart';

class StorePage extends StatelessWidget {
  final StoreModel store;

  const StorePage({super.key, required this.store});

  void _editStore(BuildContext context) {
    // Create edit page later
  }

  void _addItem(BuildContext context) {
    // Create add item page later
  }

  @override
  Widget build(BuildContext context) {
    // Access store properties directly as they belong to StoreModel
    final storeName = store.name ?? 'Store'; // Accessing store name
    final storeImage = store.storeImage ?? ''; // Accessing store image URL
    final storeDescription =
        store.description ??
        'No description available'; // Accessing description

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editStore(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display store image with a fallback if the image URL is invalid
            storeImage.isNotEmpty
                ? Image.network(
                  storeImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 100);
                  },
                )
                : const Icon(
                  Icons.store,
                  size: 100,
                ), // Fallback icon if no image URL

            const SizedBox(height: 20),
            // Description of the store
            Text(storeDescription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addItem(context),
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
