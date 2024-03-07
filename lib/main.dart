import 'package:STARZ/api/firebase_api.dart';
import 'package:STARZ/controllers/custom_hero_controller.dart';
import 'package:STARZ/message_utility.dart';
import 'package:STARZ/screens/chat/notification_util.dart';
import 'package:STARZ/screens/home/components/theme_controller.dart';
import 'package:STARZ/widgets/custom_card_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:STARZ/controllers/conctacts_controller.dart';
//import 'package:STARZ/firebase_options.dart';
import 'package:get/get.dart';
import 'package:STARZ/screens/auth/Entry_point.dart';
import 'package:STARZ/screens/auth/login/login_page.dart';
import 'package:STARZ/screens/auth/login/otp/otp_login_page.dart';

import 'package:STARZ/screens/chat/chat_page.dart';

import 'package:STARZ/screens/privacy&policy/privacy_and_policy.dart';
import 'package:STARZ/screens/video_player/video_player_screen.dart';
import 'package:STARZ/screens/home/home_screen.dart';
import 'package:STARZ/screens/page_chooser/page_chooser.dart';
import 'package:STARZ/screens/phone_contacts/phone_contacts_page.dart';
import 'screens/register/register_screen.dart';
import 'screens/home/components/navigation_bar.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/chat/pdf_viewer.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as LocalNotifications;
import 'package:provider/provider.dart';
//import 'package:http/http.dart' as http;
//import 'dart:io';

//Widget _defaultHome = const RegisterScreen();

final LocalNotifications.FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    LocalNotifications.FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String phoneNumber = message.data['+917304652722'];
  String autoReplyMessage = "Thank you for your message!";

  // Send auto-reply message
  await MessageUtility.sendMessage(autoReplyMessage, phoneNumber);

  print("Handling a background message: ${message.messageId}");
  try {
    await NotificationUtil.showNotification(
      message.notification?.title,
      message.notification?.body,
    );
    print("Notification handled successfully in background!");
  } catch (e) {
    print("Error showing notification in background: $e");
  }
}

