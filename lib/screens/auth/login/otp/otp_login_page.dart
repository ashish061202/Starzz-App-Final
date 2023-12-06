//import 'dart:convert';
//import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_sound/public/flutter_sound_recorder.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:http_parser/http_parser.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:intl/intl.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'package:place_picker/entities/location_result.dart';
//import 'package:place_picker/place_picker.dart';
import 'package:sizer/sizer.dart';
// import 'package:starz/api/whatsapp_api.dart';
// import 'package:starz/models/message.dart';
// import 'package:starz/services/location.dart';
// import 'package:starz/widgets/reply_message_card_reply.dart';
// import 'package:swipe_to/swipe_to.dart';

import '../../../home/home_screen.dart';

class OtpLoginPage extends StatefulWidget {
  static const id = '/otp-login';
  const OtpLoginPage({Key? key}) : super(key: key);

  @override
  _OtpLoginPageState createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;

  final TextEditingController _otpController = TextEditingController();

  void _onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
    try {
      await _auth.signInWithCredential(phoneAuthCredential);
      // The user is signed in
      // Navigate to the home screen or wherever you want to take the user after successful login
      Get.offAllNamed(HomeScreen.id);
    } on FirebaseAuthException catch (e) {
      // Handle the error
      // Show a snackbar or a dialog box to the user to inform them about the error
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    // Handle the verification failure
    // Show a snackbar or a dialog box to the user to inform them about the error
    Get.snackbar('Error', exception.message ?? 'An error occurred');
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    // Save the verification ID
    _verificationId = verificationId;
  }

  void _onOtpEntered(String otp) async {
    try {
      // Create a PhoneAuthCredential with the OTP code and verification ID
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      // Sign in the user with the credential
      await _auth.signInWithCredential(credential);
      // The user is signed in
      // Navigate to the home screen or wherever you want to take the user after successful login
      Get.offAllNamed(HomeScreen.id);
    } on FirebaseAuthException catch (e) {
      // Handle the error
      // Show a snackbar or a dialog box to the user to inform them about the error
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.sp),
            ElevatedButton(
              onPressed: () {
                String otp = _otpController.text.trim();
                if (otp.isEmpty) {
                  Get.snackbar('Error', 'Please enter the OTP');
                } else {
                  _onOtpEntered(otp);
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
