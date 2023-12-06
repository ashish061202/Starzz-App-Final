import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:starz/screens/auth/login/login_page.dart';
import 'package:starz/screens/home/home_screen.dart';

class PageChooser extends StatefulWidget {
  const PageChooser({super.key});

  static const id = "/page_chooser";

  @override
  State<PageChooser> createState() => _PageChooserState();
}

class _PageChooserState extends State<PageChooser> {
  @override
  void initState() {
    super.initState();
    FacebookAuth.i.accessToken.then((value) => value == null
        ? Get.offNamed(LoginPage.id)
        : Get.offNamed(HomeScreen.id));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
