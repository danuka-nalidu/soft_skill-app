import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/lib_book.dart';
import '../services/firebase_service.dart';

class EditBookPage extends StatefulWidget {
  final Book book;

  EditBookPage({required this.book});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String authorName;
  late String pages;
  late String language;
  late String releaseDate;
  late String description;
  late String category;
  late double price;
  File? pdfFile;
  File? imageFile;
  late String pdfUrl;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    title = widget.book.title;
    authorName = widget.book.authorName;
    pages = widget.book.pages;
    language = widget.book.language;
    releaseDate = widget.book.releaseDate;
    description = widget.book.description;
    category = widget.book.category;
    price = widget.book.price;
    pdfUrl = widget.book.pdfUrl;
    imageUrl = widget.book.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
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
                initialValue: title,
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
                initialValue: authorName,
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
                initialValue: pages,
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
                initialValue: language,
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
                initialValue: releaseDate,
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
                value: category,
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
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a category' : null,
                onSaved: (value) => category = value!,
              ),
              SizedBox(height: 16.0),
              // Description Field
              TextFormField(
                initialValue: description,
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
              // Price Field
              TextFormField(
                initialValue: price.toString(),
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFcedbfd), // TextField color
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the price' : null,
                onSaved: (value) => price = double.parse(value!),
              ),
              SizedBox(height: 16.0),
              // Image Picker
              ElevatedButton.icon(
                onPressed: pickImageFile,
                icon: Icon(Icons.image),
                label: Text(
                    imageFile == null ? 'Pick New Cover Image' : 'Image Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07274d), // Button color
                ),
              ),
              SizedBox(height: 8.0),
              // PDF Picker
              ElevatedButton.icon(
                onPressed: pickPdfFile,
                icon: Icon(Icons.picture_as_pdf),
                label: Text(pdfFile == null ? 'Pick New PDF File' : 'PDF Selected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07274d), // Button color
                ),
              ),
              SizedBox(height: 24.0),
              // Submit Button
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Update Book'),
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (pdfFile != null) {
        pdfUrl = await firebaseService.uploadPdf(pdfFile!);
      }
      if (imageFile != null) {
        imageUrl = await firebaseService.uploadImage(imageFile!);
      }
      Book updatedBook = Book(
        id: widget.book.id,
        title: title,
        authorName: authorName,
        pages: pages,
        language: language,
        releaseDate: releaseDate,
        category: category,
        description: description,
        price: price,
        pdfUrl: pdfUrl,
        imageUrl: imageUrl,
      );
      await firebaseService.updateBook(updatedBook);
      Navigator.pop(context);
    }
  }
}