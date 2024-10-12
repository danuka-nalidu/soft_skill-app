import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uee_project/screens/user/user_course_detail_screen.dart';
import '../../models/course_model.dart';

class MyCoursesPage extends StatefulWidget {
  @override
  _MyCoursesPageState createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'Saved'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSavedCoursesList(), // Saved courses
          _buildCoursesWithProgress(), // In-progress courses
          _buildCoursesCompleted(), // Completed courses
        ],
      ),
    );
  }

  // Updated function to build the grid view of saved courses
  Widget _buildSavedCoursesList() {
    final savedCoursesStream = FirebaseFirestore.instance
        .collection('myCourses') // Fetch saved courses without user-specific
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: savedCoursesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No saved courses.'));
        }

        final courses = snapshot.data!.docs.map((doc) {
          return CourseModel.fromFirestore(doc);
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display 2 courses per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7, // Adjust this ratio for controlling height
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseCardForSavedTab(
                course); // Build the saved tab card
          },
        );
      },
    );
  }

  // Function to build the course card for the saved tab
  Widget _buildCourseCardForSavedTab(CourseModel course) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: course.media.isNotEmpty
                ? Image.network(
                    course.media[0],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 140,
                    color: Colors.purple[100],
                    child:
                        Icon(Icons.image, size: 50, color: Colors.purple[700]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              course.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'By ${course.tutor}',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Instead of Spacer(), use Expanded to make it adjust based on content
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserCourseDetailScreen(course: course),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward, size: 16),
                  label: Text('View', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the list of in-progress courses with progress percentage
  Widget _buildCoursesWithProgress() {
    final courseStream =
        FirebaseFirestore.instance.collection('courses').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: courseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No in-progress courses.'));
        }

        final courses = snapshot.data!.docs.map((doc) {
          return CourseModel.fromFirestore(doc);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(course.id)
                  .collection('lessons')
                  .get(),
              builder: (context, lessonSnapshot) {
                if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!lessonSnapshot.hasData ||
                    lessonSnapshot.data!.docs.isEmpty) {
                  return Container(); // No lessons, don't show the course
                }

                // Fetch total lessons and count completed lessons
                final totalLessons = lessonSnapshot.data!.docs.length;
                final completedLessons = lessonSnapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data.containsKey('isCompleted') &&
                      data['isCompleted'] == true;
                }).length;

                // Show the course if it's in progress (i.e., not all lessons are completed)
                if (completedLessons > 0 && completedLessons < totalLessons) {
                  // Calculate progress percentage
                  final progress = totalLessons > 0
                      ? (completedLessons / totalLessons) * 100
                      : 0;

                  // Show the course with progress bar
                  return _buildCourseCardWithProgress(
                      course, progress.toDouble()); // Ensure progress is double
                }

                // If all lessons are completed, don't show this course in the "In Progress" tab
                return Container();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCourseCardWithProgress(CourseModel course, double progress) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: course.media.isNotEmpty
              ? Image.network(
                  course.media[0],
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
                  child: Icon(Icons.image, size: 40, color: Colors.purple[700]),
                ),
        ),
        title: Text(
          course.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'By ${course.tutor}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Only show progress bar if progress is less than 100%
            if (progress < 100) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress /
                          100, // Progress should be between 0.0 and 1.0
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                      '${progress.toStringAsFixed(1)}% completed'), // Show percentage as text
                ],
              ),
            ] else ...[
              // Display "Completed" if 100% progress
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Course Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserCourseDetailScreen(course: course),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoursesCompleted() {
    final courseStream =
        FirebaseFirestore.instance.collection('courses').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: courseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No completed courses.'));
        }

        final courses = snapshot.data!.docs.map((doc) {
          return CourseModel.fromFirestore(doc);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(course.id)
                  .collection('lessons')
                  .get(),
              builder: (context, lessonSnapshot) {
                if (lessonSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!lessonSnapshot.hasData ||
                    lessonSnapshot.data!.docs.isEmpty) {
                  return Container(); // No lessons, don't show the course
                }

                // Fetch total lessons and count completed lessons
                final totalLessons = lessonSnapshot.data!.docs.length;
                final completedLessons = lessonSnapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data.containsKey('isCompleted') &&
                      data['isCompleted'] == true;
                }).length;

                // Only show course if all lessons are completed
                if (completedLessons == totalLessons) {
                  return _buildCourseCardWithProgress(
                      course, 100); // 100% completed
                }

                // If not all lessons are completed, don't show this course
                return Container();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: course.media.isNotEmpty
              ? Image.network(
                  course.media[0],
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
                  child: Icon(Icons.image, size: 40, color: Colors.purple[700]),
                ),
        ),
        title: Text(
          course.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.person, size: 18, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'By ${course.tutor}',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black54),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserCourseDetailScreen(course: course),
              ),
            );
          },
        ),
      ),
    );
  }
}
