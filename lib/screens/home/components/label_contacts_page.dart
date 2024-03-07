import 'dart:convert';

import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/screens/chat/chat_page.dart';
import 'package:STARZ/screens/chat/file_helper.dart';
import 'package:STARZ/widgets/label_custom_card.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart' as contacts_flutter;
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:contacts_service/contacts_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/phone_contacts/phone_contacts_page.dart';
import '../../../widgets/custom_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class LabelSearchBarController {
  late AnimationController controller;
  late Animation<double> animation;

  LabelSearchBarController(TickerProvider vsync) {
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

//Me
class LabelContactsPage extends StatefulWidget {
  LabelContactsPage({
    super.key,
    required this.enteredWABAID,
    required this.isSearchBarVisible,
    required this.selectedLabel,
    required this.labelsPageToPhoneNumbers,
    required this.wabaidController,
    required this.selectedLabelCount,
  }) {
    snapshot = FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .snapshots();
    whatsApp = WhatsAppApi();
    whatsApp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.tryParse(phoneNumberId));
    // roomId = Get.arguments['roomId'];
    // phoneNumber = Get.arguments['to'];
    // userName = Get.arguments['userName&Num'];
  }

  final String? enteredWABAID;
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool isSearchBarVisible;
  final String selectedLabel;
  final int selectedLabelCount;
  final List<dynamic> labelsPageToPhoneNumbers;
  final WABAIDController wabaidController;
  late WhatsAppApi whatsApp;
  late String phoneNumberId = wabaidController.phoneNumber;
  // late String roomId;
  // late String phoneNumber;
  // late String userName;

  @override
  State<LabelContactsPage> createState() => _LabelContactsPageState();
}

