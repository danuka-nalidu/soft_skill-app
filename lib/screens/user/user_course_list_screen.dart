import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import 'user_course_detail_screen.dart';

class UserCourseListScreen extends StatefulWidget {
  @override
  _UserCourseListScreenState createState() => _UserCourseListScreenState();
}

class _UserCourseListScreenState extends State<UserCourseListScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future:
            Provider.of<CourseProvider>(context, listen: false).fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading courses'));
          }

          return Consumer<CourseProvider>(
            builder: (context, courseProvider, child) {
              final courses = courseProvider.courses.where((course) {
                return course.title.toLowerCase().contains(_searchTerm);
              }).toList();

              if (courses.isEmpty) {
                return Center(child: Text('No courses available'));
              }

              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];

                  String? imageUrl =
                      course.media.isNotEmpty ? course.media[0] : null;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.image,
                                    size: 40, color: Colors.purple[700]),
                              ),
                      ),
                      title: Text(
                        course.title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 18, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              '${course.tutor}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: Colors.blueAccent),
                            onPressed: () async {
                              await _addCourseToMyCourses(context, course);
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.arrow_forward, color: Colors.blueAccent),
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => UserCourseDetailScreen(course: course),
                          //       ),
                          //     );
                          //   },
                          // ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserCourseDetailScreen(course: course),
                                ),
                              );
                            },
                            child: Text(
                              'View Course',
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ],
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

  Future<void> _addCourseToMyCourses(
      BuildContext context, CourseModel course) async {
    try {
      final myCoursesRef = FirebaseFirestore.instance.collection('myCourses');

      final existingCourse = await myCoursesRef.doc(course.id).get();
      if (existingCourse.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Course already added to My Courses')),
        );
        return;
      }

      await myCoursesRef.doc(course.id).set({
        'id': course.id,
        'title': course.title,
        'tutor': course.tutor,
        'media': course.media,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.title} added to My Courses')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding course to My Courses')),
      );
      print('Error adding course to My Courses: $e');
    }
  }
}
