import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:line_skip_admin/models/store_model.dart';
import 'package:line_skip_admin/utils/pick_image.dart';
import 'package:line_skip_admin/widgets/build_text_field.dart';

class AddStorePage extends StatefulWidget {
  final StoreModel? store;
  final bool isEdit;

  const AddStorePage({super.key, this.store, this.isEdit = false});

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      final store = widget.store!;
      _nameController.text = store.name;
      _descriptionController.text = store.description;
      _locationController.text = store.location;
      _upiIdController.text = store.storeUpiId;
      _mobileNumberController.text = store.mobileNumber;
      _ownerNameController.text = store.ownerName;
      _hasTrolleyPairing = store.hasTrolleyPairing;
      _imageUrl = store.storeImage;
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final image = await pickImage(context);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String imageUrl = _imageUrl ?? '';

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

      if (widget.isEdit && widget.store != null) {
        await FirebaseFirestore.instance
            .collection('stores')
            .doc(widget.store!.storeId)
            .update({...baseData, 'storeId': widget.store!.storeId});
        final store = StoreModel(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          hasTrolleyPairing: _hasTrolleyPairing,
          storeImage: imageUrl,
          storeUpiId: _upiIdController.text.trim(),
          mobileNumber: _mobileNumberController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          storeId: widget.store!.storeId,
        );
        Navigator.of(context).pop(store);
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('stores')
            .add(baseData);
        await docRef.update({'storeId': docRef.id});
        Navigator.pop(context);
      }
    } catch (e) {
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
        title: Text(widget.isEdit ? 'Edit Store' : 'Add Store'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveStore),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Store Details"),
              textField(
                controller: _nameController,
                label: 'Store Name',
                icon: Icons.store,
                validator: (v) => v!.isEmpty ? 'Enter store name' : null,
              ),
              textField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
              ),
              textField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 20),
              _sectionTitle("Contact Info"),
              textField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Enter owner name' : null,
              ),
              textField(
                controller: _mobileNumberController,
                label: 'Mobile Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Enter mobile number' : null,
              ),
              textField(
                controller: _upiIdController,
                label: 'Store UPI ID',
                icon: Icons.payment,
                validator: (v) => v!.isEmpty ? 'Enter UPI ID' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle("Trolley & Image"),
              SwitchListTile(
                title: const Text('Has Trolley Pairing'),
                value: _hasTrolleyPairing,
                onChanged: (val) => setState(() => _hasTrolleyPairing = val),
              ),
              const SizedBox(height: 10),
              _buildImageSection(),
              const SizedBox(height: 30),
              if (_isSaving) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageSection() {
    final borderRadius = BorderRadius.circular(12);

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 200,
          color: Colors.grey[200],
          child:
              _pickedImage != null
                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                  : (widget.isEdit && _imageUrl != null
                      ? Image.network(_imageUrl!, fit: BoxFit.cover)
                      : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.image, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
        ),
      ),
    );
  }
}
