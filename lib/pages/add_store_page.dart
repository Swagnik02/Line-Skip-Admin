import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_skip_admin/models/store_model.dart';

class AddStorePage extends StatefulWidget {
  final String? storeId;
  final bool isEdit;
  final bool isView;

  const AddStorePage({
    super.key,
    this.storeId,
    this.isEdit = false,
    this.isView = false,
  });

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
  String? _imageUrl;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.storeId != null) _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    setState(() => _isLoading = true);
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('stores')
              .doc(widget.storeId)
              .get();

      if (doc.exists) {
        final store = StoreModel.fromFirestore(doc);
        _nameController.text = store.name;
        _descriptionController.text = store.description;
        _locationController.text = store.location;
        _upiIdController.text = store.storeUpiId;
        _mobileNumberController.text = store.mobileNumber;
        _ownerNameController.text = store.ownerName;
        _hasTrolleyPairing = store.hasTrolleyPairing;
        _imageUrl = store.storeImage;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching store: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    if (widget.isView) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String imageUrl = _imageUrl ?? '';

      // Upload image if picked
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance.ref(
          'storeImage/${_nameController.text.trim()}.jpg',
        );
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final baseData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'hasTrolleyPairing': _hasTrolleyPairing,
        'storeImage': imageUrl,
        'storeUpiId': _upiIdController.text.trim(),
        'mobileNumber': _mobileNumberController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'createdAt': Timestamp.now(),
      };

      if (widget.isEdit && widget.storeId != null) {
        // Update existing document and include storeId if needed
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.storeId)
            .update({...baseData, 'storeId': widget.storeId});
      } else {
        // Add new document and get the doc reference
        final docRef = await FirebaseFirestore.instance
            .collection('stores')
            .add(baseData);

        // Then update it with storeId field
        await docRef.update({'storeId': docRef.id});
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save store: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool get _isView => widget.isView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? 'Edit Store'
              : _isView
              ? 'View Store'
              : 'Add Store',
        ),
        actions: [
          if (!_isView)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveStore),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Store Name',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter store name' : null,
                        enabled: !_isView,
                      ),
                      TextFormField(
                        controller: _ownerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter owner name' : null,
                        enabled: !_isView,
                      ),
                      TextFormField(
                        controller: _mobileNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                        ),
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter mobile number' : null,
                        enabled: !_isView,
                      ),
                      TextFormField(
                        controller: _upiIdController,
                        decoration: const InputDecoration(
                          labelText: 'Store UPI ID',
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Enter UPI ID' : null,
                        enabled: !_isView,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        enabled: !_isView,
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                        enabled: !_isView,
                      ),
                      SwitchListTile(
                        title: const Text('Has Trolley Pairing'),
                        value: _hasTrolleyPairing,
                        onChanged:
                            _isView
                                ? null
                                : (val) =>
                                    setState(() => _hasTrolleyPairing = val),
                      ),
                      const SizedBox(height: 20),
                      if (_pickedImage != null)
                        Image.file(_pickedImage!, height: 450)
                      else if (_imageUrl != null)
                        Image.network(_imageUrl!, height: 450)
                      else if (!_isView)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Pick Store Image'),
                          onPressed: _pickImage,
                        ),
                      const SizedBox(height: 20),
                      if (_isSaving)
                        const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
    );
  }
}
