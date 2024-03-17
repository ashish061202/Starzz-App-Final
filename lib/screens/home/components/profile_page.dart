import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:STARZ/screens/auth/entry_point.dart';
import 'package:STARZ/screens/home/components/add_problem.dart';
import 'package:STARZ/screens/home/components/problem_list.dart';
import 'package:STARZ/screens/home/components/profile_photo_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:STARZ/screens/privacy&policy/privacy_and_policy.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointUser {
  String id;
  String name;
  int points; // Add this line

  PointUser({required this.id, required this.name, required this.points});
}

//He
class ProfileScreen extends StatefulWidget {
  static const id = "/profile_page";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool isDarkMode;
  File? profileImage;
  late CollectionReference _reference;
  late String enteredWABAID;
  bool _isFetchingImage = false;
  bool _isUploadingImage = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late PointUser currentUser;
  late int pointsToRedeem;
  Timer? _appUsageTimer;

  @override
  void initState() {
    super.initState();
    isDarkMode = Get.isDarkMode;
    final wabaidController = Get.find<WABAIDController>();
    enteredWABAID = wabaidController.enteredWABAID;
    _reference = FirebaseFirestore.instance
        .collection('accounts')
        .doc(enteredWABAID)
        .collection('profileImage');

    // Fetch the last uploaded image URL from Firestore
    _fetchLastProfileImage();

    // Initialize currentUser
    currentUser = PointUser(
      id: enteredWABAID,
      name: "Ashish",
      points: 50,
    );

    // Initialize pointsToRedeem
    pointsToRedeem = 0;

    // Retrieve user data from Firebase Authentication
    // _retrieveUserData();
    // // Start tracking app usage time
    // _startAppUsageTracking();
  }

  // @override
  // void dispose() {
  //   // Cancel the timer when the widget is disposed
  //   _appUsageTimer?.cancel();
  //   super.dispose();
  // }

  // Future<void> _retrieveUserData() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     int storedPoints = prefs.getInt('user_${currentUser.id}_points') ?? 0;

  //     setState(() {
  //       currentUser.points = storedPoints;
  //     });
  //   } catch (e) {
  //     print('Error retrieving user data: $e');
  //   }
  // }

  // void _startAppUsageTracking() {
  //   // Use a timer or other mechanism to track user's time spent in the app
  //   const Duration appUsageInterval = Duration(seconds: 10);

  //   _appUsageTimer = Timer.periodic(appUsageInterval, (Timer timer) {
  //     // Check if the widget is still mounted before calling setState
  //     if (mounted && _appUsageTimer?.isActive == true) {
  //       // Add points for the user based on app usage
  //       _addPointsForAppUsage(5);
  //     }
  //   });
  // }

  // void _addPointsForAppUsage(double pointsToAdd) {
  //   setState(() {
  //     currentUser.points += pointsToAdd.toInt();
  //     _savePointsToStorage(currentUser.points);
  //   });
  // }

  // void _savePointsToStorage(int points) async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setInt('user_${currentUser.id}_points', points);
  //   } catch (e) {
  //     print('Error saving points to storage: $e');
  //   }
  // }

  // Widget _buildRedeemButton() {
  //   return ElevatedButton(
  //     onPressed: () {
  //       _showRedeemDialog();
  //     },
  //     child: const Text('Redeem Points'),
  //   );
  // }

  // Widget _buildSlider() {
  //   return StatefulBuilder(
  //     builder: (BuildContext context, StateSetter setState) {
  //       pointsToRedeem = min(currentUser.points, pointsToRedeem);

  //       // Check if there are available points to redeem
  //       if (currentUser.points > pointsToRedeem) {
  //         return Column(
  //           children: [
  //             Text(
  //                 'Points to Redeem: $pointsToRedeem'), // Display the current slider value
  //             const SizedBox(height: 10),
  //             Slider(
  //               value: pointsToRedeem.toDouble(),
  //               min: 0,
  //               max: (currentUser.points - 1).toDouble(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   pointsToRedeem =
  //                       value.clamp(0, currentUser.points - 1).toInt();
  //                 });
  //               },
  //             ),
  //           ],
  //         );
  //       } else {
  //         // Return an empty container if there are no available points
  //         return const Text("Not enough points to redeem !");
  //       }
  //     },
  //   );
  // }

