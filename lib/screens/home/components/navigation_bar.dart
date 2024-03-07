import 'package:STARZ/screens/home/components/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:STARZ/screens/home/components/dashboard_screen.dart';
import 'package:STARZ/screens/home/components/profile_page.dart';
import 'package:STARZ/screens/home/home_screen.dart';
import 'package:get/get.dart';
//import 'package:get/get.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  static const id = "/navigation_bar";

  @override
  State<NavigationScreen> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationScreen> {
  int _currentIndex = 0;
  List<Widget> widgetList = [
    DashboardScreen(),
    const HomeScreen(),
    const ProfileScreen()
  ];

  //static const id = "/";
  @override
  Widget build(BuildContext context) {
    final DarkModeController darkModeController = DarkModeController();
    return WillPopScope(
      onWillPop: () async {
        // Return the result directly instead of a Future
        final result = await _onBackPressed();
        return result ?? false; // Return false if result is null
      },
      child: Scaffold(
        body: Center(
          child: widgetList[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          iconSize: 23,
          elevation: 12,
          backgroundColor: darkModeController.isDarkMode.isTrue
              ? Colors.black
              : Colors.brown.shade50,
          selectedItemColor: darkModeController.isDarkMode.isTrue
              ? Colors.white // Color for the selected item in dark mode
              : const Color.fromARGB(255, 107, 74,
                  207), // Color for the selected item in light mode
          unselectedItemColor: darkModeController.isDarkMode.isTrue
              ? Colors.white.withOpacity(0.6) // Adjust the opacity as needed
              : Colors.black.withOpacity(0.6), // Adjust the opacity as needed
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              //backgroundColor: Colors.purple
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: "Chat",
              //backgroundColor: Colors.purple
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
              //backgroundColor: Colors.purple
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Future<bool?> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final titleStyle = TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        );
        final contentStyle = TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
        );
        final noButtonStyle = TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.blue : Colors.blue,
        );
        final yesButtonStyle = TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.red : Colors.red,
        );

        return AlertDialog(
          title: Text(
            'Do you really want to exit the app?',
            style: titleStyle,
          ),
          content: Text(
            'Exiting the app will close all active sessions.',
            style: contentStyle,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: noButtonStyle,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Yes',
                style: yesButtonStyle,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
        );
      },
    );
  }
}