// const _credentials = r'''{
//   "type": "service_account",
//   "project_id": "steady-method-412112",
//   "private_key_id": "69c3011f9fbf0567aab35e747aa624ef6e6fc380",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2kwBm8U2EaYJA\n2F85e7hHMQUWM1JG5evF74W3IO+zHm7o5KzKP8HHSjmuu6XhYutxleebgaDuhPnD\n2wwhdtrSZJVlA6g7eJjXLrEldWEKMzTmqDQtOjNN9KRdh+I3Jpfdo7XGrjQtgOBe\nKlFFMJ23bGmS8DG3bX9sfvsm+6K8GNgPPtZQ0ECyHws7rNg7/m421xJh8pxU1QWk\nfqwVZSjcC22O7FNxPOeqwa9gk4n/WBE/SzvxjNr5/ME033lC5nptJnrtwDoVYGBu\nAVfRPmneaw6vCVyi/pRTZoiag/Goo0n+cqzLMrMp+BS3JXYQM3E8o/W2NLtJ5k4a\n1sR+Z+UjAgMBAAECggEAAM8avvOhLRqg+4b563GwGcCoQRzt55qFNojrksNc/779\nLTlpYP8/U8UkbeQu+MmAOZSfqufvV2wHbBkmyJv6N3LZDQWJhua8TQr/H43EzE+S\nk6MTK1AitUNSpyEL0F3ynLmcLv3+nstlzLg4FZJnLU5+eUQ1mpZ40t/Z+D/Z//Nd\ngZVa9/+A//KDTGximcYtBqCltrWaRvRSMzfbRlS6iZ8Y3Zc8TBiSBXGxWjgIKfwd\ncfBoW+8fprvGl6lLlUG4K0W7JT81yyGTE44hv3NMlSy/hCW0In0lYP+mXYvYSATu\nL0sci+dyZ9eWuFMAHndFtLn9cVp+U97AyGb1b0YMwQKBgQDu8ncasDJLNTZ+te22\nJNHsWWUaS+BfzNM6WeaDQ6JC6q+Ycsy36IvkjzJ6+om+5oH2LqPQM1zDzfOUJH1O\njlsTBGz46DFBQjN6l6yCUkuZfs9n4pJBa8oYysz8sx8FZkpSPv2NB+SA4NbHqFOK\nRmtSeoOP5H8qEtUVKoyGuqJgiwKBgQDDmpw6FOqnsNHw5e/zDVI8v8LFK9S3dMp5\nL2SYbwaKTmtFV0YkO8Lkasw14w4KM2OntilGEHN0CUd6bkdULhts4cKpAV2/DCa4\naV2O/Pe4rtTfIiI6yA84wu68N0DBXBQHENPEProtRUGZTMY/H6bSmBScs3C8RDgj\n0jFZaqlIyQKBgH9qle6KVFdcadHJq5e8LKDOzqXmHiCXtW9hLxWCBE2QndA6L0ZG\nYAqh/XYskTVV76laF4pXSTk0YpX1m0g/ivsqGf3kuxckeRT/OkNIJP4V6/1miT0P\ngHYV9pct4PXdJPaUlloVAlljC8Tt0pZilKonoG4jl1fVMQEXblYNwbafAoGBAK5A\nevJnFdADflNbk9HzSRKjRhC+hkZUfddNeBEvvyTQzVE9eVfoASvZVEihGC3QL/QF\nHGm1WBTD+3A+874zQO1ThUVn2SrL2WapPtaV1t0oqqyIzPOOq7jGN0Vm94IJ1DGj\nNPP7aYHQ06qMsYMkYEn1f09Fr6WYJGcM5jehBGO5AoGBAOTGfcsPWaXn5KDWyLpV\nSK2TjQJkyDkC1SlmGX81WC7fT74f0GndDHDrjuAcYQcm0J5XlY+loHPKD0dc5mPf\nt/L+hh4lESH79ZzUu45fPvTZDxPnYzxTTGivVwCxoEC7NYggtnaV3uxR6GTKogKc\nRefXPCQ+HvpZiqjt8aZkAKiI\n-----END PRIVATE KEY-----\n",
//   "client_email": "sheet-965@steady-method-412112.iam.gserviceaccount.com",
//   "client_id": "115173403809616435356",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sheet-965%40steady-method-412112.iam.gserviceaccount.com",
//   "universe_domain": "googleapis.com"
// }''';

// const _spreadsheetId = "1AYjukkMf_OrPYxI-N79J27oGP8-Fn6hrx3709oJvOnA";

// Call this function, perhaps in your main method or at the start of your app
void _loadGreetingMessage() async {
  String? _greetingMessage;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  _greetingMessage = prefs.getString('greeting_message');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC2X3wwrifUxcdppx61HQ15n9MwFpdyWAE',
      authDomain: 'starzapp.firebaseapp.com',
      projectId: 'starzapp',
      storageBucket: 'gs://starzapp.appspot.com',
      messagingSenderId: '655518493333',
      appId: '1:655518493333:android:76b9524d749f79c1c7c99c',
    ),
  );

  // Initialize local notifications
  await FirebaseApi().initNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize flutter_downloader only once
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  _loadGreetingMessage();

  // Create DarkModeController instance
  DarkModeController darkModeController = DarkModeController();

  // final gsheets = GSheets(_credentials);
  // final ss = await gsheets.spreadsheet(_spreadsheetId);

  runApp(
    ChangeNotifierProvider(
      create: (context) => CustomCardStateNotifier(),
      child: MyApp(prefs: prefs, darkModeController: darkModeController),
    ),
  );
}

