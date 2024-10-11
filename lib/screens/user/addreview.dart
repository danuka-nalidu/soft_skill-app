import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/review_model.dart';

class AddReviewScreen extends StatefulWidget {
  final String courseId;

  AddReviewScreen({required this.courseId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> addReview(String courseId, ReviewModel review) async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('reviews')
          .add(review.toMap());
    } catch (e) {
      print('Error adding review: $e');
    }
  }



  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty || _rating == 0) {
      // Show error message if fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a review and select a rating.')),
      );
      return;
    }

    // Create a new review model
    final review = ReviewModel(
      userId: '', // Replace with actual user ID
      userName: '', // Replace with actual user name
      reviewText: _reviewController.text,
      rating: _rating,
      timestamp: DateTime.now(),
    );

    // Add review to Firestore
    await addReview(widget.courseId, review);

    // Show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review added successfully!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'Write your review'),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            Text('Rate this course:'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
