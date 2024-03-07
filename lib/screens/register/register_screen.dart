import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:STARZ/api/api_service.dart';

import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static const id = "/pinPage";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? myPin;
  bool isLoading = false;
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
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    // ignore: unused_local_variable
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    // ignore: unused_local_variable
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
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
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/img1.png',
                  //   width: 150,
                  //   height: 150,
                  // ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Registration",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "We need to register your phone to getting started!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Pinput(
                    length: 6,
                    // defaultPinTheme: defaultPinTheme,
                    // focusedPinTheme: focusedPinTheme,
                    // submittedPinTheme: submittedPinTheme,

                    showCursor: true,
                    onCompleted: (pin) {
                      myPin = pin;
                    },
                    onSubmitted: (value) {
                      myPin = value;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });

                          if (myPin != null) {
                            APIService.registerUser(myPin!).then((response) {
                              setState(() {
                                isLoading = false;
                              });
                              response.when((success) {
                                Fluttertoast.showToast(msg: "Success");
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return HomeScreen();
                                  },
                                ));
                              }, (error) {
                                Fluttertoast.showToast(
                                    msg: error, backgroundColor: Colors.red);
                              });
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: "Pin Field cannot be empty",
                                backgroundColor: Colors.red);
                          }
                        },
                        child: const Text("Signup")),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
