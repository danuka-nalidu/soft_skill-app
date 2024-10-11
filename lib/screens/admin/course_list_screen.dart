import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart'; // Import CourseProvider
import 'add_lesson_screen.dart';
import 'lessonList.dart'; // Import LessonListScreen
import 'update_course_screen.dart';
import '../../models/course_model.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening file URLs
import '../user/user_course_list_screen.dart'; // Import UserCourseListScreen

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<void> _fetchCoursesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch courses when the screen initializes
    _fetchCoursesFuture = Provider.of<CourseProvider>(context, listen: false).fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Course List'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.switch_account),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => UserCourseListScreen()),
          //     );
          //   },
          //   tooltip: 'Go to User Courses',
          // ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchCoursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading courses'));
          }

          return Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              if (courseProvider.courses.isEmpty) {
                return Center(child: Text('No courses available'));
              }

              return ListView.builder(
                itemCount: courseProvider.courses.length,
                itemBuilder: (context, index) {
                  final course = courseProvider.courses[index];
                  String? imageUrl = course.media.isNotEmpty ? course.media[0] : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonListScreen(course: course),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
                              ),
                            SizedBox(height: 10),
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              course.description,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Category: ${course.category}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Duration: ${course.duration}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tutor: ${course.tutor}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            if (course.files.isNotEmpty) ...[
                              Text(
                                'Document Files:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: course.files.map((fileUrl) {
                                  return ListTile(
                                    leading: Icon(Icons.insert_drive_file),
                                    title: Text('File: ${fileUrl.split('/').last}'),
                                    onTap: () => _openFile(fileUrl),
                                  );
                                }).toList(),
                              ),
                            ],
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateCourseScreen(
                                          course: course,
                                          index: index,
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    bool confirm = await _confirmDelete(context);
                                    if (confirm) {
                                      await Provider.of<CourseProvider>(context, listen: false)
                                          .deleteCourse(index);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Course deleted successfully')),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _openFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
