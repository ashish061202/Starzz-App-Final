import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart' as contacts_flutter;
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:contacts_service/contacts_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/phone_contacts/phone_contacts_page.dart';
import '../../../widgets/custom_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

//Me
class ContactsPage extends StatefulWidget {
  ContactsPage({
    super.key,
    required this.enteredWABAID,
    required this.isSearchBarVisible,
  }) {
    snapshot = FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .snapshots();
  }

  final String? enteredWABAID;
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool isSearchBarVisible;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late SharedPreferences _prefs;
  final Set<String> pinnedChats = Set<String>();
  List<String> pinnedContacts = [];
  WABAIDController wabaidController = Get.find<WABAIDController>();
  List<contacts_flutter.Contact> deviceContacts = [];
  List<contacts_flutter.Contact> filteredDeviceContacts = [];
  String searchQuery = "";
  bool isSearchBarExpanded = false;

  _ContactsPageState() {
    _initPrefs(); // Initialize _prefs in the constructor
    _initializeContacts();
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

  Future<String> getContactNameForNumber(String phoneNumber) async {
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

  @override
  Widget build(BuildContext context) {
    // if (deviceContacts.isEmpty) {
    //   // Return a loading indicator or placeholder while contacts are being fetched
    //   return const CircularProgressIndicator();
    // }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(PhoneContactsPage.id,
              arguments: {"fromChat": false, 'to': null, 'whatsAppApi': null});
        },
        backgroundColor: Get.isDarkMode
            ? Colors.purple.shade300
            : const Color.fromARGB(255, 107, 74, 207),
        child: Icon(
          Icons.add,
          color: Get.isDarkMode ? Colors.white : Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.isSearchBarVisible)
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

                        if (contactName
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                            user
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase())) {
                          return CustomCard(
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
                      widgets = widgets.whereType<CustomCard>().toList();

                      // Sort based on last message timestamp
                      widgets.sort((a, b) {
                        Timestamp? timestampA =
                            (a as CustomCard).lastMessageTimestamp;
                        Timestamp? timestampB =
                            (b as CustomCard).lastMessageTimestamp;

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