Future<void> initLocalNotifications() async {
  const LocalNotifications.AndroidInitializationSettings
      initializationSettingsAndroid =
      LocalNotifications.AndroidInitializationSettings('android');
  const LocalNotifications.InitializationSettings initializationSettings =
      LocalNotifications.InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null, // Set iOS to null to disable iOS notifications
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  const MyApp(
      {super.key, required this.prefs, required this.darkModeController});

  final SharedPreferences prefs;
  final DarkModeController darkModeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CustomHeroController _heroController = CustomHeroController();
  final DarkModeController darkModeController = DarkModeController();
  //final cacheManager = DefaultCacheManager();
  @override
  Widget build(BuildContext context) {
    Get.put(widget.darkModeController);
    Get.put(WABAIDController());
    return Sizer(
      builder: (context, orientation, devicetype) => GetMaterialApp(
        initialRoute: EntryPoint.id,
        debugShowCheckedModeBanner: false,
        title: 'STARZ',
        navigatorObservers: [_heroController],
        theme: ThemeData.light(), // Initial theme
        darkTheme: ThemeData.dark(),
        themeMode: widget.prefs.getBool('isDarkMode') == true
            ? ThemeMode.dark
            : ThemeMode.light,
        home: GetBuilder<DarkModeController>(
          init: darkModeController,
          builder: (_) => const NavigationScreen(),
        ),
        getPages: [
          GetPage(name: HomeScreen.id, page: () => const HomeScreen()),
          GetPage(name: PDFViewerPage.id, page: () => const PDFViewerPage()),
          GetPage(name: EntryPoint.id, page: () => const EntryPoint()),

          //GetPage(name: NavigationBar.id, page: ()=>NavigationBar()),
          GetPage(
              name: NavigationScreen.id, page: () => const NavigationScreen()),
          //GetPage(name: ProfileScreen.id, page: () => const ProfileScreen()),
          //GetPage(name: EntryPoint.id, page: () => NavigationScreen()),
          GetPage(name: RegisterScreen.id, page: () => const RegisterScreen()),
          GetPage(name: ChatPage.id, page: () => ChatPage(prefs: widget.prefs)),
          GetPage(name: LoginPage.id, page: () => const LoginPage()),
          GetPage(name: PageChooser.id, page: () => const PageChooser()),
          GetPage(name: PhoneContactsPage.id, page: () => PhoneContactsPage()),
          GetPage(name: VideoPlayerScreen.id, page: () => VideoPlayerScreen()),
          GetPage(
              name: PrivacyAndPolicyPage.id,
              page: () => const PrivacyAndPolicyPage()),
          //GetPage(name: OtpLoginPage.id, page: () => OtpLoginPage()),
        ],
        initialBinding: BindingsBuilder(() {
          Get.lazyPut(() => ConctactsController(), fenix: true);
        }),
      ),
    );
  }
}

Future<void> _handleNotification(String? title, dynamic body) async {
  String notificationBody;

  if (body is String) {
    notificationBody = body;
  } else if (body is Map<String, dynamic>) {
    // Extract the "body" field from the map
    dynamic bodyField = body['body'];

    // Check if the "body" field is a String
    if (bodyField is String) {
      notificationBody = bodyField;
    } else {
      // Handle other types accordingly or provide a default value
      notificationBody = 'Default Value';
    }
  } else {
    // Handle other types accordingly or provide a default value
    notificationBody = 'Default Value';
  }
  const LocalNotifications.AndroidNotificationDetails
      androidPlatformChannelSpecifics =
      LocalNotifications.AndroidNotificationDetails(
    '"chat_messages"', // replace with your channel ID
    '"Chat Messages"', // replace with your channel name
    importance: LocalNotifications.Importance.max,
    priority: LocalNotifications.Priority.high,
    showWhen: false,
  );
  const LocalNotifications.NotificationDetails platformChannelSpecifics =
      LocalNotifications.NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: null);

  await flutterLocalNotificationsPlugin.show(
    0, // notification ID
    title ?? '', // title
    notificationBody, // body
    platformChannelSpecifics,
    payload: 'chat_message', // optional payload
  );
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
// import 'package:STARZ/screens/home/home_screen.dart';
// import 'package:STARZ/screens/phone_contacts/phone_contacts_page.dart';
// import 'package:STARZ/screens/register/register_screen.dart';

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
