import 'dart:io';

import 'package:STARZ/screens/auth/entry_point.dart';
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
  }

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
              child: ListView(children: [
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
                                // FutureBuilder<String>(
                                //   future: FirebaseAuth.instance.currentUser
                                //               ?.phoneNumber !=
                                //           null
                                //       ? Future.value(FirebaseAuth
                                //           .instance.currentUser!.phoneNumber!)
                                //       : Future.value(null),
                                //   builder: (context, snapshot) {
                                //     if (snapshot.connectionState ==
                                //         ConnectionState.waiting) {
                                //       return const CircularProgressIndicator();
                                //     } else if (snapshot.hasError) {
                                //       return Text(
                                //           'Error loading phone number: ${snapshot.error}');
                                //     } else if (snapshot.hasData) {
                                //       final phoneNumber = snapshot.data!;
                                //       return GestureDetector(
                                //         onLongPress: () =>
                                //             _copyToClipboardPhoneNumber(
                                //                 context, phoneNumber),
                                //         child: Text(
                                //           "Phone: $phoneNumber",
                                //           style: const TextStyle(
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         ),
                                //       );
                                //     } else {
                                //       return const Text(
                                //           'No phone number found');
                                //     }
                                //   },
                                // ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ]),
            )),
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
                          // Perform logout
                          await _firebaseAuth.signOut();

                          // Clear SharedPreferences data
                          // SharedPreferences prefs =
                          //     await SharedPreferences.getInstance();
                          // prefs.remove('enteredWABAID');
                          // prefs.remove('phoneNumber');

                          Get.toNamed(EntryPoint.id);
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
