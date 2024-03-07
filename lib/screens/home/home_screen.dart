import 'dart:io';
import 'dart:typed_data';

import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/home/components/labels_page.dart';
import 'package:STARZ/screens/home/components/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/contacts_page.dart';
//import 'package:starz/screens/auth/entry_point.dart';

class SearchBarController {
  late AnimationController controller;
  late Animation<double> animation;

  SearchBarController(TickerProvider vsync) {
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  static const id = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late bool isDarkMode;
  late TextEditingController _greetingMessageController;
  late SharedPreferences _prefs;
  String? _greetingMessage;
  String? _selectedLabel;
  late String enteredWABAID;
  late CollectionReference _reference;
  // late AnimationController _searchBarController;
  // late Animation<double> _searchBarAnimation;
  late SearchBarController _searchBarController;
  bool isSearchBarVisible = false;
  final DarkModeController darkModeController = DarkModeController();
  WABAIDController wabaidController = Get.find<WABAIDController>();
  //GlobalKey<FormState> key = GlobalKey();
  // final CollectionReference _reference = FirebaseFirestore.instance
  //     .collection('accounts')
  //     .doc(enteredWABAID)
  //     .collection("discussion");
  // Add a list of labels that you want to show in the dialog
  List<String> labels = [
    'New Customer',
    'New Order',
    'Pending Payment',
    'Paid',
    'Order Complete',
    'Important',
    'Follow Up',
    'Lead',
  ];

  @override
  void initState() {
    super.initState();
    isDarkMode = Get.isDarkMode;
    final wabaidController = Get.find<WABAIDController>();
    enteredWABAID = wabaidController.enteredWABAID;
    _reference = FirebaseFirestore.instance
        .collection('accounts')
        .doc(enteredWABAID)
        .collection('templates');
    _greetingMessageController = TextEditingController();
    _loadGreetingMessage();

    _searchBarController = SearchBarController(this);
  }

  Future<void> _loadGreetingMessage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _greetingMessage = _prefs.getString('greeting_message');
    });
  }

  Future<void> _saveGreetingMessage(String message) async {
    await _prefs.setString('greeting_message', message);
    _loadGreetingMessage();
  }

  Future<void> _deleteGreetingMessage() async {
    await _prefs.remove('greeting_message');
    _loadGreetingMessage();
  }

  Future<void> _showGreetingInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Greeting Message'),
          content: TextField(
            controller: _greetingMessageController,
            decoration:
                const InputDecoration(labelText: 'Type your greeting message'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveGreetingMessage(_greetingMessageController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _showLabelInputDialog() async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Choose Label'),
  //         content: Column(
  //           children: [
  //             for (var label in labels)
  //               RadioListTile<String>(
  //                 title: Text(label),
  //                 value: label,
  //                 groupValue: _selectedLabel,
  //                 onChanged: (value) {
  //                   setState(() {
  //                     _selectedLabel = value;
  //                   });
  //                 },
  //               ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Handle the selected label
  //               if (_selectedLabel != null) {
  //                 // Implement the logic to apply the label to contacts
  //                 // For example, you can call a method to apply the label.
  //                 applyLabelToContacts(_selectedLabel!);
  //               }
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Apply'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void applyLabelToContacts(String label) {
  //   // Implement the logic to apply the label to contacts.
  //   // For example, update the database or make API calls.
  //   print('Label applied: $label');
  // }

  void _onMoreOptionSelected(String option) {
    if (option == 'Greeting Message') {
      _showGreetingInputDialog();
    } else if (option == 'theme') {
      _showThemeSelectionDialog();
    } else if (option == 'Labels') {
      navigateToLabelsPage(context);
    } else if (option == 'Customize Template') {
      _showCustomizationDialog();
    }
    // Add other menu options as needed
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: const Text('Light Theme'),
                    value: false,
                    groupValue: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Dark Theme'),
                    value: true,
                    groupValue: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.changeTheme(
                    isDarkMode ? ThemeData.dark() : ThemeData.light());
                Get.changeThemeMode(
                    isDarkMode ? ThemeMode.dark : ThemeMode.light);
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCustomizationDialog() async {
    TextEditingController headerController = TextEditingController();
    TextEditingController bodyController = TextEditingController();
    TextEditingController footerController = TextEditingController();
    String messageType = 'Text';
    String imageUrl = '';

    final GlobalKey<FormState> key = GlobalKey<FormState>();

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Customize Template Message'),
                content: Form(
                  key: key, // Associate the key with the Form widget
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: messageType,
                        onChanged: (String? newValue) {
                          setState(() {
                            messageType = newValue!;
                          });
                        },
                        items: <String>['Text', 'Media']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      // Input field based on selected content type
                      if (messageType == 'Text')
                        TextFormField(
                          controller: headerController,
                          decoration:
                              const InputDecoration(labelText: 'Header'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a header';
                            }
                            return null;
                          },
                        )
                      else if (messageType == 'Media')
                        ElevatedButton(
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            XFile? file = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            print('${file?.path}');

                            if (file == null) return;

                            String uniqueFileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            //Get a reference to storage root
                            Reference referenceRoot =
                                FirebaseStorage.instance.ref();
                            Reference referenceDirImages =
                                referenceRoot.child('images');

                            //Create the reference for the image to be stored
                            Reference referenceImageToUpload =
                                referenceDirImages.child('$uniqueFileName.jpg');

                            try {
                              //Store the file
                              await referenceImageToUpload
                                  .putFile(File(file!.path));
                              imageUrl =
                                  await referenceImageToUpload.getDownloadURL();
                              // Now you can use 'imageUrl' for further processing
                              print('Image uploaded. URL: $imageUrl');
                            } catch (e) {
                              print('Error uploading image: $e');
                            }
                          },
                          child: const Text('Select Media'),
                        ),
                      TextFormField(
                        controller: bodyController,
                        decoration: const InputDecoration(labelText: 'Body'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a body';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: footerController,
                        decoration: const InputDecoration(labelText: 'Footer'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a footer';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (imageUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please upload an image')));

                        return;
                      }

                      if (key.currentState!.validate()) {
                        String body = bodyController.text;
                        String footer = footerController.text;

                        DateTime timestamp = DateTime.now();

                        //Create a Map of data
                        Map<String, dynamic> dataToSend = {
                          'image': imageUrl,
                          'templateBody': body,
                          'templateFooter': footer,
                          'type': 'template',
                          'timestamp': timestamp,
                        };

                        //Add a new item
                        _reference.add(dataToSend);

                        // Show the template message
                        await _showTemplateMessage(imageUrl, body, footer);

                        // Close the dialog
                        //Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        });
  }

  Future<void> _showTemplateMessage(
      String imageUrl, String body, String footer) async {
    try {
      http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Template Message',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template message card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xffdcf8c6), // Customize the card background color
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(imageBytes,
                                width: double.infinity),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  body,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black, // Customize text color
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  footer,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey, // Customize text color
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Modify'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context); // Show the customization dialog
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // void _saveTemplateMessage(String header, String body, String footer) {
  //   String templateMessage = "$header\n$body\n$footer";
  //   _saveGreetingMessage(templateMessage);
  // }

  void toggleSearchBarVisibility() {
    setState(() {
      isSearchBarVisible = !isSearchBarVisible;
    });
  }

  void _toggleSearchBar() {
    toggleSearchBarVisibility();
  }

  Future<List> fetchPhoneNumbers() async {
    // Replace with your Firestore logic to fetch phone numbers
    // Example: Fetch phone numbers from the "discussion" collection
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .get();

    List phoneNumbers = snapshot.docs.map((doc) {
      return doc.data()['client'];
    }).toList();

    print('List of phone numbers : $phoneNumbers');

    return phoneNumbers;
  }

  void navigateToLabelsPage(BuildContext context) async {
    List phoneNumbers = await fetchPhoneNumbers();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabelsPage(
          toPhoneNumber: phoneNumbers, wabaidController: wabaidController,
          isSearchBarVisible: isSearchBarVisible,
          // Add other required parameters as needed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract the enteredWABAID argument
    final enteredWABAID = ModalRoute.of(context)?.settings.arguments;

    // Ensure that enteredWABAID is a String
    final String? enteredWABAIDString =
        enteredWABAID is String ? enteredWABAID : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STARZ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: isDarkMode
            ? const Color.fromARGB(1, 39, 52, 67)
            : const Color.fromARGB(255, 107, 74, 207),
        actions: <Widget>[
          IconButton(
            icon: AnimatedBuilder(
              animation: _searchBarController.animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0.0 *
                        (1.0 -
                            _searchBarController
                                .animation.value), // Adjusted offset
                    0.0,
                  ),
                  child: const Icon(Icons.search),
                );
              },
            ),
            onPressed: () {
              _toggleSearchBar();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _onMoreOptionSelected,
            offset: const Offset(0, 55),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Greeting Message',
                  child: Text('Greeting Message'),
                ),
                const PopupMenuItem<String>(
                  value: 'Labels',
                  child: Text('Labels'),
                ),
                // const PopupMenuItem<String>(
                //   value: 'theme',
                //   child: Text('Theme'),
                // ),
              ];
            },
          ),
          if (_greetingMessage != null)
            IconButton(
              icon: const Icon(Icons.subject_sharp),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GreetingMessagePage(
                      onDelete: _deleteGreetingMessage,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: ContactsPage(
        enteredWABAID: enteredWABAIDString,
        isSearchBarVisible: isSearchBarVisible,
      ),
    );
  }
}

class GreetingMessagePage extends StatefulWidget {
  final VoidCallback onDelete;

  const GreetingMessagePage({
    Key? key,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<GreetingMessagePage> createState() => _GreetingMessagePageState();
}

class _GreetingMessagePageState extends State<GreetingMessagePage> {
  late TextEditingController _editingController;
  late SharedPreferences _prefs;
  String? _greetingMessage;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _loadGreetingMessage();
  }

  Future<void> _loadGreetingMessage() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _greetingMessage = _prefs.getString('greeting_message');
      _editingController.text = _greetingMessage ?? '';
    });
  }

  Future<void> _saveGreetingMessage(String message) async {
    await _prefs.setString('greeting_message', message);
    _loadGreetingMessage();
  }

  Future<void> _confirmDelete() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this greeting message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel the delete action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDelete(); // Confirm and perform the delete action
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the GreetingMessagePage
              },
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Greeting Message'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text(
                'Saved Greeting Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_greetingMessage ?? ''),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle edit action
                    // For example, you can open a dialog to edit the message
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Edit Greeting Message'),
                          content: TextField(
                            controller: _editingController,
                            decoration: const InputDecoration(
                              labelText: 'Type your greeting message',
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _saveGreetingMessage(_editingController.text);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle delete action
                    _confirmDelete();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
