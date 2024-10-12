import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uee_project/components/communitypage.dart';
import 'package:uee_project/pages/home_page1.dart';
import 'package:uee_project/pages/home_screen.dart';
import 'package:uee_project/pages/lib_home_page.dart';
import 'package:uee_project/pages/lib_user_home_page.dart';
import 'package:uee_project/screens/admin/course_list_screen.dart';
import 'package:uee_project/screens/user/user_course_list_screen.dart';

import 'profile.dart';

// Define the primary color constant
const kprimaryColor = Colors.blue;

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 28,
          currentIndex: selectedIndex,
          selectedItemColor: kprimaryColor,
          unselectedItemColor: Colors.grey[600], // Darker unselected icons
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            color: kprimaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 0 ? Iconsax.home5 : Iconsax.home,
                color: selectedIndex == 0 ? kprimaryColor : Colors.grey[600],
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 1 ? Iconsax.document5 : Iconsax.document,
                color: selectedIndex == 1 ? kprimaryColor : Colors.grey[600],
              ),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 2 ? Iconsax.folder5 : Iconsax.folder,
                color: selectedIndex == 2 ? kprimaryColor : Colors.grey[600],
              ),
              label: 'Course',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 3 ? Iconsax.people5 : Iconsax.people,
                color: selectedIndex == 3 ? kprimaryColor : Colors.grey[600],
              ),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 4
                    ? Iconsax.profile_2user5
                    : Iconsax.profile_2user,
                color: selectedIndex == 4 ? kprimaryColor : Colors.grey[600],
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: _buildPage(selectedIndex),
    );
  }

  //Screen Navigation logic
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        // return navbarPage(Iconsax.home5);
        return const HomeScreen();
      //return const AppMainScreen();
      case 1:
        // return navbarPage(Iconsax.document5);
        return LibUserHomePage();
      case 2:
        return UserCourseListScreen(); // Course page
      case 3:
        // return navbarPage(Iconsax.people5);
        return const CommunityPage();
      case 4:
        // return navbarPage(Iconsax.profile_2user5);
        return ProfilePage();
      default:
        return navbarPage(Iconsax.home5);
    }
  }

  Widget navbarPage(IconData iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: kprimaryColor,
      ),
    );
  }
}
