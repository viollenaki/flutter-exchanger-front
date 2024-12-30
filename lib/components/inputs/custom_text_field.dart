import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters; // Add this line

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: inputFormatters ?? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))], // Modify this line
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}