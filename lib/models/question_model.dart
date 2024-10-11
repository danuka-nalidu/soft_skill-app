import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String questionText;
  final DateTime createdAt;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.createdAt,
  });

  // Convert a Firestore document to a QuestionModel
  factory QuestionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return QuestionModel(
      id: id,
      questionText: data['question'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert a QuestionModel to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'question': questionText,
      'createdAt': createdAt,
    };
  }
}
