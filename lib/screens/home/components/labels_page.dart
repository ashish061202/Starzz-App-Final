import 'dart:convert';

import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/chat/chat_page.dart';
import 'package:STARZ/screens/home/components/contacts_page.dart';
import 'package:STARZ/screens/home/components/label_contacts_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LabelsPage extends StatefulWidget {
  static const id = "/labels";

  LabelsPage(
      {super.key,
      required this.wabaidController,
      required this.toPhoneNumber,
      required this.isSearchBarVisible}) {
    whatsApp = WhatsAppApi();
    whatsApp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.tryParse(phoneNumberId));
  }

  final WABAIDController wabaidController;
  final List<dynamic> toPhoneNumber;
  late WhatsAppApi whatsApp;
  late String phoneNumberId = wabaidController.phoneNumber;
  final bool isSearchBarVisible;

  @override
  State<LabelsPage> createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  late Future<SharedPreferences> _prefs;
  late String enteredWABAID;

  final List<String> labels = [
    'New Customer',
    'New Order',
    'Pending Payment',
    'Paid',
    'Order Complete',
    'Important',
    'Follow Up',
    'Lead',
  ];

  Future<Map<String, int>> countLabeledContacts(SharedPreferences prefs) async {
    Map<String, int> labelCounts = {};

    for (String label in labels) {
      int count = 0;

      for (String phoneNumber in widget.toPhoneNumber) {
        //print('Phone numbers from list :$phoneNumber');
        String key =
            '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
        String? storedLabel = prefs.getString(key);

        if (storedLabel == label) {
          count++;
        }
      }

      labelCounts[label] = count;
    }

    return labelCounts;
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

  List<String> _loadLabelsOrder(SharedPreferences prefs) {
    List<String>? savedOrder = prefs.getStringList('labels_order');
    return savedOrder ?? labels;
  }

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
    final wabaidController = Get.find<WABAIDController>();
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
        for (String phoneNumber in widget.toPhoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel =
              await _prefs.then((prefs) => prefs.getString(key));

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
        for (String phoneNumber in widget.toPhoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel =
              await _prefs.then((prefs) => prefs.getString(key));

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

        for (String phoneNumber in widget.toPhoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel =
              await _prefs.then((prefs) => prefs.getString(key));

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

        for (String phoneNumber in widget.toPhoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel =
              await _prefs.then((prefs) => prefs.getString(key));

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

        for (String phoneNumber in widget.toPhoneNumber) {
          String key =
              '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
          String? storedLabel =
              await _prefs.then((prefs) => prefs.getString(key));

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

                    for (String phoneNumber in widget.toPhoneNumber) {
                      String key =
                          '${phoneNumber}_${widget.wabaidController.phoneNumber}_label';
                      String? storedLabel =
                          await _prefs.then((prefs) => prefs.getString(key));

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

  @override
  Widget build(BuildContext context) {
    String? selectedLabel;
    int? selectedLabelCount;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        backgroundColor: Colors.black12,
        title: const Text('Labels'),
      ),
      body: FutureBuilder(
        future: _prefs,
        builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            SharedPreferences prefs = snapshot.data!;
            List<String> currentLabelsOrder = _loadLabelsOrder(prefs);

            return FutureBuilder(
              future: countLabeledContacts(prefs),
              builder:
                  (context, AsyncSnapshot<Map<String, int>> countSnapshot) {
                if (countSnapshot.connectionState == ConnectionState.done) {
                  Map<String, int> labelCounts = countSnapshot.data!;

                  return ReorderableListView.builder(
                    itemCount: currentLabelsOrder.length,
                    itemBuilder: (context, index) {
                      String label = currentLabelsOrder[index];
                      int contactCount = labelCounts[label] ?? 0;

                      return ListTile(
                        key: ValueKey(label),
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: _getLabelColor(label),
                          child: const Icon(Icons.label,
                              color: Colors.white, size: 20),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(
                                Icons.drag_handle_rounded,
                                size: 25,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '$contactCount ${contactCount == 1 ? 'contact' : 'contacts'}',
                        ),
                        onTap: () {
                          setState(() {
                            selectedLabel = label;
                            selectedLabelCount = contactCount;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LabelContactsPage(
                                enteredWABAID: enteredWABAID,
                                isSearchBarVisible: widget.isSearchBarVisible,
                                selectedLabel: selectedLabel!,
                                selectedLabelCount: selectedLabelCount!,
                                labelsPageToPhoneNumbers: widget.toPhoneNumber,
                                wabaidController: widget.wabaidController,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        String movedLabel =
                            currentLabelsOrder.removeAt(oldIndex);
                        currentLabelsOrder.insert(newIndex, movedLabel);
                        prefs.setStringList('labels_order', currentLabelsOrder);
                      });
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            // You can return a loading indicator here if needed
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
