import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/item_model.dart';
import 'package:line_skip_admin/models/store_model.dart';
import 'package:line_skip_admin/pages/item/add_item_page.dart';
import 'package:line_skip_admin/pages/store/add_store_page.dart';
import 'package:line_skip_admin/widgets/item_card.dart';

class StorePage extends StatefulWidget {
  final StoreModel store;

  const StorePage({super.key, required this.store});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<ItemModel> inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToInventoryUpdates();
  }

  void _editStore() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddStorePage(store: widget.store, isEdit: true),
      ),
    );
  }

  void _listenToInventoryUpdates() {
    final storeInventoryRef = FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.store.storeId)
        .collection('items');

    storeInventoryRef.snapshots().listen((snapshot) {
      final updatedInventory =
          snapshot.docs.map(ItemModel.fromFirestore).toList();

      if (!listEquals(updatedInventory, inventory)) {
        setState(() {
          inventory = updatedInventory;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editStore),
        ],
      ),
      body: Stack(
        children: [
          if (widget.store.storeImage.isNotEmpty)
            _buildBackgroundImage(context),
          _buildInventoryGrid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddItemPage(storeId: widget.store.storeId),
            ),
          );
        },
        label: const Text('Add Item'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBackgroundImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Image.network(
            widget.store.storeImage,
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
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
            errorBuilder:
                (_, __, ___) =>
                    const Center(child: Icon(Icons.error, size: 100)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inventory.isEmpty) {
      return const Center(child: Text('No items found in this store.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = max(constraints.maxWidth ~/ 200, 2);
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3 / 5,
          ),
          itemCount: inventory.length,
          itemBuilder: (context, index) {
            final item = inventory[index];
            return ItemCard(item: item, storeId: widget.store.storeId);
          },
        );
      },
    );
  }
}
