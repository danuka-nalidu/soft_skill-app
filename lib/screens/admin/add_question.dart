// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddQuestionsScreen extends StatefulWidget {
//   final String courseId;
//   final String lessonId;
//   final String? questionId;
//
//   AddQuestionsScreen({required this.courseId, required this.lessonId, this.questionId});
//
//   @override
//   _AddQuestionsScreenState createState() => _AddQuestionsScreenState();
// }
//
// class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
//   List<TextEditingController> _questionControllers = [];
//   List<String> _questions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _addQuestionField();
//   }
//
//
//   void _addQuestionField() {
//     setState(() {
//       _questionControllers.add(TextEditingController());
//     });
//   }
//
//
//   void _removeQuestionField(int index) {
//     setState(() {
//       _questionControllers.removeAt(index);
//     });
//   }
//
//
//   Future<void> _saveQuestions() async {
//     for (var controller in _questionControllers) {
//       _questions.add(controller.text);
//     }
//
//     CollectionReference questionsRef = FirebaseFirestore.instance
//         .collection('courses')
//         .doc(widget.courseId)
//         .collection('lessons')
//         .doc(widget.lessonId)
//         .collection('questions');
//
//     for (var question in _questions) {
//       await questionsRef.add({
//         'question': question,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Questions added successfully!')),
//     );
//
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _questionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Questions to Lesson'),
//         backgroundColor: Color(0xFF2E5969),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _questionControllers.length,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _questionControllers[index],
//                           decoration: InputDecoration(
//                             labelText: 'Question ${index + 1}',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                           _removeQuestionField(index);
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton.icon(
//                   icon: Icon(Icons.add),
//                   label: Text('Add More Questions'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF2E5969),
//                   ),
//                   onPressed: _addQuestionField,
//                 ),
//                 ElevatedButton(
//                   child: Text('Save Questions'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   onPressed: _saveQuestions,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String courseId;
  final String lessonId;
  final String? questionId; // If this is passed, it's edit mode

  AddQuestionsScreen({required this.courseId, required this.lessonId, this.questionId});

  @override
  _AddQuestionsScreenState createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  List<TextEditingController> _questionControllers = [];
  bool _isEditMode = false; // To track whether it's edit mode
  bool _isLoading = false; // To show a loading indicator when fetching data

  @override
  void initState() {
    super.initState();
    // If there's a questionId, it's edit mode
    if (widget.questionId != null) {
      _isEditMode = true;
      _loadExistingQuestions();
    } else {
      _addQuestionField(); // Add an empty field for a new question
    }
  }

  // Load existing question data for edit mode
  Future<void> _loadExistingQuestions() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot questionSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('lessons')
        .doc(widget.lessonId)
        .collection('questions')
        .doc(widget.questionId)
        .get();

    if (questionSnapshot.exists) {
      var questionData = questionSnapshot.data() as Map<String, dynamic>;
      setState(() {
        // Load existing question text into the controller
        _questionControllers.add(TextEditingController(text: questionData['question'] ?? ''));
        _isLoading = false;
      });
    }
  }

  // Add a new question field
  void _addQuestionField() {
    setState(() {
      _questionControllers.add(TextEditingController());
    });
  }

  // Remove a question field
  void _removeQuestionField(int index) {
    setState(() {
      if (_questionControllers.length > 1) {
        _questionControllers.removeAt(index);
      }
    });
  }

  // Save questions to Firestore
  Future<void> _saveQuestions() async {
    CollectionReference questionsRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('lessons')
        .doc(widget.lessonId)
        .collection('questions');

    for (var controller in _questionControllers) {
      if (controller.text.isNotEmpty) {
        var questionData = {
          'question': controller.text,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // If it's edit mode, update the existing question
        if (_isEditMode && widget.questionId != null) {
          await questionsRef.doc(widget.questionId).update(questionData);
        } else {
          // Otherwise, add a new question
          await questionsRef.add(questionData);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditMode ? 'Question updated successfully!' : 'Questions added successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionId == null ? 'Add Questions' : 'Edit Question'),
        backgroundColor: Color(0xFF2E5969),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questionControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Question ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeQuestionField(index);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add More Questions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E5969),
                  ),
                  onPressed: _addQuestionField,
                ),
                ElevatedButton(
                  child: Text(_isEditMode ? 'Update Question' : 'Save Questions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _saveQuestions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

