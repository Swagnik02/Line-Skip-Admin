import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/item_model.dart';
import 'package:line_skip_admin/pages/item/item_page.dart';
import 'package:line_skip_admin/utils/barcode_generator.dart';
import 'package:line_skip_admin/utils/width_of_card.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final String storeId;
  const ItemCard({super.key, required this.item, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ItemPage(item: item)),
            ),

        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 48);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      avatar: const Icon(
                        Icons.local_offer,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Rs.${item.price.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              /// 🔽 Use FutureBuilder here
              FutureBuilder<Uint8List>(
                future: getBarcodeImage(item.barcode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 200,
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error, size: 48);
                  } else {
                    return Image.memory(
                      width: getWidthOfCard(context),
                      snapshot.data!,

                      scale: 0.5,
                    );
                  }
                },
              ),

              const SizedBox(height: 4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Text(
                      item.brandName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
