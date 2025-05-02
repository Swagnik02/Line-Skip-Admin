import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_skip_admin/models/item_model.dart';
import 'package:line_skip_admin/utils/barcode_generator.dart';
import 'package:line_skip_admin/utils/barcode_scanner.dart';
import 'package:line_skip_admin/utils/pick_image.dart';
import 'package:line_skip_admin/widgets/build_text_field.dart';

class AddItemPage extends StatefulWidget {
  final String? storeId;
  final ItemModel? item;
  final bool isEdit;

  const AddItemPage({super.key, this.storeId, this.item, this.isEdit = false});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  late Future<Uint8List> barcodeImageFuture;
  File? _pickedImage;
  late bool _isEdit;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.isEdit;

    final item = widget.item;
    if (_isEdit && item != null) {
      _barcodeController.text = item.barcode;
      _nameController.text = item.name;
      _brandController.text = item.brandName;
      _priceController.text = item.price.toString();
      _weightController.text = item.weight.toString();
      _imageUrlController.text = item.imageUrl;
      _categoryController.text = item.category;
      _descriptionController.text = item.description ?? '';

      barcodeImageFuture = getBarcodeImage(item.barcode);
    } else {
      barcodeImageFuture = Future.value(Uint8List(0));
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final image = await pickImage(context);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final item = ItemModel(
      barcode: _barcodeController.text,
      name: _nameController.text,
      brandName: _brandController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      imageUrl: _imageUrlController.text,
      category: _categoryController.text,
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      storeId: _isEdit ? widget.item!.storeId : widget.storeId ?? '',
    );

    if (_pickedImage != null) {
      final imageUrl = await getImageLink(
        _pickedImage!,
        'itemImage',
        item.barcode,
      );

      if (imageUrl == null) {
        _showSnackBar('Image upload failed');
        return;
      }

      item.imageUrl = imageUrl;
    }

    try {
      await addItem(item);
      _showSnackBar(
        _isEdit ? 'Item Updated Successfully' : 'Item Added Successfully',
      );
      _isEdit ? Navigator.of(context).pop(item) : Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Failed to save item: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Item' : 'Add Item')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: Icon(Icons.check_circle_rounded),
        label: Text(_isEdit ? 'Update' : 'Add'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Product Info'),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                      keyboardType: TextInputType.number,
                      controller: _barcodeController,
                      label: 'Barcode',
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter barcode'
                                  : null,
                    ),
                  ),

                  IconButton(
                    icon: Transform.rotate(
                      angle: 90 * pi / 180,
                      child: const Icon(Icons.document_scanner_outlined),
                    ),
                    onPressed: () async {
                      final barcode = await scanBarcode(context);
                      if (barcode.isNotEmpty) {
                        _barcodeController.text = barcode;
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),
              buildTextField(
                controller: _nameController,
                label: 'Item Name',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              buildTextField(
                controller: _brandController,
                label: 'Brand Name',
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter brand' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d{0,2})?'),
                        ),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      controller: _priceController,
                      label: 'Price',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        }
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildTextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d{0,2})?'),
                        ),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      controller: _weightController,
                      label: 'Weight',

                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter weight';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Image'),
              const SizedBox(height: 8),
              _buildImageSection(),
              const SizedBox(height: 20),
              _buildSectionTitle('Category & Description'),
              buildTextField(
                controller: _categoryController,
                label: 'Category',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter category'
                            : null,
              ),
              const SizedBox(height: 12),
              buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 80), // space for floating button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
                  : (_isEdit
                      ? Image.network(widget.item!.imageUrl, fit: BoxFit.cover)
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
