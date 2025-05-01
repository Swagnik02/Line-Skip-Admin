import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/store_model.dart';
import 'package:line_skip_admin/pages/add_store_page.dart';

class StorePage extends StatelessWidget {
  final StoreModel store;

  const StorePage({super.key, required this.store});

  void _editStore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddStorePage(storeId: store.storeId, isEdit: true),
      ),
    );
  }

  void _addItem(BuildContext context) {
    // Create add item page later
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
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
            store.storeImage.isNotEmpty
                ? Image.network(
                  store.storeImage,
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
                : SizedBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context),
        label: const Text('Add Item'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
