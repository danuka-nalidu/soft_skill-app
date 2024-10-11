import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final String userName;
  final String reviewText;
  final int rating; // Rating out of 5
  final DateTime timestamp;

  ReviewModel({
    required this.userId,
    required this.userName,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
  });

  // Convert a ReviewModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': timestamp,
    };
  }

  // Create a ReviewModel instance from Firestore data
  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    return ReviewModel(
      userId: data['userId'],
      userName: data['userName'],
      reviewText: data['reviewText'],
      rating: data['rating'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
