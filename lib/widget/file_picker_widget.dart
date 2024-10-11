import 'package:flutter/material.dart';

class FilePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text('Drop Your Files Here'),
      ),
    );
  }
}
