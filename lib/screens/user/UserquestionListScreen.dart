import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuestionListScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;

  UserQuestionListScreen({required this.courseId, required this.lessonId});

  @override
  _UserQuestionListScreenState createState() => _UserQuestionListScreenState();
}

class _UserQuestionListScreenState extends State<UserQuestionListScreen> {
  @override
  Widget build(BuildContext context) {
    // Validate courseId and lessonId before querying Firestore
    if (widget.courseId.isEmpty || widget.lessonId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Lesson Questions'),
          backgroundColor: Color(0xFF2E5969), // Custom color for app bar
        ),
        body: Center(
          child: Text(
            'Invalid course or lesson ID.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson Questions'),
        backgroundColor: Color(0xFF2E5969), // Custom color for app bar
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('lessons')
            .doc(widget.lessonId)
            .collection('questions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var questions = snapshot.data!.docs;

          if (questions.isEmpty) {
            return Center(
              child: Text(
                'No questions available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var question = questions[index];
              var questionData = question.data() as Map<String, dynamic>?;

              String questionText = questionData != null && questionData.containsKey('question')
                  ? questionData['question']
                  : 'No Question Text';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${index + 1}', // Displaying question number
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          questionText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5969),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
