import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uee_project/screens/user/UserquestionListScreen.dart';
import 'package:uee_project/screens/user/pdfView.dart';
import 'package:uee_project/screens/user/videoPlayScreen.dart';
import 'package:open_file/open_file.dart';
import '../../models/course_model.dart';
import '../../models/review_model.dart';
import 'addreview.dart';
import 'imageScreen.dart';
import 'my_course_screen.dart';

class UserCourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  UserCourseDetailScreen({required this.course});

  @override
  _UserCourseDetailScreenState createState() => _UserCourseDetailScreenState();
}

class _UserCourseDetailScreenState extends State<UserCourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> lessons = [];
  List<bool> lessonCompletionStatus = [];
  int lastCompletedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getLessonsStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch lessons from Firestore and track completion status
  Stream<List<Map<String, dynamic>>> _getLessonsStream() {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
        .collection('lessons')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
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

  Stream<List<ReviewModel>> _getReviewsStream(String courseId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ReviewModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Course Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (course.media.isNotEmpty)
                  Image.network(
                    course.media[0],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Lessons'),
                    Tab(text: 'Reviews'),
                  ],
                ),
                Container(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(course),
                      _buildLessonsList(context),
                      _buildReviewsTab(course.id),
                      Center(child: Text('Reviews Content Here')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double
                  .infinity, // Increase the width to take the full available width
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyCoursesPage()),
                  );
                },
                icon: Icon(Icons.school, color: Colors.white),
                label: Text(
                  'Go to My Courses',
                  style:
                      TextStyle(color: Colors.white), // Text color set to white
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Applied border radius of 12
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewsTab(String courseId) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ReviewModel>>(
            stream: _getReviewsStream(courseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading reviews.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No reviews yet.'));
              } else {
                final reviews = snapshot.data!;
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(review.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.reviewText),
                            SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                            Text(
                              'Reviewed on: ${review.timestamp}',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddReviewScreen(courseId: courseId)),
              );
            },
            icon: Icon(Icons.rate_review, color: Colors.white),
            label: Text(
              'Add Review',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(CourseModel course) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                // Course Title Section in its own card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 22, color: Colors.blueGrey),
                            SizedBox(width: 8),
                            Text(
                              course.tutor,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.play_circle_fill,
                                size: 24, color: Colors.orangeAccent),
                            SizedBox(width: 8),
                            Icon(Icons.verified, size: 24, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              'Certificate',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course Description",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: StreamBuilder<List<ReviewModel>>(
                      stream: _getReviewsStream(course.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error loading ratings.');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('No ratings yet.');
                        } else {
                          final reviews = snapshot.data!;
                          final totalReviews = reviews.length;
                          final averageRating = reviews
                                  .map((review) => review.rating)
                                  .reduce((a, b) => a + b) /
                              totalReviews;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ratings & Reviews',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  // Display average rating
                                  Text(
                                    '${averageRating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Display stars based on average rating
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < averageRating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 24,
                                      );
                                    }),
                                  ),
                                  Spacer(),
                                  // Total number of reviews
                                  Text(
                                    '$totalReviews reviews',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonsList(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getLessonsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading lessons.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No lessons available.'));
        } else {
          final lessons = snapshot.data!;
          int firstIncompleteIndex =
              lessons.indexWhere((lesson) => !(lesson['isCompleted'] ?? false));

          // If all lessons are completed, just show the completed lessons
          if (firstIncompleteIndex == -1) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                return _buildLessonCard(context, index, lessons[index],
                    lessons[index]['isCompleted'] ?? false);
              },
            );
          }

          // Show all completed lessons and only the first incomplete lesson
          return ListView.builder(
            shrinkWrap: true,
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              if (lessons[index]['isCompleted'] ||
                  index == firstIncompleteIndex) {
                return _buildLessonCard(context, index, lessons[index],
                    lessons[index]['isCompleted'] ?? false);
              }
              return Container();
            },
          );
        }
      },
    );
  }

  Widget _buildLessonCard(BuildContext context, int index,
      Map<String, dynamic> lesson, bool isCompleted) {
    final lessonId = lesson['id'];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Title with completion status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lesson['title'] ?? 'Lesson Title',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),

            // Lesson Duration
            Row(
              children: [
                Icon(Icons.timer, size: 18, color: Colors.blueGrey),
                SizedBox(width: 4),
                Text(
                  'Duration: ${lesson['duration'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Media Links (if available)
            _buildMediaLinks(lesson['media']),
            SizedBox(height: 8),

            // File Links (if available)
            _buildFileLinks(lesson['files']),

            // Action Buttons (View Questions & Next)
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserQuestionListScreen(
                          courseId: widget.course.id,
                          lessonId: lessonId,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.question_answer),
                  label: Text('View Questions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isCompleted
                      ? null
                      : () async {
                          await _markLessonAsCompleted(index, lessonId);
                        },
                  icon: Icon(isCompleted ? Icons.check : Icons.arrow_forward),
                  label: Text(isCompleted ? 'Completed' : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCompleted ? Colors.grey : Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markLessonAsCompleted(int index, String lessonId) async {
    try {
      // Mark the lesson as completed in Firestore
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .collection('lessons')
          .doc(lessonId)
          .update({'isCompleted': true});

      setState(() {
        // Mark the lesson as completed in the local state
        lessonCompletionStatus[index] = true;
      });
    } catch (error) {
      print('Error updating lesson: $error');
    }
  }

  Widget _buildMediaLinks(List<dynamic>? media) {
    if (media == null || media.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No media available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(media.length, (index) {
        String mediaUrl = media[index];
        return GestureDetector(
          onTap: () {
            if (mediaUrl.endsWith('.jpg') ||
                mediaUrl.endsWith('.png') ||
                mediaUrl.endsWith('.jpeg')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImageScreen(imageUrl: mediaUrl)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.link, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text(
                  'Media Link ${index + 1}',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

// Helper to display file links
  Widget _buildFileLinks(List<dynamic>? files) {
    if (files == null || files.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No files available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(files.length, (index) {
        String fileUrl = files[index];
        return GestureDetector(
          onTap: () {
            if (fileUrl.endsWith('.pdf')) {
              // Navigate to PDFViewerScreen if it's a PDF file
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(pdfUrl: fileUrl),
                ),
              );
            } else if (fileUrl.endsWith('.mp4')) {
              // Navigate to VideoPlayerScreen if it's an MP4 file
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoUrl: fileUrl),
                ),
              );
            } else {
              _openFile(fileUrl); // Handle other file types
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                    fileUrl.endsWith('.pdf')
                        ? Icons.picture_as_pdf
                        : fileUrl.endsWith('.mp4')
                            ? Icons.videocam
                            : Icons.insert_drive_file,
                    color: Colors.blue,
                    size: 18),
                SizedBox(width: 8),
                Text(
                  fileUrl.endsWith('.pdf')
                      ? 'PDF Link ${index + 1}'
                      : fileUrl.endsWith('.mp4')
                          ? 'Video Link ${index + 1}'
                          : 'File Link ${index + 1}',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _openFile(String fileUrl) async {
    final result = await OpenFile.open(fileUrl);
    if (result.type == ResultType.error) {
      print('Error opening file: ${result.message}');
    }
  }
}
