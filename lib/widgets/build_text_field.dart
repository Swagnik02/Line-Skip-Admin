import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  int maxLines = 1,
  List<TextInputFormatter> inputFormatters = const [],
}) {
  return TextFormField(
    inputFormatters: [...inputFormatters],
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: validator,
    keyboardType: keyboardType,
    maxLines: maxLines,
  );
}

// Helper for consistent TextFormFields
Widget textField({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: TextFormField(
      controller: controller,

      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