  // void _showRedeemDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         alignment: Alignment.center,
  //         title: Text('Redeem Points for\n${currentUser.id}'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Available Points: ${currentUser.points}'),
  //             const SizedBox(height: 10),
  //             if (currentUser.points > 0) _buildSlider(),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           if (currentUser.points >= pointsToRedeem)
  //             ElevatedButton(
  //               onPressed: () {
  //                 if (currentUser.points >= pointsToRedeem) {
  //                   _redeemPoints(pointsToRedeem);
  //                   Navigator.of(context).pop();
  //                 } else {
  //                   Fluttertoast.showToast(
  //                     msg: 'Not enough points to redeem!',
  //                     toastLength: Toast.LENGTH_SHORT,
  //                     gravity: ToastGravity.BOTTOM,
  //                     timeInSecForIosWeb: 1,
  //                     backgroundColor: Colors.red,
  //                     textColor: Colors.white,
  //                     fontSize: 16.0,
  //                   );
  //                 }
  //               },
  //               child: const Text('Redeem'),
  //             ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _redeemPoints(int pointsToRedeem) {
  //   // Implement your logic to redeem points
  //   if (currentUser.points >= pointsToRedeem) {
  //     // Deduct points from the user's account
  //     currentUser.points -= pointsToRedeem;

  //     // Reset pointsToRedeem to a default value or 0
  //     setState(() {
  //       pointsToRedeem = 0;
  //     });

  //     // Save the updated points to storage
  //     _savePointsToStorage(currentUser.points);

  //     // Display a success message
  //     Fluttertoast.showToast(
  //       msg: 'Points redeemed successfully!',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   } else {
  //     // Display an error message, not enough points
  //     Fluttertoast.showToast(
  //       msg: 'Not enough points to redeem!',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }

  Future<void> _fetchLastProfileImage() async {
    try {
      setState(() {
        _isFetchingImage = true;
      });

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _reference
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.docs.isNotEmpty) {
        String lastImageUrl = querySnapshot.docs.first.data()['profile_Image'];
        if (lastImageUrl.isNotEmpty) {
          setState(() {
            profileImage = File(lastImageUrl);
          });
        }
      }
    } catch (e) {
      print('Error fetching last profile image: $e');
    } finally {
      setState(() {
        _isFetchingImage = false;
      });
    }
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Hero(
          tag: 'profileImage', // Unique tag for the hero animation
          createRectTween: (begin, end) {
            return RectTween(
              begin: begin,
              end: end,
            );
          },
          child: GestureDetector(
            onTap: () {
              _showProfileOptions();
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: isDarkMode
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 0, 0, 0),
              child: _buildProfileImage(),
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        // ... other widgets
      ],
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: isDarkMode
              ? null
              : const Color.fromARGB(255, 202, 181, 240), // Add this line
          child: ClipOval(
            child: _buildImageWidget(),
          ),
        ),
        if (_isUploadingImage || _isFetchingImage)
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        if (profileImage == null ||
            (!profileImage!.existsSync() &&
                !profileImage!.path.startsWith('https://')))
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (_isFetchingImage) {
      return Container(); // Return an empty container while fetching
    }

