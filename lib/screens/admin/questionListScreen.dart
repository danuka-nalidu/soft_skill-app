import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_question.dart';

class QuestionListScreen extends StatelessWidget {
  final String courseId;
  final String lessonId;


  QuestionListScreen({required this.courseId, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions for Lesson'),
        backgroundColor: Color(0xFF2E5969),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .collection('questions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var questions = snapshot.data!.docs;

          if (questions.isEmpty) {
            return Center(child: Text('No questions available.'));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              var question = questions[index];
              var questionData = question.data() as Map<String, dynamic>?;

              String questionText = questionData != null && questionData.containsKey('question')
                  ? questionData['question']
                  : 'No Question Text';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    questionText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to edit question screen (not provided)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddQuestionsScreen(
                                courseId: courseId,
                                lessonId: lessonId,
                                questionId: question.id,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDeleteQuestion(context, courseId, lessonId, question.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteQuestion(BuildContext context, String courseId, String lessonId, String questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Question'),
        content: Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteQuestion(courseId, lessonId, questionId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuestion(String courseId, String lessonId, String questionId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }
}
