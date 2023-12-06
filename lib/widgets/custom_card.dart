import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../screens/chat/chat_page.dart';
import 'package:starz/services/firestore_service.dart';

// ignore: must_be_immutable
//He
/*class CustomCard extends StatelessWidget {
  CustomCard({super.key, required this.toPhoneNumber, required this.roomId});

  String toPhoneNumber;
  String roomId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.toNamed(ChatPage.id,
                arguments: {"to": toPhoneNumber, "roomId": roomId});
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueGrey,
              child: SvgPicture.asset("assets/person.svg",
                  color: Colors.white, height: 37, width: 37),
            ),
            title: Text(
              toPhoneNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.done_all, color: Colors.grey, size: 12),
                const SizedBox(width: 5),
                Text("chat.currentMessage!",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]))
              ],
            ),
            trailing: Text("chat.time!"),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20, left: 80),
          child: Divider(
            thickness: 1,
          ),
        )
      ],
    );
  }
}*/

//Me Try2
class CustomCard extends StatelessWidget {
  const CustomCard(
      {super.key,
      required this.toPhoneNumber,
      required this.roomId,
      required this.lastMessageTimestamp});

  final String toPhoneNumber;
  final String roomId;
  final Timestamp? lastMessageTimestamp;

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final DateTime messageTime = timestamp.toDate();
    final DateTime now = DateTime.now();

    if (now.difference(messageTime).inDays == 0) {
      // If the message is from today, display the formatted time
      return DateFormat.Hm().format(messageTime); // Adjust the format as needed
    } else if (now.difference(messageTime).inDays == 1) {
      // If the message is from yesterday, display 'Yesterday'
      return 'Yesterday';
    } else {
      // If the message is older than 2 days, display the date
      return DateFormat.yMMMd()
          .format(messageTime); // Adjust the format as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.toNamed(ChatPage.id,
                arguments: {"to": toPhoneNumber, "roomId": roomId});
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueGrey,
              child: SvgPicture.asset("assets/person.svg",
                  color: Colors.white, height: 37, width: 37),
            ),
            title: Text(
              toPhoneNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: getLastMessage(toPhoneNumber),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading message: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final lastMessage = snapshot.data!;
                      final body = lastMessage['text']['body'] as String?;
                      final timestamp = lastMessage['timestamp'] as Timestamp?;
                      // ... customize how you want to display the last message ...
                      return Text('Last Message: $body');
                    } else {
                      return const Text('No messages found');
                    }
                  },
                ),
              ],
            ),
            trailing: FutureBuilder<Map<String, dynamic>?>(
              future: getLastMessage(toPhoneNumber),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading message: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final lastMessage = snapshot.data!;
                  final timestamp = lastMessage['timestamp'] as Timestamp?;
                  final formattedTime = _formatTimestamp(timestamp);
                  return Text(formattedTime);
                } else {
                  return const Text('No messages found');
                }
              },
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
    );
  }

  // String _formatTimestamp(Timestamp? timestamp) {
  //   if (timestamp == null) {
  //     return '';
  //   }
  //   final DateTime dateTime = timestamp.toDate();
  //   final String formattedTime =
  //       DateFormat.Hm().format(dateTime); // Adjust the format as needed
  //   return formattedTime;
  // }
}
