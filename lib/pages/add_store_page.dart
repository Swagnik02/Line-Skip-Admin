import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key});

  @override
  State<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _hasTrolleyPairing = false;
  File? _pickedImage;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate() || _pickedImage == null) return;
    setState(() => _isSaving = true);

    // Create a reference for storing the image in Firebase Storage
    final ref = FirebaseStorage.instance.ref(
      'storeImage/${_nameController.text.trim()}.jpg',
    );
    await ref.putFile(_pickedImage!);
    final imageUrl = await ref.getDownloadURL();

    // Add the new store document to Firestore (Firestore auto-generates the docId)
    final storeRef = await FirebaseFirestore.instance.collection('stores').add({
      'createdAt': Timestamp.now(),
      'description': _descriptionController.text.trim(),
      'hasTrolleyPairing': _hasTrolleyPairing,
      'location': _locationController.text.trim(),
      'name': _nameController.text.trim(),
      'storeImage': imageUrl,
    });

    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Store'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveStore),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              SwitchListTile(
                title: const Text('Has Trolley Pairing'),
                value: _hasTrolleyPairing,
                onChanged: (val) => setState(() => _hasTrolleyPairing = val),
              ),
              const SizedBox(height: 20),
              _pickedImage != null
                  ? Image.file(_pickedImage!, height: 100)
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Store Image'),
                    onPressed: _pickImage,
                  ),
              const SizedBox(height: 20),
              if (_isSaving) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
