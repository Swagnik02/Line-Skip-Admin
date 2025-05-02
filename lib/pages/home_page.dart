import 'dart:math' show max, pi;
import 'dart:developer' show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_skip_admin/models/store_model.dart';
import 'package:line_skip_admin/pages/store/add_store_page.dart';
import 'package:line_skip_admin/pages/store/store_page.dart';
import 'package:line_skip_admin/utils/barcode_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<StoreModel> stores = [];
  bool isLoading = true;
  bool useRealTimeUpdates = true;

  @override
  void initState() {
    super.initState();
    useRealTimeUpdates ? listenToStoreUpdates() : fetchAllStores();
  }

  // Real-time fetching using snapshots
  void listenToStoreUpdates() {
    FirebaseFirestore.instance.collection('stores').snapshots().listen((
      snapshot,
    ) {
      final updatedStores =
          snapshot.docs.map((doc) => StoreModel.fromMap(doc.data())).toList();
      // Only update if the data is different
      if (updatedStores != stores) {
        setState(() {
          stores = updatedStores;
          isLoading = false;
        });
      }
    });
  }

  // One-time fetch using get()
  Future<void> fetchAllStores() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('stores').get();
      final fetchedStores =
          snapshot.docs.map((doc) => StoreModel.fromMap(doc.data())).toList();
      // Only update if the data is different
      if (fetchedStores != stores) {
        setState(() {
          stores = fetchedStores;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('Error fetching stores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stores'),
        actions: [
          IconButton(
            icon: Transform.rotate(
              angle:
                  90 * pi / 180, // Rotating 90 degrees (converted to radians)
              child: const Icon(Icons.document_scanner_outlined),
            ),
            onPressed: () async {
              final barcode = await scanBarcode(context);
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Scanned Barcode'),
                    content: Text(barcode),
                  );
                },
              );
            },
          ),

          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildStoreTiles(context, width),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStorePage()),
          );
        },
        tooltip: 'Add New Store',
        icon: const Icon(Icons.add),
        label: const Text('Add Store'),
      ),
    );
  }

  // Builds the store tiles
  Widget _buildStoreTiles(BuildContext context, double width) {
    if (stores.isEmpty) {
      return const Center(child: Text('No stores found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 9 / 16,
        crossAxisCount: max(width ~/ 200, 2),
      ),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return storeCard(context, store);
      },
    );
  }

  Widget storeCard(BuildContext context, StoreModel store) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StorePage(store: store)),
            ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Card(
            elevation: 0,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    store.storeImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 48);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    store.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
