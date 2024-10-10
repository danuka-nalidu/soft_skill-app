import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final void Function()? onTap;

  const CommentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light background color for the button
          shape: BoxShape.circle, // Circular shape for the button
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2), // Shadow for depth
            ),
          ],
        ),
        padding: const EdgeInsets.all(12), // Padding for better touch target
        child:  Icon(
          Icons.comment,
          color: Colors.grey[700], // Darker icon color for contrast
          size: 24, // Increased icon size
        ),
      ),
    );
  }
}
