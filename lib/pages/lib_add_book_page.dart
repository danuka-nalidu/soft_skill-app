import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lib_book.dart';
import '../services/firebase_service.dart';

class AddBookPage extends StatefulWidget {
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String authorName = '';
  String pages = '';
  String language = '';
  String releaseDate = '';
  String description = '';
  String category = '';
  File? pdfFile;
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
        backgroundColor: Color(0xFF4c88d0), // Primary color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the title' : null,
                onSaved: (value) => title = value!,
              ),
              SizedBox(height: 16.0),
              // Author Name Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Authors Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the author name' : null,
                onSaved: (value) => authorName = value!,
              ),
              SizedBox(height: 16.0),
              // Pages Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Pages',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the number of pages' : null,
                onSaved: (value) => pages = value!,
              ),
              SizedBox(height: 16.0),
              // Language Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the language' : null,
                onSaved: (value) => language = value!,
              ),
              SizedBox(height: 16.0),
              // Release Date Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Release Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the release date' : null,
                onSaved: (value) => releaseDate = value!,
              ),
              SizedBox(height: 16.0),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: category.isNotEmpty ? category : null,
                items: ['Fiction', 'Non-Fiction', 'Science', 'History']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a category' : null,
                onSaved: (value) => category = value!,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
              ),
              SizedBox(height: 16.0),
              // Description Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the description' : null,
                onSaved: (value) => description = value!,
              ),
              SizedBox(height: 16.0),
              // Image Picker
              ElevatedButton.icon(
                onPressed: pickImageFile,
                icon: Icon(Icons.image),
                label: Text(imageFile == null
                    ? 'Upload Cover Image'
                    : 'Image Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07274d), // Button color
                ),
              ),
              SizedBox(height: 8.0),
              // PDF Picker
              ElevatedButton.icon(
                onPressed: pickPdfFile,
                icon: Icon(Icons.picture_as_pdf),
                label: Text(
                    pdfFile == null ? 'Upload PDF File' : 'PDF Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07274d), // Button color
                ),
              ),
              SizedBox(height: 24.0),
              // Submit Button
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Add'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Color(0xFF07274d), // Button color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        pdfFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> pickImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() && pdfFile != null) {
      _formKey.currentState!.save();

      // Upload the selected files to Firebase
      String pdfUrl = await firebaseService.uploadPdf(pdfFile!);
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await firebaseService.uploadImage(imageFile!);
      }

      // Create the Book object
      Book book = Book(
        title: title,
        authorName: authorName,
        pages: pages,
        language: language,
        releaseDate: releaseDate,
        category: category,
        description: description,
        price: 0.0, // You can update this field later if needed
        pdfUrl: pdfUrl,
        imageUrl: imageUrl,
      );

      // Save the book to Firebase
      await firebaseService.addBook(book);

      // Go back to the previous screen
      Navigator.pop(context);
    } else if (pdfFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a PDF file')),
      );
    }
  }
}
