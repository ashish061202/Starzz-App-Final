import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:get/get.dart';
// import 'package:starz/screens/auth/login/login_page.dart';
// import 'package:starz/screens/home/components/navigation_bar.dart';
// import 'package:starz/screens/privacy&policy/privacy_and_policy.dart';

import 'components/contacts_page.dart';
import 'package:starz/screens/auth/entry_point.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  static const id = "/";

  @override
  Widget build(BuildContext context) {
    final String? enteredWABAID = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starz'),
        // leading: IconButton(
        //     icon: Icon(Icons.logout_rounded),
        //     onPressed: () async {
        //       await FacebookAuth.i.logOut();
        //       Get.offNamed(LoginPage.id);
        //     }),
        // actions: [
        // IconButton(
        //   onPressed: () {
        //     Get.toNamed(PrivacyAndPolicyPage.id);
        //   },
        //   icon: const Icon(Icons.info_outline_rounded),
        // ),
        //],
      ),
      body: ContactsPage(enteredWABAID: enteredWABAID),
    );
  }
}
