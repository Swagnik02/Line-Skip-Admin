import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/item_model.dart';
import 'package:line_skip_admin/pages/item/add_item_page.dart';
import 'package:line_skip_admin/utils/barcode_generator.dart';
import 'package:line_skip_admin/utils/width_of_card.dart';

class ItemPage extends StatelessWidget {
  final ItemModel item;

  const ItemPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              {
                final updatedItem = await Navigator.of(context).push<ItemModel>(
                  MaterialPageRoute(
                    builder: (context) => AddItemPage(item: item, isEdit: true),
                  ),
                );

                if (updatedItem != null) {
                  // Rebuild the widget with the new item
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ItemPage(item: updatedItem),
                    ),
                  );
                }
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteItem(item);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Barcode',
              item.barcode,
              buildBarcode: _buildBarcode(),
            ),
            _buildDetailCard('Brand', item.brandName),
            _buildDetailCard('Price', '\$${item.price.toStringAsFixed(2)}'),
            _buildDetailCard('Weight', '${item.weight} kg'),
            _buildDetailCard('Category', item.category),
            if (item.description != null && item.description!.isNotEmpty)
              _buildDetailCard('Description', item.description!),
          ],
        ),
      ),
    );
  }

  // Your barcode widget builder
  FutureBuilder<Uint8List> _buildBarcode() {
    return FutureBuilder<Uint8List>(
      future: getBarcodeImage(item.barcode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 200,
            height: 50,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, size: 48);
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(
              width: getWidthOfCard(context),
              snapshot.data!,

              scale: 0.5,
            ),
          );
        }
      },
    );
  }

  // _buildDetailCard widget
  Widget _buildDetailCard(String title, String value, {Widget? buildBarcode}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(value), buildBarcode ?? const SizedBox.shrink()],
        ),
        leading: const Icon(Icons.info_outline),
      ),
    );
  }
}
