import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;

  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1), // Light red background
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8), // Padding around the icon
        child: const Icon(
          Icons.cancel,
          color: Colors.red, // Icon color
        ),
      ),
    );
  }
}
