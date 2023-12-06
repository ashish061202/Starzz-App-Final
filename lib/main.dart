import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:starz/controllers/conctacts_controller.dart';
import 'package:starz/firebase_options.dart';
import 'package:get/get.dart';
import 'package:starz/screens/auth/Entry_point.dart';
import 'package:starz/screens/auth/login/login_page.dart';
import 'package:starz/screens/auth/login/otp/otp_login_page.dart';

import 'package:starz/screens/chat/chat_page.dart';

import 'package:starz/screens/home/components/profile_page.dart';
import 'package:starz/screens/privacy&policy/privacy_and_policy.dart';
import 'package:starz/screens/video_player/video_player_screen.dart';
import 'package:starz/screens/home/home_screen.dart';
import 'package:starz/screens/page_chooser/page_chooser.dart';
import 'package:starz/screens/phone_contacts/phone_contacts_page.dart';
import 'screens/register/register_screen.dart';
import 'screens/home/components/navigation_bar.dart';
import 'package:starz/screens/auth/wabaid_controller.dart';

//Widget _defaultHome = const RegisterScreen();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC2X3wwrifUxcdppx61HQ15n9MwFpdyWAE',
      authDomain: 'https://accounts.google.com/o/oauth2/auth',
      projectId: 'starzapp',
      storageBucket: 'starzapp.appspot.com',
      messagingSenderId: '655518493333',
      appId: '1:655518493333:android:0ffd42bd02caba16c7c99c',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WABAIDController());
    return Sizer(
      builder: (context, orientation, devicetype) => GetMaterialApp(
        initialRoute: EntryPoint.id,
        debugShowCheckedModeBanner: false,
        title: 'Starz App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //home: const RegisterScreen(),
        getPages: [
          GetPage(name: HomeScreen.id, page: () => const HomeScreen()),
          GetPage(name: EntryPoint.id, page: () => const EntryPoint()),

          //GetPage(name: NavigationBar.id, page: ()=>NavigationBar()),
          GetPage(
              name: NavigationScreen.id, page: () => const NavigationScreen()),
          GetPage(name: ProfileScreen.id, page: () => const ProfileScreen()),
          //GetPage(name: "/navigate", page: () => NavigationScreen()),
          GetPage(name: RegisterScreen.id, page: () => const RegisterScreen()),
          GetPage(name: ChatPage.id, page: () => ChatPage()),
          GetPage(name: LoginPage.id, page: () => const LoginPage()),
          GetPage(name: PageChooser.id, page: () => const PageChooser()),
          GetPage(name: PhoneContactsPage.id, page: () => PhoneContactsPage()),
          GetPage(name: VideoPlayerScreen.id, page: () => VideoPlayerScreen()),
          GetPage(
              name: PrivacyAndPolicyPage.id,
              page: () => const PrivacyAndPolicyPage()),
          GetPage(name: OtpLoginPage.id, page: () => const OtpLoginPage()),
        ],
        initialBinding: BindingsBuilder(() {
          Get.lazyPut(() => ConctactsController(), fenix: true);
        }),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create a stream to listen for changes in authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Send an OTP code to the user's phone number
  Future<void> sendOtp(String phoneNumber) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to the OTP verification page
        Get.toNamed(OtpLoginPage.id, arguments: {
          'verificationId': verificationId,
          'phoneNumber': phoneNumber,
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify the OTP code entered by the user
}

// import "dart:html";

// import 'package:flutter/material.dart';
// import 'package:starz/screens/home/home_screen.dart';
// import 'package:starz/screens/phone_contacts/phone_contacts_page.dart';
// import 'package:starz/screens/register/register_screen.dart';

// void main(List<String> args) {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: PhoneContactsPage());
//   }
// }
