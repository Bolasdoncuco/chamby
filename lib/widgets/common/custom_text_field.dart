import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool isWhite;
  final TextInputType keyboardType;
  final Function(String)? onSubmitted;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.isWhite = false,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        obscureText: obscureText,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
          prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey[400]) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
