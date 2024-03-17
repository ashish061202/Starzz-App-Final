import 'package:STARZ/screens/auth/entry_point.dart';
import 'package:STARZ/screens/auth/login/rain_animation.dart';
import 'package:STARZ/screens/home/components/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpLoginPage extends StatefulWidget {
  static const id = '/otp-login';
  final String verificationid;
  final String enteredWABAID;
  const OtpLoginPage(
      {super.key, required this.verificationid, required this.enteredWABAID});

  @override
  State<OtpLoginPage> createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const RainAnimation(),
          Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/otp_screen_logo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Phone Verification",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "We need to register your phone without getting started!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Pinput(
                    length: 6,
                    controller: otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    showCursor: true,
                    onCompleted: (pin) => print(pin),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        try {
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                            verificationId: widget.verificationid,
                            smsCode: otpController.text.toString(),
                          );
                          FirebaseAuth.instance
                              .signInWithCredential(credential)
                              .then(
                            (value) {
                              Get.toNamed(NavigationScreen.id,
                                  arguments: widget.enteredWABAID);
                            },
                          );
                        } catch (e) {
                          print('OTP Login Page Error : $e.toString()');
                        }
                      },
                      child: const Text(
                        "Verify Phone Number",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            EntryPoint.id,
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Edit Phone Number ?",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class OtpLoginPage extends StatefulWidget {
//   static const id = '/otp-login';
//   const OtpLoginPage({Key? key}) : super(key: key);

//   @override
//   _OtpLoginPageState createState() => _OtpLoginPageState();
// }

// class _OtpLoginPageState extends State<OtpLoginPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late String _verificationId;

//   final TextEditingController _otpController = TextEditingController();

//   void _onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
//     try {
//       await _auth.signInWithCredential(phoneAuthCredential);
//       // The user is signed in
//       // Navigate to the home screen or wherever you want to take the user after successful login
//       Get.offAllNamed(HomeScreen.id);
//     } on FirebaseAuthException catch (e) {
//       // Handle the error
//       // Show a snackbar or a dialog box to the user to inform them about the error
//       Get.snackbar('Error', e.message ?? 'An error occurred');
//     }
//   }

//   void _onVerificationFailed(FirebaseAuthException exception) {
//     // Handle the verification failure
//     // Show a snackbar or a dialog box to the user to inform them about the error
//     Get.snackbar('Error', exception.message ?? 'An error occurred');
//   }

//   void _onCodeSent(String verificationId, int? resendToken) {
//     // Save the verification ID
//     _verificationId = verificationId;
//   }

//   void _onOtpEntered(String otp) async {
//     try {
//       // Create a PhoneAuthCredential with the OTP code and verification ID
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: otp,
//       );
//       // Sign in the user with the credential
//       await _auth.signInWithCredential(credential);
//       // The user is signed in
//       // Navigate to the home screen or wherever you want to take the user after successful login
//       Get.offAllNamed(HomeScreen.id);
//     } on FirebaseAuthException catch (e) {
//       // Handle the error
//       // Show a snackbar or a dialog box to the user to inform them about the error
//       Get.snackbar('Error', e.message ?? 'An error occurred');
//     }
//   }

//   @override
//   void dispose() {
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(16.sp),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextFormField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Enter OTP',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16.sp),
//             ElevatedButton(
//               onPressed: () {
//                 String otp = _otpController.text.trim();
//                 if (otp.isEmpty) {
//                   Get.snackbar('Error', 'Please enter the OTP');
//                 } else {
//                   _onOtpEntered(otp);
//                 }
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
