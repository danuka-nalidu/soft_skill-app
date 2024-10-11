import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';
import 'lessonList.dart';

class AddLessonScreen extends StatefulWidget {
  final CourseModel course;
  final String? lessonId; // Optional lessonId for edit mode

  AddLessonScreen({required this.course, this.lessonId});

  @override
  _AddLessonScreenState createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  String _duration = '';
  List<String> _media = [];
  List<String> _files = [];
  List<String> _durationOptions = ['15 min', '30 min', '45 min', '1 hour'];

  bool _isEditMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.lessonId != null) {
      _isEditMode = true;
      _loadLessonData();
    } else {
      _isLoading = false;
    }
  }


  Future<void> _loadLessonData() async {
    DocumentSnapshot lessonSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
        .collection('lessons')
        .doc(widget.lessonId)
        .get();

    if (lessonSnapshot.exists) {
      setState(() {
        _title = lessonSnapshot['title'] ?? '';
        _content = lessonSnapshot['content'] ?? '';
        _duration = lessonSnapshot['duration'] ?? '';
        _media = List<String>.from(lessonSnapshot['media'] ?? []);
        _files = List<String>.from(lessonSnapshot['files'] ?? []);
        _isLoading = false;  // Mark loading as done
      });
    }
  }


  void _deleteMedia(int index) {
    setState(() {
      _media.removeAt(index);
    });
  }

  void _deleteFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _selectMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _media.add(image.path);
      });
    }
  }

  void _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _files = result.paths!.cast<String>();
      });
    }
  }

  Future<void> _saveLesson() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      var lessonData = {
        'title': _title,
        'content': _content,
        'duration': _duration,
        'media': _media,
        'files': _files,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_isEditMode) {

        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.course.id)
            .collection('lessons')
            .doc(widget.lessonId)
            .update(lessonData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson updated successfully!')),
        );
      } else {

        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.course.id)
            .collection('lessons')
            .add(lessonData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lesson added successfully!')),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonListScreen(course: widget.course),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Lesson' : 'Add Lesson to ${widget.course.title}'),
        backgroundColor: Color(0xFF2E5969),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Lesson Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a lesson title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              SizedBox(height: 16),

              // Content field
              TextFormField(
                initialValue: _content,
                decoration: InputDecoration(
                  labelText: 'Lesson Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the lesson content';
                  }
                  return null;
                },
                onSaved: (value) {
                  _content = value ?? '';
                },
              ),
              SizedBox(height: 16),

              // Duration Dropdown
              DropdownButtonFormField(
                value: _duration.isNotEmpty ? _duration : null,
                decoration: InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _durationOptions
                    .map((duration) => DropdownMenuItem(
                  value: duration,
                  child: Text(duration),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _duration = value.toString();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the lesson duration';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              if (_media.isNotEmpty)
                Column(
                  children: _media.asMap().entries.map((entry) {
                    int index = entry.key;
                    String file = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            file,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMedia(index),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text('Select Media'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E5969),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectMedia,
              ),
              SizedBox(height: 16),

              if (_files.isNotEmpty)
                Column(
                  children: _files.asMap().entries.map((entry) {
                    int index = entry.key;
                    String file = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            file,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFile(index),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              ElevatedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text('Select Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E5969),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectFiles,
              ),
              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(_isEditMode ? 'Update Lesson' : 'Save Lesson'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveLesson,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