class _LabelContactsPageState extends State<LabelContactsPage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences _prefs;
  final Set<String> pinnedChats = Set<String>();
  List<String> pinnedContacts = [];
  WABAIDController wabaidController = Get.find<WABAIDController>();
  late String enteredWABAID;
  List<contacts_flutter.Contact> deviceContacts = [];
  List<contacts_flutter.Contact> filteredDeviceContacts = [];
  String searchQuery = "";
  bool isSearchBarExpanded = false;
  late LabelSearchBarController _searchBarController;
  bool isSearchBarVisible = false;
  TextEditingController _messageController = TextEditingController();
  late String phoneNumberId = wabaidController.phoneNumber;
  Set<String> _selectedContacts = Set<String>();
  bool hasContactsForLabel = false;

  _LabelContactsPageState() {
    _initPrefs(); // Initialize _prefs in the constructor
    _initializeContacts();
  }

  @override
  void initState() {
    super.initState();
    _searchBarController = LabelSearchBarController(this);
    enteredWABAID = wabaidController.enteredWABAID;
  }

  Future<List<TemplateMessage>> fetchTemplateMessages(
      String accessToken) async {
    var url =
        'https://graph.facebook.com/v19.0/$enteredWABAID/message_templates?access_token=$accessToken';
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 400) {
      print('Bad Request 1: ${response.body}');
      // Handle the error or return an empty list
      return [];
    } else if (response.statusCode == 200) {
      print('Bad Request 2: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming 'data' contains a 'messages' field with an array of messages
      if (responseData.containsKey('data')) {
        print('Bad Request 3: ${response.body}');
        final List<dynamic> templateData = responseData['data'];
        // Mapping the templates to TemplateMessage objects
        final List<TemplateMessage> templateMessages =
            templateData.map((template) {
          // Assuming you have an 'id' and 'text' field in your TemplateMessage class
          return TemplateMessage.fromJson(template);
        }).toList();

        return templateMessages;
      } else {
        print('Bad Request: No "data" field in the response');
        return [];
      }
    } else {
      print('Bad Request 5: ${response.body}');
      print('Status Code : ${response.statusCode}');
      throw Exception(
          'Failed to load template messages. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchDataAndShowDialog(String selectedLabel) async {
    try {
      List<TemplateMessage> templateMessages = await fetchTemplateMessages(
          'EAAMEyX45PoMBO18lFTrAnLeKbiDi2qJAL7Nec61OLZAayaIqcWYAczQn3jGlWuWGwWZBFOjFk1ZBTBNqhjZCZAvLpww7XlgJps4SCsKUlgDmgNZBx6hl82AQdzJCZAZB12nxyIuvKAKUNBrcNFgfbSfN6lMXxqxZBdF5carAwaQSZA2KJWZAzjAXoLBjbLJq9BkIWGa');
      _showTemplateDialog(templateMessages, selectedLabel);
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> _showTemplateDialog(
      List<TemplateMessage> templateMessages, String selectedLabel) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Message Templates',
            style: GoogleFonts.baloo2(
              textStyle: const TextStyle(
                color: Colors.green,
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: templateMessages.length,
              itemBuilder: (BuildContext context, int index) {
                final template = templateMessages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle tap event for the template
                        _openInputDialog(template, selectedLabel);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${template.name}\nID: ${template.id}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(height: 10.0),
                              if (template.imageUrl != null)
                                Container(
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: NetworkImage(template.imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: template.imageUrl != null &&
                                              template.imageUrl!
                                                  .contains(".mp4") ||
                                          template.imageUrl!.contains(".pdf")
                                      ? Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: Center(
                                            child: Text(
                                              template.imageUrl!
                                                      .contains(".mp4")
                                                  ? 'Video Preview'
                                                  : 'Document Preview',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Text: ${template.text}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              ),
                              const SizedBox(height: 10.0),
                              if (template.example != null &&
                                  template.example!.bodyText != null)
                                for (List<String> bodyText
                                    in template.example!.bodyText!)
                                  Text(
                                    'Body Text: ${bodyText.join(', ')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                              const SizedBox(height: 10.0),
                              if (template.example != null &&
                                  template.example!.footerText != null)
                                Text(
                                  'Footer Text: ${template.footerText}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.language.isNotEmpty)
                                Text(
                                  'Language: ${template.language}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.status.isNotEmpty)
                                Text(
                                  'Status: ${template.status}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.category.isNotEmpty)
                                Text(
                                  'Category: ${template.category}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openInputDialog(
      TemplateMessage template, String selectedLabel) async {
    // Check if header format is LOCATION
    if (template.components.any((component) =>
        component.type == 'HEADER' && component.format == 'LOCATION')) {
      List<TextEditingController> controllersList = [];
      // Show a dialog to enter location details
      TextEditingController latitudeController = TextEditingController();
      TextEditingController longitudeController = TextEditingController();
      TextEditingController nameController = TextEditingController();
      TextEditingController addressController = TextEditingController();

      // ignore: use_build_context_synchronously
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Location Details'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Add input fields for location details
                  TextField(
                    controller: latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                  TextField(
                    controller: longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Location Name'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration:
                        const InputDecoration(labelText: 'Location Address'),
                  ),
                  // Add input fields for bodyText if present
                  ...template.example?.bodyText
                          ?.expand((List<String> bodyText) {
                        return bodyText.map((String variable) {
                          TextEditingController controller =
                              TextEditingController();
                          // Store the controller for later use
                          controllersList.add(controller);
                          return TextField(
                            controller: controller,
                            decoration:
                                InputDecoration(labelText: 'Enter $variable'),
                          );
                        });
                      }).toList() ??
                      [],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Check if any of the fields are empty
                  if (latitudeController.text.isEmpty ||
                      longitudeController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      controllersList
                          .any((controller) => controller.text.isEmpty)) {
                    // Show a toast warning if any field is empty
                    Fluttertoast.showToast(
                      msg: 'All fields are required.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else {
                    Navigator.of(context).pop(true); // User confirmed
                  }
                },
                child: const Text('Send'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // User canceled
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      // If user canceled the confirmation, return
      if (confirm == false) {
        return;
      }

      // Extract entered values
      double latitude, longitude;
      String locationName, locationAddress;

      if (latitudeController.text.isNotEmpty &&
          longitudeController.text.isNotEmpty) {
        latitude = double.parse(latitudeController.text);
        longitude = double.parse(longitudeController.text);
      } else {
        // Handle invalid or empty latitude/longitude
        // Show an error message or return, depending on your requirements
        return;
      }

      locationName = nameController.text;
      locationAddress = addressController.text;

      // If bodyText is present, handle entered parameters
      if (template.example?.bodyText != null) {
        // Handle the entered parameters
        Map<String, String> enteredVariables = {};
        template.example!.bodyText!.forEach((List<String> bodyText) {
          bodyText.asMap().forEach((index, variable) {
            TextEditingController controller = controllersList[index];
            String enteredText = controller.text;
            enteredVariables[variable] = enteredText;
          });
        });
        for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);

          // Check if the stored label matches the current label
          if (storedLabel == selectedLabel) {
            // Call the API function with the entered values and variables
            widget.whatsApp.messagesTemplate(
              templateName: template.name,
              to: int.parse(phoneNumber),
              mediaUrl:
                  null, // Change to the actual mediaUrl or set it to null if not applicable
              text: "",
              location: {
                'latitude': latitude,
                'longitude': longitude,
                'name': locationName,
                'address': locationAddress,
              },
              variables: enteredVariables,
              language: template.language,
              templateHeaderFormat: template.components.firstWhereOrNull(
                (component) => component.type == 'HEADER',
              ),
            );
          }
        }
      } else {
        for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);

          // Check if the stored label matches the current label
          if (storedLabel == selectedLabel) {
            // Call the API function without bodyText
            widget.whatsApp.messagesTemplate(
              templateName: template.name,
              to: int.parse(phoneNumber),
              mediaUrl:
                  null, // Change to the actual mediaUrl or set it to null if not applicable
              text: "",
              location: {
                'latitude': latitude,
                'longitude': longitude,
                'name': locationName,
                'address': locationAddress,
              },
              variables: {},
              language: template.language,
              templateHeaderFormat: template.components.firstWhereOrNull(
                (component) => component.type == 'HEADER',
              ),
            );
          }
        }
      }
    } else
    // Check if bodyText is not null or empty
    if (template.example?.bodyText == null ||
        template.example!.bodyText!.isEmpty) {
      // Check if header format is IMAGE or VIDEO
      if (template.components.any((component) =>
          component.type == 'HEADER' &&
          (component.format == 'IMAGE' ||
              component.format == 'VIDEO' ||
              component.format == 'DOCUMENT' ||
              component.format == 'LOCATION'))) {
        // Show a dialog to enter the image URL
        TextEditingController imageUrlController = TextEditingController();
        // ignore: use_build_context_synchronously
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter Image/Video URL'),
              content: TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image/Video URL'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Check if the image URL is empty
                    if (imageUrlController.text.isEmpty) {
                      // Show a toast warning if the image URL is empty
                      Fluttertoast.showToast(
                        msg: 'Image/Video URL is required.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    } else {
                      Navigator.of(context).pop(true); // User confirmed
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);

          // Check if the stored label matches the current label
          if (storedLabel == selectedLabel) {
            // Send the template with the entered image/video URL
            widget.whatsApp.messagesTemplate(
              templateName: template.name,
              to: int.parse(phoneNumber),
              mediaUrl: imageUrlController.text,
              text: "",
              variables: {}, // No variables for templates without bodyText
              language: template.language,
              templateHeaderFormat: template.components.firstWhereOrNull(
                (component) =>
                    component.type == 'HEADER' &&
                    (component.format == 'IMAGE' ||
                        component.format == 'VIDEO'),
              ),
            );
          }
        }
      } else if (template.components.any((component) =>
          component.type == 'HEADER' && component.format == 'TEXT')) {
        // Show a confirmation dialog
        // ignore: use_build_context_synchronously
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'Are you sure to send this message template?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);

          // Check if the stored label matches the current label
          if (storedLabel == selectedLabel) {
            // Send the template without an image URL
            widget.whatsApp.messagesTemplate(
              templateName: template.name,
              to: int.parse(phoneNumber),
              mediaUrl: null,
              text: "",
              variables: {}, // No variables for templates without bodyText
              language: template.language,
              templateHeaderFormat: template.components.firstWhereOrNull(
                (component) => component.type == 'HEADER',
              ),
            );
          }
        }
      } else {
        // The template doesn't have a 'HEADER' component
        // Show a confirmation dialog
        // ignore: use_build_context_synchronously
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'Do you want to send this template?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);

          // Check if the stored label matches the current label
          if (storedLabel == selectedLabel) {
            // Send the template without a 'HEADER' component
            widget.whatsApp.messagesTemplate(
              templateName: template.name,
              to: int.parse(phoneNumber),
              mediaUrl: null,
              text: "",
              variables: {}, // No variables for templates without bodyText
              language: template.language,
              templateHeaderFormat:
                  null, // Set to null for templates without 'HEADER'
            );
          }
        }
      }
    } else {
      List<TextEditingController> controllersList = [];

      // Create controllers for variables and imageUrl
      TextEditingController imageUrlController = TextEditingController();
      controllersList.add(imageUrlController);

      // Create a map to store the entered variables
      Map<String, String> enteredVariables = {};

      String? enteredImageUrl;

      List<Widget> inputFields = [];

// Add an input field for imageUrl only if header format is not 'TEXT'
      if (template.components.any((component) =>
          component.type == 'HEADER' &&
          (component.format == 'IMAGE' ||
              component.format == 'VIDEO' ||
              component.format == 'DOCUMENT' ||
              component.format == 'LOCATION'))) {
        inputFields.add(
          TextField(
            controller: imageUrlController,
            onChanged: (value) {
              setState(() {
                // Update the enteredImageUrl when the text changes
                enteredImageUrl = value.isNotEmpty ? value : null;
              });
            },
            decoration: const InputDecoration(labelText: 'Enter Media URL'),
          ),
        );
      }

// Show input fields for bodyText variables
      inputFields.addAll(
        template.example?.bodyText?.expand((List<String> bodyText) {
              return bodyText.map((String variable) {
                // Create a TextEditingController for each variable
                TextEditingController controller = TextEditingController();
                controllersList.add(controller);

                return TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Enter $variable'),
                );
              });
            }).toList() ??
            [],
      );

      // ignore: use_build_context_synchronously
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Parameters for ${template.name} Template'),
            content:
                // StatefulBuilder(
                //   builder: (context, setState) {
                //     return
                SingleChildScrollView(
              child: Column(
                children: inputFields,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Check if the template has body text parameters
                  bool hasBodyTextParameters =
                      template.example?.bodyText?.isNotEmpty ?? false;

// Check if any of the bodyText controllers are empty
                  bool anyFieldEmpty = hasBodyTextParameters
                      ? controllersList
                          .sublist(1)
                          .any((controller) => controller.text.isEmpty)
                      : false;

                  // Check if the imageUrl controller is empty
                  bool imageUrlEmpty = template.components.any((component) =>
                          component.type == 'HEADER' &&
                          (component.format == 'IMAGE' ||
                              component.format == 'VIDEO' ||
                              component.format == 'DOCUMENT' ||
                              component.format == 'LOCATION'))
                      ? imageUrlController.text.isEmpty
                      : false;

                  // Check the values and conditions
                  print('anyFieldEmpty: $anyFieldEmpty');
                  print(
                      'imageUrlController.text: "${imageUrlController.text}"');
                  print(
                      'bodyText controllers: ${controllersList.sublist(1).map((c) => c.text).toList()}');

                  if (imageUrlEmpty && !hasBodyTextParameters) {
                    // Do not show a toast warning if there are no parameters to fill
                  } else if (imageUrlEmpty && hasBodyTextParameters) {
                    // Show a toast warning if there are bodyText parameters and imageUrl is empty
                    Fluttertoast.showToast(
                      msg: 'Please fill in the Media URL field.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (anyFieldEmpty) {
                    // Show a toast warning if any bodyText field is empty
                    Fluttertoast.showToast(
                      msg: 'Please fill in all the fields.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    // Handle the entered parameters
                    List<List<String>> enteredParameters = [];
                    template.example?.bodyText
                        ?.forEach((List<String> bodyText) {
                      List<String> enteredTexts = [];
                      bodyText.forEach((variable) {
                        // Get the value from the corresponding TextEditingController
                        TextEditingController controller =
                            controllersList.removeAt(1);
                        String enteredText = controller.text;
                        enteredTexts.add(enteredText);

                        // Store the entered variable and its value
                        enteredVariables[variable] = enteredText;
                      });
                      enteredParameters.add(enteredTexts);
                    });

                    // Get the imageUrl from its controller
                    String imageUrl = imageUrlController.text;

                    // Print or use the entered parameters
                    print('Entered Parameters: $enteredParameters');
                    print('Entered Image URL: $imageUrl');

                    for (String phoneNumber
                        in widget.labelsPageToPhoneNumbers) {
                      String key =
                          '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
                      String? storedLabel = _prefs.getString(key);

                      // Check if the stored label matches the current label
                      if (storedLabel == selectedLabel) {
                        // Pass the entered variables to messagesTemplate
                        widget.whatsApp.messagesTemplate(
                            templateName: template.name,
                            to: int.parse(phoneNumber),
                            mediaUrl: imageUrl,
                            text: "",
                            variables: enteredVariables,
                            language: template.language,
                            templateHeaderFormat: template.components
                                .firstWhereOrNull(
                                    (component) => component.type == 'HEADER'));
                      }
                    }

                    // // Send message with image using the entered image URL
                    // await sendMessageWithImage(
                    //   imageUrl,
                    //   template.text,
                    //   template.footerText ?? "",
                    // );

                    // Close the dialog
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _initializeContacts() async {
    await _getDeviceContacts();
    setState(() {}); // Trigger UI update after fetching device contacts
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPinnedChats();
  }

  Future<void> _loadPinnedChats() async {
    final List<String> pinnedChatsList =
        _prefs.getStringList('${widget.enteredWABAID}_pinnedChats') ?? [];
    setState(() {
      pinnedChats.addAll(pinnedChatsList);
    });
  }

  Future<void> _savePinnedChats() async {
    await _prefs.setStringList(
        '${widget.enteredWABAID}_pinnedChats', pinnedChats.toList());
  }

  Future<void> _getDeviceContacts() async {
    if (await flutter_contacts.FlutterContacts.requestPermission()) {
      deviceContacts = await flutter_contacts.FlutterContacts.getContacts(
          withProperties: true);
      filteredDeviceContacts = List.from(deviceContacts);
    }
  }

  void updateFilteredDeviceContacts(String query) {
    searchQuery = query; // Update the searchQuery
    if (deviceContacts.isNotEmpty) {
      filteredDeviceContacts = deviceContacts
          .where((contact) =>
              contact.displayName!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (contact.phones.isNotEmpty &&
                  contact.phones.first.number
                      .toLowerCase()
                      .contains(query.toLowerCase())))
          .toList();
    } else {
      filteredDeviceContacts.clear();
    }
    setState(() {});
  }

  Future<Timestamp?> getLastMessageTimestamp(String roomId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("accounts")
              .doc(widget.enteredWABAID)
              .collection("discussion")
              .doc(roomId)
              .collection("messages")
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> lastMessage =
            querySnapshot.docs.first;
        return lastMessage['timestamp'] as Timestamp?;
      } else {
        return null; // No messages found
      }
    } catch (e) {
      print("Error fetching last message timestamp: $e");
      return null;
    }
  }

  String getContactNameForNumber(String phoneNumber) {
    // Remove non-numeric characters from phone numbers
    String sanitizedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Iterate through device contacts to find matching phone number
    for (final contact in deviceContacts) {
      if (contact.phones.isNotEmpty &&
          contact.phones.first.number?.replaceAll(RegExp(r'\D'), '') ==
              sanitizedPhoneNumber) {
        return contact.displayName ?? "";
      }
    }
    return ""; // Return empty string if no matching contact is found
  }

  // Future<List<Widget>> fetchAndSortData(
  //     QuerySnapshot<Map<String, dynamic>> snapshot, String searchQuery) async {
  //   List<Widget> widgets = [];

  //   for (int i = 0; i < snapshot.size; i++) {
  //     String user = snapshot.docs[i].data()['client'];
  //     String roomId = snapshot.docs[i].id;

  //     // Fetch last message timestamp for each contact
  //     Timestamp? lastMessageTimestamp = await getLastMessageTimestamp(roomId);

  //     // Determine if the chat is pinned
  //     bool isPinned = pinnedChats.contains(roomId);

  //     String contactName = await getContactNameForNumber(user);

  //     if (contactName.toLowerCase().contains(searchQuery.toLowerCase()) ||
  //         user.toLowerCase().contains(searchQuery.toLowerCase())) {
  //       widgets.add(CustomCard(
  //         wabaidController: wabaidController,
  //         roomId: snapshot.docs[i].id,
  //         toPhoneNumber: contactName.isNotEmpty ? contactName : user,
  //         lastMessageTimestamp: lastMessageTimestamp,
  //         isPinned: isPinned,
  //         onLongPress: () {
  //           print('Long press detected on $roomId');
  //           togglePin(roomId, isPinned);
  //         },
  //         onPinToggle: (bool isPinned) {
  //           togglePin(roomId, isPinned);
  //         },
  //       ));
  //     }
  //   }

  //   widgets.sort((a, b) {
  //     Timestamp? timestampA = (a as CustomCard).lastMessageTimestamp;
  //     Timestamp? timestampB = (b as CustomCard).lastMessageTimestamp;

  //     // Pinned chats appear first
  //     if (pinnedChats.contains(a.roomId) && !pinnedChats.contains(b.roomId)) {
  //       return -1;
  //     } else if (!pinnedChats.contains(a.roomId) &&
  //         pinnedChats.contains(b.roomId)) {
  //       return 1;
  //     }

  //     if (timestampA == null && timestampB == null) {
  //       return 0;
  //     } else if (timestampA == null) {
  //       return 1;
  //     } else if (timestampB == null) {
  //       return -1;
  //     }

  //     return timestampB.compareTo(timestampA);
  //   });

  //   // for (final contact in filteredDeviceContacts) {
  //   //   widgets.add(
  //   //     ListTile(
  //   //       title: Text("${contact.displayName}"),
  //   //       subtitle: Text(
  //   //         contact.phones.isNotEmpty
  //   //             ? contact.phones.first.number?.toString() ?? "No phone number"
  //   //             : "No phone number",
  //   //         style: const TextStyle(fontSize: 16),
  //   //       ),
  //   //       // Add any other UI elements or functionality as needed
  //   //     ),
  //   //   );
  //   // }

  //   return widgets;
  // }

  Future<void> togglePin(String roomId, bool isPinned) async {
    print('Toggling pin for chat $roomId');

    if (isPinned) {
      pinnedChats.remove(roomId);
    } else {
      pinnedChats.add(roomId);
    }

    await _savePinnedChats();
    setState(() {}); // Trigger UI update
    print('Pinned chats: $pinnedChats');
    // Optionally, you can update the UI or perform any other actions
  }

  Color _getLabelColor(String label) {
    Map<String, Color> labelColors = {
      'New Customer': Colors.blue,
      'New Order': Colors.green,
      'Pending Payment': Colors.orange,
      'Paid': Colors.teal,
      'Order Complete': Colors.purple,
      'Important': Colors.red,
      'Follow Up': Colors.indigo,
      'Lead': Colors.amber,
    };

    return labelColors[label] ?? Colors.black;
  }

  void toggleSearchBarVisibility() {
    setState(() {
      isSearchBarVisible = !isSearchBarVisible;
    });
  }

  void _toggleSearchBar() {
    toggleSearchBarVisibility();
  }

  void sendMessage(String message, String selectedLabel, String phoneNumber) {
    setMessage(message, selectedLabel, phoneNumber);
    // Set the flag to true when a new message is added
    //shouldScrollToBottom = true;
  }

  void setMessage(
      String message, String selectedLabel, String phoneNumber) async {
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var response = await widget.whatsApp.messagesText(
      message: message,
      to: int.parse(phoneNumber),
    );

    print('+++ RESPONSE NORMAL $response');
    if (response != null && response.containsKey('messages')) {
      var messagesList = response['messages'];

      if (messagesList != null && messagesList.isNotEmpty) {
        var messageId = messagesList[0]['id'];

        await FirebaseFirestore.instance
            .collection("accounts")
            .doc(enteredWABAID)
            .collection("discussion")
            .doc(phoneNumber)
            .collection("messages")
            .add({
          "from": phoneNumberId,
          "id": messageId,
          "text": {"body": message},
          "type": "text",
          "timestamp": DateTime.now(),
          "fcmToken": fcmToken,
        });
      } else {
        print('Error: messages list is empty or null');
      }
    } else {
      print('Error: response is null or does not contain key "messages"');
    }
  }

  bool _areAllContactsSelected() {
    return _selectedContacts.length ==
        widget.labelsPageToPhoneNumbers.where((phoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel = _prefs.getString(key);
          return storedLabel == widget.selectedLabel;
        }).length;
  }

  void _selectAllContacts(bool value) {
    //setState(() {
    if (value) {
      _selectedContacts.clear(); // Clear existing contacts before adding
      for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
        String key =
            '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
        String? storedLabel = _prefs.getString(key);

        if (storedLabel == widget.selectedLabel) {
          _selectedContacts.add(phoneNumber.toString());
        }
      }
    } else {
      _selectedContacts.clear();
    }
    //});
  }

  void _showTextInputDialog(String selectedLabel) {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            // FocusScope handles keyboard behavior
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                insetPadding: EdgeInsets.zero, // Remove default padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16.0), // Set border radius
                ),
                title: Text(
                  'Broadcast message - $selectedLabel',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Select All',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Checkbox(
                                value: _areAllContactsSelected(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectAllContacts(value!);
                                  });
                                },
                              ),
                            ),
                            // Phone numbers ListTile
                            ...widget.labelsPageToPhoneNumbers.map(
                              (phoneNumber) {
                                String key =
                                    '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
                                String? storedLabel = _prefs.getString(key);
                                String contactName =
                                    getContactNameForNumber(phoneNumber);

                                if (storedLabel == selectedLabel &&
                                    (contactName.toLowerCase().contains(
                                            searchQuery.toLowerCase()) ||
                                        phoneNumber.toLowerCase().contains(
                                            searchQuery.toLowerCase()))) {
                                  return ListTile(
                                    title: Text(
                                      contactName.isNotEmpty
                                          ? contactName
                                          : phoneNumber.toString(),
                                      style: GoogleFonts.nunito(fontSize: 18),
                                    ),
                                    dense: true,
                                    trailing: Checkbox(
                                      value: _selectedContacts
                                          .contains(phoneNumber),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value != null) {
                                            if (value) {
                                              _selectedContacts
                                                  .add(phoneNumber);
                                            } else {
                                              _selectedContacts
                                                  .remove(phoneNumber);
                                            }
                                          }
                                        });
                                      },
                                      checkColor: Colors
                                          .white, // Color of the check icon
                                      activeColor: Colors
                                          .blue, // Color of the checkbox when checked
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message..',
                        hintStyle: GoogleFonts.nunito(
                          color: Colors.grey,
                        ),
                        errorText: _messageController.text.isEmpty
                            ? 'Required*'
                            : null,
                      ),
                      onChanged: (value) {
                        // Remove error text when the user types at least one character
                        if (value.isNotEmpty) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            _selectedContacts.clear();
                            _messageController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .red.shade300, // Change cancel button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Check if at least one checkbox is checked
                            if (_selectedContacts.isEmpty) {
                              // Show an alert or take appropriate action
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Warning',
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'Please select at least one contact!',
                                      style: GoogleFonts.nunito(),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.blue, // Button color
                                        ),
                                        child: Text(
                                          'OK',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (_messageController.text.isEmpty) {
                              // Show error text for empty message
                              setState(() {});
                            } else {
                              for (String phoneNumber in _selectedContacts) {
                                sendMessage(
                                  _messageController.text,
                                  selectedLabel,
                                  phoneNumber,
                                );
                              }
                              Navigator.pop(context); // Close the dialog
                              _selectedContacts.clear();
                              _messageController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green.shade500, // Change cancel button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Send',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showMessageOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.message,
                  color: Colors.blue,
                ),
                title: const Text(
                  'Text message',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
                    String key =
                        '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
                    String? storedLabel = _prefs.getString(key);

                    // Check if the stored label matches the current label
                    if (storedLabel == widget.selectedLabel) {
                      Navigator.pop(context); // Close the options popup
                      _showTextInputDialog(widget.selectedLabel);
                      hasContactsForLabel =
                          true; // Set the flag to true when a contact is found
                      break;
                    }
                  }
                  // Show the toast warning if no contacts were found for the label
                  if (!hasContactsForLabel) {
                    print(
                        '++++++++++++No Contacts Available+++++++++++++++++++');
                    Fluttertoast.showToast(
                      msg: "No contacts available for this label",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.telegram_rounded,
                  color: Colors.green,
                ),
                title: const Text(
                  'Message template',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  for (String phoneNumber in widget.labelsPageToPhoneNumbers) {
                    String key =
                        '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
                    String? storedLabel = _prefs.getString(key);

                    // Check if the stored label matches the current label
                    if (storedLabel == widget.selectedLabel) {
                      Navigator.pop(context); // Close the options popup
                      fetchDataAndShowDialog(widget.selectedLabel);
                      hasContactsForLabel =
                          true; // Set the flag to true when a contact is found
                      break;
                    }
                  }
                  // Show the toast warning if no contacts were found for the label
                  if (!hasContactsForLabel) {
                    print(
                        '++++++++++++No Contacts Available+++++++++++++++++++');
                    Fluttertoast.showToast(
                      msg: "No contacts available for this label",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMoreOptionSelected(String option) {
    if (option == 'Message customers') {
      _showMessageOptionsDialog();
    } else if (option == 'Labels') {
      navigator?.pop(context);
    }
    // Add other menu options as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: Colors.black12,
        leadingWidth: 25,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getLabelColor(widget.selectedLabel),
              child: const Icon(
                Icons.label,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.selectedLabelCount} ${widget.selectedLabelCount == 1 ? 'contact' : 'contacts'}',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
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
                  value: 'Message customers',
                  child: Text('Message customers'),
                ),
                const PopupMenuItem<String>(
                  value: 'Labels',
                  child: Text('Labels'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSearchBarVisible)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      updateFilteredDeviceContacts(value);
                    },
                  ),
                ),
              ),
            const SizedBox(
                height: 19), // Adjust the height according to your preference
            Padding(
              padding:
                  const EdgeInsets.only(left: 19), // Adjust the left padding
              child: Text(
                'Chats',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 9),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: widget.snapshot,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData && snapshot.data != null) {
                    QuerySnapshot<Map<String, dynamic>> data = snapshot.data!;
                    if (data.docs.isEmpty && filteredDeviceContacts.isEmpty) {
                      return const Center(
                        child: Text('There are no current discussions'),
                      );
                    }

                    Future<List<Widget>> buildWidgets(
                        QuerySnapshot<Map<String, dynamic>> data) async {
                      List<Widget> widgets =
                          await Future.wait(data.docs.map((doc) async {
                        String user = doc.data()['client'];
                        String roomId = doc.id;

                        // Fetch last message timestamp for each contact
                        Timestamp? lastMessageTimestamp =
                            await getLastMessageTimestamp(roomId);

                        // Determine if the chat is pinned
                        bool isPinned = pinnedChats.contains(roomId);

                        String contactName =
                            await getContactNameForNumber(user);

                        // Check if the contact has the selected label
                        String key =
                            '${user}_${widget.wabaidController.phoneNumber}_label';
                        String? storedLabel =
                            widget.labelsPageToPhoneNumbers.contains(user)
                                ? _prefs.getString(key)
                                : null;

                        if (storedLabel == widget.selectedLabel &&
                            (contactName
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()) ||
                                user
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase()))) {
                          return LabelCustomCard(
                            wabaidController: wabaidController,
                            roomId: roomId,
                            toPhoneNumber: user,
                            savedContactName:
                                contactName.isNotEmpty ? contactName : user,
                            lastMessageTimestamp: lastMessageTimestamp,
                            isPinned: isPinned,
                            onLongPress: () {
                              print('Long press detected on $roomId');
                              togglePin(roomId, isPinned);
                            },
                            onPinToggle: (bool isPinned) {
                              togglePin(roomId, isPinned);
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      }));

                      // Sort only the CustomCard instances
                      widgets = widgets.whereType<LabelCustomCard>().toList();

                      // Sort based on last message timestamp
                      widgets.sort((a, b) {
                        Timestamp? timestampA =
                            (a as LabelCustomCard).lastMessageTimestamp;
                        Timestamp? timestampB =
                            (b as LabelCustomCard).lastMessageTimestamp;

                        // Pinned chats appear first
                        if (pinnedChats.contains(a.roomId) &&
                            !pinnedChats.contains(b.roomId)) {
                          return -1;
                        } else if (!pinnedChats.contains(a.roomId) &&
                            pinnedChats.contains(b.roomId)) {
                          return 1;
                        }

                        if (timestampA == null && timestampB == null) {
                          return 0;
                        } else if (timestampA == null) {
                          return 1;
                        } else if (timestampB == null) {
                          return -1;
                        }

                        return timestampB.compareTo(timestampA);
                      });

                      return widgets;
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          FutureBuilder<List<Widget>>(
                            future: buildWidgets(data),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                List<Widget> widgets = snapshot.data!;
                                if (widgets.isEmpty) {
                                  // No contacts found for the selected label and search query
                                  return Center(
                                    child: Text(
                                      'No contacts',
                                      style: GoogleFonts.nunito(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: widgets,
                                );
                              } else {
                                // Use shimmer loading placeholders
                                return Shimmer.fromColors(
                                  baseColor: Get.isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!,
                                  highlightColor: Get.isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[200]!,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        child: ListView.builder(
                                          itemCount:
                                              50, // You can adjust the number of placeholders
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              leading: CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Get.isDarkMode
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[300],
                                              ),
                                              title: Container(
                                                height: 16,
                                                width: 100,
                                                color: Get.isDarkMode
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[300],
                                              ),
                                              subtitle: Container(
                                                height: 12,
                                                width: 100,
                                                color: Get.isDarkMode
                                                    ? Colors.grey[800]!
                                                    : Colors.grey[300],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                }
                // Use shimmer loading placeholders
                return Shimmer.fromColors(
                  baseColor:
                      Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      Get.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: ListView.builder(
                          itemCount:
                              50, // You can adjust the number of placeholders
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Get.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300],
                              ),
                              title: Container(
                                height: 16,
                                width: 200,
                                color: Get.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300],
                              ),
                              subtitle: Container(
                                height: 12,
                                width: 100,
                                color: Get.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[300],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
