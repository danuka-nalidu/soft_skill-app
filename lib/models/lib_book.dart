import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String? id;
  String title;
  String authorName;  // New field for author name
  String pages;       // New field for pages
  String language;    // New field for language
  String releaseDate; // New field for release date
  String category;    // New field for category
  String description;
  double price;
  String pdfUrl;
  String? imageUrl;   // New field for cover image

  Book({
    this.id,
    required this.title,
    required this.authorName,
    required this.pages,
    required this.language,
    required this.releaseDate,
    required this.category,
    required this.description,
    required this.price,
    required this.pdfUrl,
    this.imageUrl,
  });

  factory Book.fromDocument(DocumentSnapshot doc) {
    return Book(
      id: doc.id,
      title: doc['title'],
      authorName: doc['authorName'],  // Added field
      pages: doc['pages'],            // Added field
      language: doc['language'],      // Added field
      releaseDate: doc['releaseDate'],// Added field
      category: doc['category'],      // Added field
      description: doc['description'],
      price: doc['price'].toDouble(),
      pdfUrl: doc['pdfUrl'],
      imageUrl: doc['imageUrl'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'authorName': authorName,   // Added field
      'pages': pages,             // Added field
      'language': language,       // Added field
      'releaseDate': releaseDate, // Added field
      'category': category,       // Added field
      'description': description,
      'price': price,
      'pdfUrl': pdfUrl,
      'imageUrl': imageUrl,
    };
  }
}
