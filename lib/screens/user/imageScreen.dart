import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  FullScreenImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    bool isLocalFile = imageUrl.startsWith('/data') || imageUrl.startsWith('file://');

    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Center(
        child: isLocalFile
            ? Image.file(File(imageUrl)) // Load image from local file
            : Image.network(imageUrl), // Load image from network URL
      ),
    );
  }
}
