import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String tutor;
  final List<String> media; // List of media URLs
  final List<String> files; // List of file URLs (e.g., PDFs)

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.tutor,
    this.media = const [],
    this.files = const [],
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? '',
      tutor: data['tutor'] ?? '',
      media: List<String>.from(data['media'] ?? []),
      files: List<String>.from(data['files'] ?? []),
    );
  }
}
