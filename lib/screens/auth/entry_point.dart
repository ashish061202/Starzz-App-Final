//import 'package:ayurveda_apk/widget/backgroungimage.dart';
import 'package:STARZ/screens/auth/login/otp/otp_login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:STARZ/screens/home/components/navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:STARZ/screens/home/components/profile_page.dart';
//import 'package:STARZ/screens/home/home_screen.dart';
//import 'package:STARZ/screens/home/home_screen.dart';
import 'wabaid_controller.dart';
import 'package:connectivity/connectivity.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import '../widget/mydrawer.dart';

class BackgroundImageEntryPoint extends StatelessWidget {
  const BackgroundImageEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color: Colors.amberAccent,
        image: DecorationImage(
            image: const AssetImage(
              "assets/wallpaper.jpg",
            ),
            fit: BoxFit.cover,
            colorFilter: Get.isDarkMode
                ? const ColorFilter.mode(
                    Color.fromARGB(160, 0, 0, 0), BlendMode.darken)
                : const ColorFilter.mode(
                    Color.fromARGB(160, 0, 0, 0), BlendMode.darken)),
      ),
    );
  }
}

//Me Try1
class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  static const id = "/entry_point";

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _wabaIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String countryCode = "+91";
  bool hideWABAIDField = false;

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdate();

    // Check if the user is already logged in
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      // User is already logged in, navigate to the home screen

      // Retrieve WABAID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? enteredWABAID = prefs.getString('enteredWABAID');
      String? phoneNumber = prefs.getString('phoneNumber');

      if (enteredWABAID != null) {
        // Navigate to the home screen with the stored WABAID
        WABAIDController wabaidController = Get.find();
        wabaidController.setEnteredWABAID(enteredWABAID);
        wabaidController.setPhoneNumber(phoneNumber!);
        Get.toNamed(NavigationScreen.id, arguments: enteredWABAID);
      }
    } else {
      // User is not logged in, check if 'Phone' field is present in Firestore
      _checkForPhoneNumberField();
    }
  }

  Future<void> _checkForPhoneNumberField() async {
    // Retrieve WABAID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? enteredWABAID = prefs.getString('enteredWABAID');

    if (enteredWABAID != null) {
      var docSnapshot = await FirebaseFirestore.instance
          .collection(('accounts'))
          .doc(enteredWABAID)
          .get();

      if (docSnapshot.exists && docSnapshot.data()!.containsKey('Phone')) {
        // 'Phone' field is present, show phone number input only
        String rawPhoneNumber = docSnapshot['Phone'];

        // Trim the prefix if it's '+91'
        String phoneNumber = rawPhoneNumber.startsWith('+91')
            ? rawPhoneNumber.substring(3) // Skip the '+91' prefix
            : rawPhoneNumber;

        // Set the trimmed phone number to the _phoneNumberController
        _phoneNumberController.text = phoneNumber;

        // Hide WABAID field
        setState(() {
          hideWABAIDField = true;
        });
      }
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      print('Checking for update...');
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      print('Error checking for update: $e');
    }
  }

  void _showUpdateDialog(AppUpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
              'A new version of the app is available. Please update to the latest version.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Start the update process
                await InAppUpdate.performImmediateUpdate();
                _startImmediateUpdate();
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startImmediateUpdate() async {
    try {
      AppUpdateResult result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.success) {
        print('Update started successfully !');
        // Update started successfully
        // Handle the case when the user might close the app during the update
        // You may want to display a message informing the user to reopen the app
      } else if (result == AppUpdateResult.userDeniedUpdate) {
        print('User denied the update');
        // User denied the update
        // You may want to show a message or handle it accordingly
      } else {
        print('Update failed for some reason');
        // Update failed for some reason
        // You may want to show a message or handle it accordingly
      }
    } catch (e) {
      print('Error starting immediate update: $e');
    }
  }

  // Function to handle clearing SharedPreferences, unhiding WABAID input field, and clearing phone number input field
  void _clearSharedPreferencesAndFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('enteredWABAID');
    await prefs.remove('phoneNumber');
    _wabaIdController.clear();
    _phoneNumberController.clear();

    setState(() {
      hideWABAIDField = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundImageEntryPoint(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Welcome to STARZ VENTURES",
                        style: GoogleFonts.nunito(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Automate your Business",
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: !_phoneNumberController.text.isNotEmpty &&
                                !hideWABAIDField
                            ? 50
                            : 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9),
                        child: Column(
                          children: [
                            SizedBox(
                              height: !_phoneNumberController.text.isNotEmpty &&
                                      !hideWABAIDField
                                  ? 10
                                  : 5,
                            ),
                            if (!_phoneNumberController.text.isNotEmpty &&
                                !hideWABAIDField)
                              TextFormField(
                                controller: _wabaIdController,
                                // Set the text color of the input field
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  iconColor: Colors.white,
                                  icon: const Icon(Icons.lock),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  hintText: "Enter WABAID",
                                  hintStyle: GoogleFonts.nunito(
                                    color: const Color.fromARGB(
                                        255, 118, 114, 114),
                                  ),
                                  labelText: "WABAID ",
                                  labelStyle: GoogleFonts.nunito(
                                    color: const Color.fromARGB(
                                        255, 245, 243, 243),
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 12,
                            ),
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                iconColor: Colors.white,
                                icon: const Icon(Icons.phone),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                hintText: "Enter Phone Number",
                                hintStyle: GoogleFonts.nunito(
                                  color:
                                      const Color.fromARGB(255, 118, 114, 114),
                                ),
                                labelText: "Phone Number ",
                                labelStyle: GoogleFonts.nunito(
                                  color:
                                      const Color.fromARGB(255, 245, 243, 243),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(
                      //   height: _phoneNumberController.text.isNotEmpty &&
                      //           hideWABAIDField
                      //       ? null
                      //       : 20,
                      // ),
                      if (_phoneNumberController.text.isNotEmpty &&
                          hideWABAIDField)
                        TextButton(
                          onPressed: () {
                            _clearSharedPreferencesAndFields();
                          },
                          child: const Text(
                            'Click here to login with another WABAID',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: !_phoneNumberController.text.isNotEmpty &&
                                !hideWABAIDField
                            ? 40
                            : 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool isConnected = await _checkInternetConnection();

                          if (!isConnected) {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('No Internet Connection'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.signal_wifi_off,
                                        size: 50,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Oops! It seems you are not connected to the internet.',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.redAccent[100],
                                        ),
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              },
                            );
                            return;
                          }

                          // Retrieve last entered WABAID from SharedPreferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String? lastEnteredWABAID =
                              prefs.getString('enteredWABAID');

                          String enteredWABAID = lastEnteredWABAID ??
                              _wabaIdController.text.trim();
                          String enteredPhoneNumber =
                              '$countryCode${_phoneNumberController.text.toString()}';
                          WABAIDController wabaidController = Get.find();
                          wabaidController.setEnteredWABAID(enteredWABAID);

                          var docSnapshot = await FirebaseFirestore.instance
                              .collection(('accounts'))
                              .doc(enteredWABAID)
                              .get();

                          if (docSnapshot.exists) {
                            String phoneNumber = docSnapshot['phoneNumber'];

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('enteredWABAID', enteredWABAID);
                            prefs.setString('phoneNumber', phoneNumber);
                            WABAIDController wabaidController = Get.find();
                            wabaidController
                                .setPhoneNumber(docSnapshot['phoneNumber']);

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => OtpLoginPage(
                            //       verificationid: "verificationid",
                            //       enteredWABAID: enteredWABAID,
                            //     ),
                            //   ),
                            // );

                            if (docSnapshot.data()!.containsKey('Phone')) {
                              if (enteredPhoneNumber == docSnapshot['Phone']) {
                                await _firebaseAuth.verifyPhoneNumber(
                                  phoneNumber: enteredPhoneNumber,
                                  verificationCompleted:
                                      (PhoneAuthCredential credential) async {
                                    await _firebaseAuth
                                        .signInWithCredential(credential);
                                  },
                                  verificationFailed:
                                      (FirebaseAuthException e) {
                                    print("Verification failed: $e.message");
                                    if (e.code == 'invalid-phone-number') {
                                      print(
                                          'The provided phone number is not valid.');
                                    }
                                  },
                                  codeSent: (String verificationid,
                                      int? resendtoken) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OtpLoginPage(
                                          verificationid: verificationid,
                                          enteredWABAID: enteredWABAID,
                                        ),
                                      ),
                                    );
                                  },
                                  codeAutoRetrievalTimeout:
                                      (String verificationId) {},
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 40,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Wrong phone number',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Oops! No account found for this phone number.',
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.grey,
                                            ),
                                            child: const Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              // 'Phone' field is not present, update it
                              await _firebaseAuth.verifyPhoneNumber(
                                phoneNumber: enteredPhoneNumber,
                                verificationCompleted:
                                    (PhoneAuthCredential credential) async {
                                  await _firebaseAuth
                                      .signInWithCredential(credential);
                                },
                                verificationFailed: (FirebaseAuthException e) {
                                  print("Verification failed: $e.message");
                                  if (e.code == 'invalid-phone-number') {
                                    print(
                                        'The provided phone number is not valid.');
                                  }
                                },
                                codeSent: (String verificationid,
                                    int? resendtoken) async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtpLoginPage(
                                        verificationid: verificationid,
                                        enteredWABAID: enteredWABAID,
                                      ),
                                    ),
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('accounts')
                                      .doc(enteredWABAID)
                                      .update({'Phone': enteredPhoneNumber});
                                },
                                codeAutoRetrievalTimeout:
                                    (String verificationId) {},
                              );
                            }
                          } else {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Invalid WABAID',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Oops! The entered WABAID is not valid.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                        ),
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple.shade800, // Text color
                          elevation: 5, // Elevation (shadow) of the button
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded corners
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.login), // Icon on the left
                              const SizedBox(
                                  width: 8), // Spacing between icon and text
                              Text(
                                !_phoneNumberController.text.isNotEmpty &&
                                        !hideWABAIDField
                                    ? "Enter"
                                    : "Login",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
