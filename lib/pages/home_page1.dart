import 'package:flutter/material.dart';
import 'package:uee_project/components/commentBox.dart';
import 'package:uee_project/components/communitypage.dart';

class HomePage1 extends StatelessWidget {
  const HomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 236, 235, 237),
        centerTitle: true,
        elevation: 4.0,
        shadowColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Community Posts Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityPage()),
                  );
                },
                icon: Icon(Icons.forum, color: Colors.black),
                label: Text(
                  'Community Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  shadowColor: Colors.deepPurple,
                  backgroundColor: const Color.fromARGB(255, 133, 119, 172),
                ),
              ),
              SizedBox(height: 20),

              // Feedbacks Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestMe()),
                  );
                },
                icon: Icon(Icons.feedback, color: Colors.black),
                label: Text(
                  'Feedbacks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 8,
                  shadowColor: Colors.pinkAccent,
                  backgroundColor: const Color.fromARGB(255, 194, 159, 172),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage1(),
    theme: ThemeData(
      primaryColor: Colors.deepPurple,
      scaffoldBackgroundColor: Colors.grey[100],
      fontFamily: 'Montserrat',
    ),
  ));
}
