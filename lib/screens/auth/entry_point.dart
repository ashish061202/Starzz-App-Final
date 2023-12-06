//import 'package:ayurveda_apk/widget/backgroungimage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:starz/screens/home/components/navigation_bar.dart';
import 'package:starz/screens/home/components/profile_page.dart';
//import 'package:starz/screens/home/home_screen.dart';
//import 'package:starz/screens/home/home_screen.dart';
import 'package:starz/widgets/background_image.dart';
import 'wabaid_controller.dart';

//import '../widget/mydrawer.dart';

//He
/*class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  static const id = "/entry_point";

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  //final _formKey = GlobalKey<FormState>();
  final TextEditingController _wabaIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    const Text(
                      "Welcome to STARZ VENTURES",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Automate your Business",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: _wabaIdController,
                            //obscureText: true,
                            decoration: InputDecoration(
                                iconColor: Colors.white,
                                icon: const Icon(Icons.lock),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                hintText: "Enter WABAID", //181424085051090
                                hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 118, 114, 114)),
                                labelText: "WABAID ",
                                labelStyle: const TextStyle(
                                    color: Color.fromARGB(255, 245, 243, 243))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          //Validate the WABAID against the 'accounts' collection
                          String enteredWABAID = _wabaIdController.text.trim();

                          var docSnapshot = await FirebaseFirestore.instance
                              .collection(('accounts'))
                              .doc(enteredWABAID)
                              .get();
                          if (docSnapshot.exists) {
                            //If the WABAID is valid
                            //Navigate to the next screen
                            Get.toNamed(NavigationScreen.id, arguments: enteredWABAID);
                          } else {
                            // If the WABAID is not valid, show an error message
                            // or handle the error accordingly
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Invalid WABAID'),
                                  content: const Text('Please try again.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text("Enter")),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}*/

//Me Try1
class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});
  static const id = "/entry_point";

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final TextEditingController _wabaIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    const Text(
                      "Welcome to STARZ VENTURES",
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Automate your Business",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: _wabaIdController,
                            decoration: InputDecoration(
                              iconColor: Colors.white,
                              icon: const Icon(Icons.lock),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              hintText: "Enter WABAID",
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 118, 114, 114),
                              ),
                              labelText: "WABAID ",
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 245, 243, 243),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String enteredWABAID = _wabaIdController.text.trim();
                        WABAIDController wabaidController = Get.find();
                        wabaidController.setEnteredWABAID(enteredWABAID);

                        var docSnapshot = await FirebaseFirestore.instance
                            .collection(('accounts'))
                            .doc(enteredWABAID)
                            .get();
                        if (docSnapshot.exists) {
                          Get.toNamed(NavigationScreen.id,
                              arguments: enteredWABAID);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Invalid WABAID'),
                                content: const Text('Please try again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text("Enter"),
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
      ],
    );
  }
}
