import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProblemPage extends StatefulWidget {
  const AddProblemPage({super.key, required this.enteredWABAID});

  static const id = '/add_problem';
  final String enteredWABAID;

  @override
  State<AddProblemPage> createState() => _AddProblemPageState();
}

class _AddProblemPageState extends State<AddProblemPage>
    with TickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onButtonPressed() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference problemsCollection = firestore.collection('problems');
    String description = _descriptionController.text;
    String category = _categoryController.text;
    double starRating = 0;

    await problemsCollection.add({
      'description': description,
      'userId': widget.enteredWABAID,
      'category': category,
      'starRating': starRating,
    });

    _animationController.forward(from: 0);
    await Future.delayed(
        const Duration(milliseconds: 300)); // Adjust delay as needed
    Navigator.pop(context); // Navigate back after adding the problem
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Problem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Problem Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Problem Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            elevation: 3, // Elevation
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Button border radius
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: Tween<double>(
                                    begin: 1,
                                    end: 0.95,
                                  )
                                      .animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.easeInOut,
                                        ),
                                      )
                                      .value,
                                  child: Text(
                                    'Submit',
                                    style: GoogleFonts.fuzzyBubbles(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Get.isDarkMode
                                            ? Colors.white
                                            : Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
