import 'package:flutter/material.dart';
import 'package:starz/screens/home/components/dashboard_screen.dart';
import 'package:starz/screens/home/components/profile_page.dart';
import 'package:starz/screens/home/home_screen.dart';
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
    const DashboardScreen(),
    const HomeScreen(),
    const ProfileScreen()
  ];
  //static const id = "/";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: widgetList[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          iconSize: 33,
          elevation: 12,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                backgroundColor: Colors.purple),
            BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                label: "Chat",
                backgroundColor: Colors.purple),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
                backgroundColor: Colors.purple),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ));
  }
}
