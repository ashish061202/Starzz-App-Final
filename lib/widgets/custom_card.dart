import 'dart:async';
import 'package:STARZ/widgets/custom_card_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart' as contacts_service;
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../screens/chat/chat_page.dart';
import 'package:STARZ/services/firestore_service.dart';

//Me Try2
class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.toPhoneNumber,
    required this.roomId,
    required this.lastMessageTimestamp,
    required this.isPinned,
    required this.onLongPress,
    //required this.contact,
    required this.onPinToggle,
    required this.wabaidController,
    required this.savedContactName,
  });

  final String toPhoneNumber;
  final String roomId;
  final Timestamp? lastMessageTimestamp;
  final bool isPinned;
  //final String contact;
  final VoidCallback onLongPress;
  final Function(bool) onPinToggle;
  final WABAIDController wabaidController;
  final String savedContactName;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  int newMessageCount = 0; // Add this line
  Timestamp? lastSeenTimestamp;
  late bool _isPinned;
  late SharedPreferences _prefs;
  String _selectedLabel = '';
  late Color _selectedColor;
  bool? _isNumberVisible;
  bool isChatPageOpen = false;
  final wabaidController = Get.find<WABAIDController>();
  late String phoneNumberId = wabaidController.phoneNumber;
  // Declare a stream controller to manage the stream
  late StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _streamController;
  late List<String> labelNames;
  final GlobalKey<State> _key = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    // Initialize labelNames
    labelNames = _getLabelNames();
    // Initialize SharedPreferences
    _initPrefs().then((_) {
      setState(() {
        // Load the selected label color for the contact
        _selectedLabel =
            _prefs.getString('${widget.toPhoneNumber}_label') ?? '';
      });
    });

    lastSeenTimestamp = null; // Initialize lastSeenTimestamp

    // Initialize the stream controller with the stream of messages
    _streamController =
        StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();

    // Listen to the message stream and add data to the stream controller
    getLastMessageStream().listen((data) {
      if (!_streamController.isClosed) {
        _streamController.add(data.docs);
      }
    });
    print("phoneNumber ID to show tick: $phoneNumberId");
    _initPrefs().then((_) {
      _isPinned = widget.isPinned;
      setState(() {
        _isNumberVisible = _prefs.getBool(widget.toPhoneNumber) ?? true;
      });
    });
  }

  @override
  void dispose() {
    // Close the stream controller when the widget is disposed
    _streamController.close();
    super.dispose();
  }

  List<String> _getLabelNames() {
    // Fetch label names dynamically based on your logic
    return [
      'New Customer',
      'New Order',
      'Pending Payment',
      'Paid',
      'Order Complete',
      'Important',
      'Follow Up',
      'Lead',
      // Add more labels as needed
    ];
  }

  // The stream of messages
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageStream() {
    // Initialize the newMessageCount when the stream is created
    // newMessageCount = 0;

    return FirebaseFirestore.instance
        .collection('accounts')
        .doc(widget.wabaidController.enteredWABAID)
        .collection('discussion')
        .doc(widget.toPhoneNumber)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      // Use an async function to fetch the last seen timestamp
      Future<void> updateMessageCount() async {
        try {
          final prefs = await SharedPreferences.getInstance();

          // Retrieve the list of seen message IDs
          final List<String> seenMessageIds =
              prefs.getStringList('seenMessages_${widget.toPhoneNumber}') ?? [];

          // Filter messages based on 'from' value and timestamp
          final relevantMessages = querySnapshot.docs.where((doc) {
            final timestamp = doc['timestamp'];
            final messageId = doc.id;

            return doc['from'] == widget.toPhoneNumber &&
                doc['from'] != widget.wabaidController.phoneNumber &&
                timestamp is Timestamp &&
                (lastSeenTimestamp == null ||
                    timestamp.compareTo(lastSeenTimestamp!) > 0) &&
                !seenMessageIds.contains(messageId);
          });

          // Update the new message count
          newMessageCount += relevantMessages.length;

          // If there are new messages, update the last seen timestamp and seen message IDs
          if (relevantMessages.isNotEmpty) {
            final latestTimestamp = relevantMessages
                .map((doc) => doc['timestamp'] as Timestamp)
                .reduce((value, element) =>
                    value.compareTo(element) > 0 ? value : element);

            final latestMessageIds =
                relevantMessages.map((doc) => doc.id).toList();

            setState(() {
              lastSeenTimestamp = latestTimestamp;
            });

            // Save the latest seen message IDs to SharedPreferences
            seenMessageIds.addAll(latestMessageIds);
            prefs.setStringList(
                'seenMessages_${widget.toPhoneNumber}', seenMessageIds);
          }
        } catch (e) {
          print('Error updating message count: $e');
        }
      }

      // Call the async function to update the message count
      updateMessageCount();

      // Return the original QuerySnapshot
      return querySnapshot;
    });
  }

  // void updateCountInSharedPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setInt('messageCount_${widget.toPhoneNumber}', newMessageCount);
  // }

  // Function to determine the last message from the stream
  Map<String, dynamic>? getLastMessageFromSnapshot(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshots) {
    if (snapshots.isNotEmpty) {
      final lastMessage = snapshots.first.data() as Map<String, dynamic>;

      if (lastMessage.containsKey('isPhoneNumberIdMatch')) {
        // The 'isPhoneNumberIdMatch' field is present in the last message
        return Map<String, dynamic>.from(lastMessage)
          ..['isPhoneNumberIdMatch'] = lastMessage['isPhoneNumberIdMatch'];
      } else {
        // The 'isPhoneNumberIdMatch' field is not present, set it to false
        return Map<String, dynamic>.from(lastMessage)
          ..['isPhoneNumberIdMatch'] = false;
      }
    } else {
      return null;
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Load selected label and color for the contact
    _selectedLabel = _prefs.getString(
            '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_label') ??
        '';
    _selectedColor = _getLabelColor(_selectedLabel);

    // Load the visibility state from SharedPreferences
    dynamic visibilityValue = _prefs.get(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_visibility');

    // Check if the value is a boolean, otherwise set a default value
    _isNumberVisible = (visibilityValue is bool) ? visibilityValue : true;

    // Save the correct value to SharedPreferences
    _prefs.setBool(widget.toPhoneNumber, _isNumberVisible ?? true);

    setState(() {});
  }

  Future<void> _updateVisibility(bool isVisible) async {
    setState(() {
      _isNumberVisible = isVisible;
    });
    // Save the visibility state to SharedPreferences
    _prefs.setBool(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_visibility',
        isVisible);
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('hh:mm a');

    if (now.difference(messageTime).inDays == 0) {
      // If the message is from today, display the formatted time
      String formattedTime = formatter.format(messageTime);
      return formattedTime
          .replaceAll('AM', 'am')
          .replaceAll('PM', 'pm'); // Adjust the format as needed
    } else if (now.difference(messageTime).inHours == 24) {
      // If the message is from yesterday, display 'Yesterday'
      return 'Yesterday';
    } else {
      // If the message is older than 2 days, display the date
      return DateFormat.yMMMd()
          .format(messageTime); // Adjust the format as needed
    }
  }

  Color _getLabelColor(String label) {
    // Define a mapping of label names to colors
    Map<String, Color> labelColors = {
      'New Customer': Colors.blue,
      'New Order': Colors.green,
      'Pending Payment': Colors.orange,
      'Paid': Colors.teal,
      'Order Complete': Colors.purple,
      'Important': Colors.red,
      'Follow Up': Colors.indigo,
      'Lead': Colors.amber,
      // Add more labels and colors as needed
    };

    // Get the color for the selected label
    return labelColors[label] ?? Colors.black;
  }

  PopupMenuItem<String> buildLabelMenuItem(String label, bool isSelected) {
    Color color = _getLabelColor(label);

    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color,
            child: const Icon(Icons.label, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? color
                  : Get.isDarkMode
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          // const Spacer(),
          // GestureDetector(
          //   onTap: () async {
          //     await _editLabelName(label);
          //   },
          //   child: const Icon(
          //     Icons.edit,
          //     color: Colors.grey,
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> _setSelectedLabel(String label) async {
    // Save the selected label color for the contact
    await _prefs.setString(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_label',
        label);
    // Save the selected color for the contact
    await _prefs.setInt(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_label_color',
        _getLabelColor(label).value);
    setState(() {
      _selectedLabel = label;
      _selectedColor = _getLabelColor(label);
      print('Selected Label: $_selectedLabel');
      print('Selected Color: $_selectedColor');
    });
  }

  Future<void> _removeLabel() async {
    // Remove the selected label for the contact
    await _prefs.remove(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_label');

    // Remove the selected color for the contact
    await _prefs.remove(
        '${widget.toPhoneNumber}_${widget.wabaidController.phoneNumber}_label_color');

    setState(() {
      _selectedLabel = '';
      _selectedColor =
          Colors.grey.shade300; // Set to light grey or any default color
    });
  }

  // Add a new method to handle pin toggle
  void _togglePin() async {
    bool newIsPinned = !_isPinned; // Toggle the pinned status

    // Inform the parent widget about the pin toggle
    widget.onPinToggle(newIsPinned);

    print('Inside _togglePin - newIsPinned: $newIsPinned');

    setState(() {
      _isPinned = newIsPinned;
    });
  }

  // Add this method to handle saving contacts
  Future<void> saveContact(BuildContext context) async {
    print('Entered in saveContact function');

    // Check if the contact is already saved
    if (widget.toPhoneNumber == widget.savedContactName) {
      TextEditingController customNameController = TextEditingController();

      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Save Contact',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter contact name and tap Save',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Save the contact
                          await _addContact(
                            displayName: customNameController.text.isNotEmpty
                                ? customNameController.text
                                : widget.toPhoneNumber,
                            phones: [widget.toPhoneNumber],
                          );

                          // Update the savedContactName in the state
                          Provider.of<CustomCardStateNotifier>(context,
                                  listen: false)
                              .updateSavedContactName(
                            toPhoneNumber: widget.toPhoneNumber,
                            newName: customNameController.text.isNotEmpty
                                ? customNameController.text
                                : widget.toPhoneNumber,
                          );

                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Contact is already saved, show a message or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact is already saved!'),
        ),
      );
    }
  }

  // Helper method to add a contact
  Future<void> _addContact({
    required String displayName,
    required List<String> phones,
  }) async {
    final contact = contacts_service.Contact(
      givenName: displayName,
      phones: phones
          .map((phone) => contacts_service.Item(label: 'mobile', value: phone))
          .toList(),
    );

    await contacts_service.ContactsService.addContact(contact);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact saved successfully!'),
      ),
    );
  }

  void _showLongPressMenu(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: _isPinned
                  ? const Icon(Icons.push_pin_outlined) // Icon for removing pin
                  : const Icon(Icons.push_pin),
              title: _isPinned
                  ? const Text('Unpin contact')
                  : const Text('Pin contact'),
              onTap: () async {
                // Handle the pin action
                widget.onLongPress();

                // Close the bottom sheet after a short delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pop(context);
                });
              },
            ),
            if (widget.toPhoneNumber == widget.savedContactName)
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save Contact'),
                onTap: () {
                  // Close the bottom sheet
                  Navigator.of(context).pop();
                  // Save the contact
                  saveContact(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Add label'),
              onTap: () async {
                Navigator.pop(context);
                await _showLabelPopupMenu(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLabelPopupMenu(BuildContext context) async {
    final String? selectedLabel = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Label'),
          children: [
            for (String label in labelNames) // Dynamically build menu items
              buildLabelMenuItem(label, label == _selectedLabel),
            const PopupMenuItem<String>(
              value: 'Remove Label',
              child: Row(
                children: [
                  Icon(Icons.remove_circle,
                      color: Colors.grey), // Icon for removing label
                  SizedBox(width: 10),
                  Text('Remove Label'),
                ],
              ),
            ),
            // Add more label options as needed
          ],
        );
      },
    );

    if (selectedLabel == 'Remove Label') {
      await _removeLabel();
    }
    // else if (selectedLabel == 'Edit Label') {
    //   //await _editLabelName();
    // }
    else if (selectedLabel != null) {
      await _setSelectedLabel(selectedLabel);
    }
  }

  Future<void> _editLabelName(String oldLabel) async {
    final String? editedLabel = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? newLabel;
        return AlertDialog(
          title: const Text('Edit Label'),
          content: TextField(
            onChanged: (value) {
              newLabel = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter new label',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newLabel != null && newLabel!.isNotEmpty) {
                  // Update label name in SharedPreferences
                  await _updateLabelName(oldLabel, newLabel!);
                  Navigator.pop(context, newLabel);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (editedLabel != null) {
      await _setSelectedLabel(editedLabel);
    }
  }

  IconData? _getLabelIcon(String label) {
    // Define a mapping of label names to corresponding icons
    Map<String, IconData> labelIcons = {
      'New Customer': Icons.label,
      'New Order': Icons.label,
      'Pending Payment': Icons.label,
      'Paid': Icons.label,
      'Order Complete': Icons.label,
      'Important': Icons.label,
      'Follow Up': Icons.label,
      'Lead': Icons.label,
      // Add more labels and icons as needed
    };

    // Get the icon for the selected label
    return labelIcons[label];
  }

  Future<void> _updateLabelName(String oldLabel, String newLabel) async {
    // Get the current label color and remove the existing label
    final Color oldLabelColor = _getLabelColor(oldLabel);
    await _removeLabel();

    // Save the new label with the same color
    await _setSelectedLabel(newLabel);

    // Update the label names list
    setState(() {
      labelNames = _getLabelNames();
    });

    // You may also need to update the label color for consistency
    await _prefs.setInt(
        '${widget.toPhoneNumber}_label_color', oldLabelColor.value);
  }

  Widget _buildShimmerLoadingCard() {
    return Container(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor:
                Get.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blueGrey,
                child: SvgPicture.asset(
                  "assets/person.svg",
                  color: Colors.white,
                  height: 37,
                  width: 37,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      height: 15,
                      width: 100,
                      color:
                          Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 18,
                        width: 18,
                        color: Get.isDarkMode
                            ? Colors.grey[800]!
                            : Colors.grey[300],
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                children: <Widget>[
                  Container(
                    height: 12,
                    width: 20,
                    color:
                        Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
                  ),
                  Flexible(
                    child: Container(
                      height: 12,
                      width: 100,
                      color:
                          Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 18,
                    width: 18,
                    color:
                        Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 12,
                    width: 50,
                    color:
                        Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Container(
                      height: 12,
                      width: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20, left: 80),
            child: Divider(
              thickness: 1,
            ),
          )
        ],
      ),
    );
  }

  // Shimmer effect for loading icon
  Widget _buildShimmerLoadingIcon() {
    return Shimmer.fromColors(
      baseColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
      child: Padding(
        padding: const EdgeInsets.only(right: 3.0),
        child: Container(
          height: 18,
          width: 18,
          color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildShimmerLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 15,
            width: 200,
            color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTimestamp() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 12,
        width: 100,
        color: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor:
                  Get.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              child: _buildShimmerLoadingCard(),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading message: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final lastMessage = getLastMessageFromSnapshot(snapshot.data!);

            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color.fromARGB(255, 61, 163, 247),
                      Color.fromARGB(255, 21, 94, 153),
                      Colors.purple,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(value * 20, 0),
                      child: child,
                    );
                  },
                  child: const Text(
                    'Hide',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              secondaryBackground: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Color.fromARGB(255, 61, 163, 247),
                      Color.fromARGB(255, 21, 94, 153),
                      Colors.purple,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(right: 16),
                alignment: Alignment.centerRight,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(-value * 20, 0),
                      child: child,
                    );
                  },
                  child: const Text(
                    'Unhide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  // Left swipe
                  _updateVisibility(false);
                } else if (direction == DismissDirection.endToStart) {
                  // Right swipe
                  _updateVisibility(true);
                }
              },
              child: GestureDetector(
                onLongPress: () {
                  _showLongPressMenu(context);
                },
                child: Container(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Reset new message count to 0 when user taps on the CustomCard
                          setState(() {
                            newMessageCount = 0;
                          });
                          Get.toNamed(ChatPage.id, arguments: {
                            "to": widget.toPhoneNumber,
                            "userName&Num": widget.savedContactName,
                            "roomId": widget.roomId,
                            "prefs": _prefs,
                          });
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blueGrey,
                            child: SvgPicture.asset(
                              "assets/person.svg",
                              color: Colors.white,
                              height: 37,
                              width: 37,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _isNumberVisible ?? true
                                            ? Provider.of<CustomCardStateNotifier>(
                                                            context)
                                                        .savedContactNames[
                                                    widget.toPhoneNumber] ??
                                                widget.savedContactName
                                            : '************',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Conditionally show label icon and color
                              Row(
                                children: [
                                  Icon(
                                    _getLabelIcon(_selectedLabel),
                                    color: _getLabelColor(_selectedLabel),
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 5),
                                  FutureBuilder<Map<String, dynamic>?>(
                                    future: getLastMessage(
                                        widget.toPhoneNumber,
                                        widget.wabaidController.enteredWABAID,
                                        widget.wabaidController.phoneNumber),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Shimmer.fromColors(
                                          baseColor: Get.isDarkMode
                                              ? Colors.grey[800]!
                                              : Colors.grey[300]!,
                                          highlightColor: Get.isDarkMode
                                              ? Colors.grey[700]!
                                              : Colors.grey[200]!,
                                          child: _buildShimmerTimestamp(),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(
                                            'Error loading message: ${snapshot.error}');
                                      } else if (snapshot.hasData) {
                                        final lastMessage = snapshot.data!;
                                        final timestamp =
                                            lastMessage['timestamp']
                                                as Timestamp?;
                                        final formattedTime =
                                            _formatTimestamp(timestamp);
                                        // Define a color for the timestamp based on newMessageCount
                                        final timestampColor =
                                            newMessageCount > 0
                                                ? Colors.green
                                                : Colors.grey.shade700;
                                        final isDarkModeTime =
                                            newMessageCount > 0 &&
                                                    Get.isDarkMode
                                                ? Colors.green
                                                : Colors.grey;
                                        final timestampFontWeight =
                                            newMessageCount > 0
                                                ? FontWeight.bold
                                                : FontWeight.bold;
                                        return Text(
                                          formattedTime,
                                          style: GoogleFonts.nunito(
                                            color: Get.isDarkMode
                                                ? isDarkModeTime
                                                : timestampColor,
                                            fontWeight: timestampFontWeight,
                                            fontSize: 12,
                                          ),
                                        );
                                      } else {
                                        return const Text('');
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 5),
                                  if (newMessageCount >
                                      0) // Add some space between timestamp and message count
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: Text(
                                        newMessageCount
                                            .toString(), // Display new message count
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Add Expanded here
                                child: Row(
                                  children: [
                                    // Display the "done all" icon before the subtitle
                                    FutureBuilder<Map<String, dynamic>?>(
                                      future: getLastMessage(
                                        widget.toPhoneNumber,
                                        widget.wabaidController.enteredWABAID,
                                        widget.wabaidController.phoneNumber,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Shimmer.fromColors(
                                            baseColor: Get.isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.grey[300]!,
                                            highlightColor: Get.isDarkMode
                                                ? Colors.grey[700]!
                                                : Colors.grey[200]!,
                                            child: _buildShimmerLoadingIcon(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error loading message: ${snapshot.error}');
                                        } else if (snapshot.hasData) {
                                          final lastMessage = snapshot.data!;
                                          final isPhoneNumberIdMatch =
                                              lastMessage[
                                                      'isPhoneNumberIdMatch'] ??
                                                  false;

                                          // Display the "done all" icon if isPhoneNumberIdMatch is true
                                          return isPhoneNumberIdMatch
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 3.0),
                                                  child: Icon(
                                                    Icons.done_all,
                                                    color: Colors.grey,
                                                    size: 18.0,
                                                  ),
                                                )
                                              : const SizedBox();
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                    Flexible(
                                      child:
                                          FutureBuilder<Map<String, dynamic>?>(
                                        future: getLastMessage(
                                            widget.toPhoneNumber,
                                            widget
                                                .wabaidController.enteredWABAID,
                                            widget
                                                .wabaidController.phoneNumber),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Shimmer.fromColors(
                                              baseColor: Get.isDarkMode
                                                  ? Colors.grey[800]!
                                                  : Colors.grey[300]!,
                                              highlightColor: Get.isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[200]!,
                                              child:
                                                  _buildShimmerLoadingIndicator(),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error loading message: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            final lastMessage = snapshot.data!;

                                            if (lastMessage['type'] ==
                                                'document') {
                                              // Check if 'filename' is present and not null
                                              final filename =
                                                  lastMessage['document']
                                                      ['filename'] as String?;
                                              if (filename != null) {
                                                String displayFilename = filename
                                                            .length >
                                                        15
                                                    ? '${filename.substring(0, 15)}...'
                                                    : filename;
                                                return Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.insert_drive_file,
                                                      color: Colors.grey,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      displayFilename,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                // Handle the case where 'filename' is null
                                                return const Text('Document');
                                              }
                                            } else if (lastMessage['type'] ==
                                                'image') {
                                              return const Text(
                                                'Photo',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'video') {
                                              return const Text(
                                                'Video',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'audio') {
                                              return const Text(
                                                'Audio',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'reaction') {
                                              return const Text(
                                                'reaction',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'location') {
                                              return const Text(
                                                'location',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'contacts') {
                                              return const Text(
                                                'contact',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'order') {
                                              return const Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .store_mall_directory_rounded,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ), // Assuming Icons.shop represents a shop icon
                                                  SizedBox(
                                                    width: 5,
                                                  ), // Adjust the spacing between icon and text as needed
                                                  Text(
                                                    'Order',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              );
                                            } else if (lastMessage['type'] ==
                                                'unsupported') {
                                              return const Text(
                                                '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'button') {
                                              // Display button type message
                                              final buttonText =
                                                  lastMessage['button']
                                                      ?['payload'];
                                              return Text(
                                                buttonText ?? 'Button',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              );
                                            } else if (lastMessage['type'] ==
                                                'interactive') {
                                              // Handle interactive type message
                                              final interactiveData =
                                                  lastMessage['interactive'];

                                              if (interactiveData != null) {
                                                final nfmReplyData =
                                                    interactiveData[
                                                        'nfm_reply'];
                                                if (nfmReplyData != null) {
                                                  final body =
                                                      nfmReplyData['body']
                                                          as String?;
                                                  final name =
                                                      nfmReplyData['name']
                                                          as String?;
                                                  final responseJson =
                                                      nfmReplyData[
                                                              'response_json']
                                                          as String?;
                                                  print(
                                                      'Interactive Message: $body, $name, $responseJson');

                                                  // Display interactive type message information
                                                  return const Text(
                                                    'Flow message',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  );
                                                }
                                              }

                                              // Default case if interactive data is not properly structured
                                              return const Text(
                                                  'Interactive Message: Unknown format');
                                            } else {
                                              final body = lastMessage['text']
                                                  ['body'] as String?;
                                              //final timestamp = lastMessage['timestamp'] as Timestamp?;
                                              // ... customize how you want to display the last message ...
                                              return Text(
                                                '$body' ?? '',
                                                overflow: TextOverflow
                                                    .ellipsis, // This will add ellipsis (...) if the text overflows
                                                maxLines: 1,
                                              );
                                            }
                                          } else {
                                            return const Text(
                                                'No messages found');
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isPinned)
                                const Icon(
                                  Icons.push_pin_sharp,
                                  color: Colors.grey,
                                  size: 18.0,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20, left: 80),
                        child: Divider(
                          thickness: 1,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }
}
