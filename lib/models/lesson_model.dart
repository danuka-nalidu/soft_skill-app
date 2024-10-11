import 'package:cloud_firestore/cloud_firestore.dart';

class LessonModel {
  final String id;
  final String title;
  final String content;
  final String duration;
  final List<String> media;
  final List<String> files;
  final bool isCompleted;

  LessonModel({
    required this.id,
    required this.title,
    required this.content,
    required this.duration,
    this.media = const [],
    this.files = const [],
    this.isCompleted = false,
  });


  factory LessonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      duration: data['duration'] ?? '',
      media: List<String>.from(data['media'] ?? []),
      files: List<String>.from(data['files'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}
