import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:starz/screens/home/home_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const id = "/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: IconButton(
        iconSize: 80,
        icon: const Icon(Icons.facebook, color: Colors.blue),
        onPressed: () async {
          LoginResult result = await FacebookAuth.i.login();
          if (result.status == LoginStatus.success) {
            Get.toNamed(HomeScreen.id);
          }
        },
      )),
    );
  }
}
