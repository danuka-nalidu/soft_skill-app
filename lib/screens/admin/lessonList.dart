import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uee_project/screens/admin/questionListScreen.dart';
import '../../models/course_model.dart';
import 'add_lesson_screen.dart';
import 'add_question.dart';


class LessonListScreen extends StatelessWidget {
  final CourseModel course;

  LessonListScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${course.title} Lessons'),
        backgroundColor: Color(0xFF2E5969),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(course.id)
            .collection('lessons')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var lessons = snapshot.data!.docs;

          if (lessons.isEmpty) {
            return Center(child: Text('No lessons available.'));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              var lesson = lessons[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    lesson['title'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Duration: ${lesson['duration'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // Navigate to edit lesson screen with lessonId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddLessonScreen(
                                course: course,
                                lessonId: lesson.id, // Pass the lessonId for editing
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _confirmDeleteLesson(context, course.id, lesson.id);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'add_question') {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddQuestionsScreen(
                                  courseId: course.id,
                                  lessonId: lesson.id,
                                ),
                              ),
                            );
                          } else if (value == 'view_questions') {
                            // Navigate to view questions for the lesson
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionListScreen(
                                  courseId: course.id,
                                  lessonId: lesson.id,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'add_question',
                            child: Text('Add Question'),
                          ),
                          PopupMenuItem(
                            value: 'view_questions',
                            child: Text('View Questions'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddLessonScreen(course: course),
            ),
          );
        },
        backgroundColor: Color(0xFF2E5969),
        child: Icon(Icons.add),
      ),
    );
  }


  void _confirmDeleteLesson(BuildContext context, String courseId, String lessonId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Lesson'),
        content: Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteLesson(courseId, lessonId);
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


  Future<void> _deleteLesson(String courseId, String lessonId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }
}

