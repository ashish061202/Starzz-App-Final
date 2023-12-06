import 'package:flutter/material.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starz/config.dart';
import 'package:starz/screens/home/components/navigation_bar.dart';
import 'package:starz/screens/phone_contacts/phone_contacts_page.dart';
//import 'package:whatsapp/whatsapp.dart';
import '../../../widgets/custom_card.dart';

//He
/*class ContactsPage extends StatelessWidget {
  ContactsPage({
    super.key,
    required this.enteredWABAID,
  }) {
    //print(AppConfig.phoneNoID);
    snapshot = FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .snapshots();
  }

  final String? enteredWABAID;
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(PhoneContactsPage.id, arguments: {
              "fromChat": false,
              'to': null,
              'whatsAppApi': null
            });
          },
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: snapshot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('There are no current discussions'),
                  );
                }
                List<Widget> widgets = [];
                for (int i = 0; i < snapshot.data!.size; i++) {
                  String user = snapshot.data!.docs[i].data()['client'];
                  //users.remove(AppConfig.phoneNoID);

                  widgets.add(CustomCard(
                    roomId: snapshot.data!.docs[i].id,
                    toPhoneNumber: user,
                  ));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: widgets,
                  ),
                );
              }
            }
            const Text("6");
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}*/


//Me
class ContactsPage extends StatelessWidget {
  ContactsPage({
    super.key,
    required this.enteredWABAID,
  }) {
    //print(AppConfig.phoneNoID);
    snapshot = FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .snapshots();
  }

  final String? enteredWABAID;
  late Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;

  Future<Timestamp?> getLastMessageTimestamp(String roomId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("accounts")
              .doc(enteredWABAID)
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

  Future<List<Widget>> fetchAndSortData(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<Widget> widgets = [];

    for (int i = 0; i < snapshot.size; i++) {
      String user = snapshot.docs[i].data()['client'];
      String roomId = snapshot.docs[i].id;

      // Fetch last message timestamp for each contact
      Timestamp? lastMessageTimestamp =
          await getLastMessageTimestamp(roomId);

      widgets.add(CustomCard(
        roomId: snapshot.docs[i].id,
        toPhoneNumber: user,
        lastMessageTimestamp: lastMessageTimestamp,
      ));
    }

    widgets.sort((a, b) {
      Timestamp? timestampA = (a as CustomCard).lastMessageTimestamp;
      Timestamp? timestampB = (b as CustomCard).lastMessageTimestamp;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(PhoneContactsPage.id, arguments: {
            "fromChat": false,
            'to': null,
            'whatsAppApi': null
          });
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: snapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data != null) {
              QuerySnapshot<Map<String, dynamic>> data = snapshot.data!;
              if (data.docs.isEmpty) {
                return const Center(
                  child: Text('There are no current discussions'),
                );
              }

              return FutureBuilder<List<Widget>>(
                future: fetchAndSortData(data),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Widget> widgets = snapshot.data as List<Widget>;

                    return SingleChildScrollView(
                      child: Column(
                        children: widgets,
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


