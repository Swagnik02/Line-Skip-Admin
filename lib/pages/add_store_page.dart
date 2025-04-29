import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _upiIdController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
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

    try {
      // Upload image to Firebase Storage
      final ref = FirebaseStorage.instance.ref(
        'storeImage/${_nameController.text.trim()}.jpg',
      );
      await ref.putFile(_pickedImage!);
      final imageUrl = await ref.getDownloadURL();

      // Add store data to Firestore
      await FirebaseFirestore.instance.collection('stores').add({
        'createdAt': Timestamp.now(),
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'hasTrolleyPairing': _hasTrolleyPairing,
        'storeImage': imageUrl,
        'storeUpiId': _upiIdController.text.trim(),
        'mobileNumber': _mobileNumberController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
      });

      Navigator.pop(context);
    } catch (e) {
      // Handle any error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save store: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
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
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter store name' : null,
              ),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter owner name' : null,
              ),
              TextFormField(
                controller: _mobileNumberController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) => value!.isEmpty ? 'Enter mobile number' : null,
              ),
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(labelText: 'Store UPI ID'),
                validator: (value) => value!.isEmpty ? 'Enter UPI ID' : null,
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