    return profileImage != null && profileImage!.existsSync()
        ? Image.file(
            profileImage!,
            fit: BoxFit.cover,
            width: 96,
            height: 96,
          )
        : (profileImage != null && !profileImage!.existsSync())
            ? Image.network(
                profileImage!.path,
                fit: BoxFit.cover,
                width: 96,
                height: 96,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                },
              )
            : SvgPicture.asset(
                "assets/person.svg",
                fit: BoxFit.cover,
                color: isDarkMode
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : const Color.fromARGB(255, 255, 255, 255),
                height: 54,
                width: 54,
              );
  }

  void _pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
        _isUploadingImage = true;
      });

      try {
        String imageUrl = await _uploadImageToStorage(File(pickedFile.path));

        if (imageUrl.isNotEmpty) {
          await _updateProfileImageInFirestore(imageUrl);

          Fluttertoast.showToast(
            msg: 'Profile image updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } finally {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<String> _uploadImageToStorage(File file) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Profile_images');

    // Create the reference for the image to be stored
    Reference referenceImageToUpload =
        referenceDirImages.child('$uniqueFileName.jpg');

    try {
      // Store the file
      await referenceImageToUpload.putFile(file);
      String imageUrl = await referenceImageToUpload.getDownloadURL();
      print('Image uploaded. URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _updateProfileImageInFirestore(String imageUrl) async {
    DateTime timestamp = DateTime.now();
    if (_reference != null) {
      Map<String, dynamic> dataToUpdate = {
        'profile_Image': imageUrl,
        'timestamp': timestamp,
      };
      await _reference.add(dataToUpdate);
    }
  }

  Future<void> _saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> _getSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ??
        false; // Default to light mode if the value is not set
  }

  void _showThemeToggleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Theme"),
          content: Row(
            children: [
              Text(
                "Light",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
                  Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  setState(() {
                    isDarkMode = value;
                  });
                },
                activeColor: Colors.blue,
                inactiveTrackColor: Colors.grey,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                "Dark",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _saveThemeMode(isDarkMode);
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showProfileOptions() {
    if (profileImage != null &&
        (profileImage!.existsSync() ||
            profileImage!.path.startsWith('https://'))) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('View Profile Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewProfilePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Change photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Profile Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProfilePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      _pickImage();
    }
  }

  void _viewProfilePhoto() {
    if (profileImage != null && profileImage!.existsSync() ||
        profileImage!.path.startsWith('https://')) {
      Get.to(() => ProfilePhotoViewPage(
            imageFile: profileImage!,
            imageUrl: profileImage!.existsSync() ? null : profileImage!.path,
          ));
    } else {
      // Handle the case where there is no profile photo available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No profile photo available.'),
        ),
      );
    }
  }

  Future<void> _deleteProfilePhoto() async {
    try {
      try {
        // Sign in before proceeding with the delete operation
        UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();

        // Check if sign-in was successful
        if (userCredential.user != null) {
          Reference referenceRoot = FirebaseStorage.instance.ref();
          Reference referenceDirImages = referenceRoot.child('Profile_images');

          // List all items in the folder
          ListResult listResult = await referenceDirImages.listAll();

          // Delete each file in the folder
          await Future.forEach(listResult.items, (Reference item) async {
            await item.delete();
          });

          print('Profile photo deleted successfully');
        } else {
          print('Error signing in before deleting profile photo');
        }
      } catch (e) {
        print('Error deleting profile photo: $e');
      }

      // Delete the documents in Firestore collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _reference.get() as QuerySnapshot<Map<String, dynamic>>;
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        await document.reference.delete();
      }

      // Update the UI
      setState(() {
        profileImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting profile photo: $e');
    }
  }

  void _copyToClipboardWABAID(BuildContext context) {
    Clipboard.setData(ClipboardData(text: enteredWABAID));

    Fluttertoast.showToast(
      msg: 'Phone number ID copied',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }

  void _copyToClipboardPhoneNumber(BuildContext context, String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber));

    Fluttertoast.showToast(
      msg: 'Phone number copied',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0,
    );
  }

  //MediaQueryData mediaQueryData = MediaQuery.of(context);
  @override
  Widget build(BuildContext context) {
    WABAIDController wabaidController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () {
                  _showThemeToggleDialog();
                  // Manually rebuild the navigation bar
                  Scaffold.of(context).setState(() {});
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const SizedBox(
              height: 20,
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: Future.value(
                                          wabaidController.enteredWABAID),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error loading WABAID: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          final enteredWABAID = snapshot.data!;
                                          return GestureDetector(
                                            onLongPress: () =>
                                                _copyToClipboardWABAID(context),
                                            child: Text(
                                              "ID: $enteredWABAID",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const Text('No WABAID found');
                                        }
                                      },
                                    ),
                                    FutureBuilder<String>(
                                      future: FirebaseAuth.instance.currentUser
                                                  ?.phoneNumber !=
                                              null
                                          ? Future.value(FirebaseAuth.instance
                                              .currentUser!.phoneNumber!)
                                          : Future.value(null),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error loading phone number: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          final phoneNumber = snapshot.data!;
                                          return GestureDetector(
                                            onLongPress: () =>
                                                _copyToClipboardPhoneNumber(
                                                    context, phoneNumber),
                                            child: Text(
                                              "Phone: $phoneNumber",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const Text(
                                              'No phone number found');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                Colors.black,
                                Colors.black,
                              ]
                            : [
                                Colors.white,
                                const Color.fromARGB(255, 61, 163, 247),
                                const Color.fromARGB(255, 21, 94, 153),
                                Colors.purple
                              ]),
                    //color: Colors.deepPurple,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        onTap: () {
                          Get.toNamed(PrivacyAndPolicyPage.id);
                        },
                        leading: Icon(
                          (Icons.info_outline),
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          "About us",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        onTap: () async {
                          await _firebaseAuth.signOut();
                          // Clear the navigation stack and push the entry point page
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const EntryPoint(),
                            ),
                            (route) => false,
                          );
                        },
                        leading: Icon(Icons.logout_outlined,
                            color: isDarkMode ? Colors.white : Colors.black),
                        title: Text(
                          "logout",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // ListTile(
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => ProblemsListPage(
                      //           enteredWABAID: enteredWABAID,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   leading: Icon(Icons.sync_problem,
                      //       color: isDarkMode ? Colors.white : Colors.black),
                      //   title: Text(
                      //     "Add problem",
                      //     style: TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.bold,
                      //       color: isDarkMode ? Colors.white : Colors.black,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 15),
                      //_buildRedeemButton(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
