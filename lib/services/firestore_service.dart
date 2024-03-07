import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessageStream(
    String phoneNumber, String enteredWABAID) {
  return FirebaseFirestore.instance
      .collection('accounts')
      .doc(enteredWABAID)
      .collection('discussion')
      .doc(phoneNumber)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future<Map<String, dynamic>?> getLastMessage(
    String phoneNumber, String enteredWABAID, String phoneNumberId) async {
  try {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await getLastMessageStream(phoneNumber, enteredWABAID).first;

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> lastMessage =
          querySnapshot.docs.first;

      // Check if the last message is from the specified phoneNumberId
      if (lastMessage['from'] == phoneNumberId) {
        final Map<String, dynamic>? lastMessageData = lastMessage.data();

        // Perform a null check before using the spread operator
        if (lastMessageData != null) {
          // Create a new map with the existing data and the additional flag
          return Map<String, dynamic>.from(lastMessageData)
            ..['isPhoneNumberIdMatch'] = true;
        }
      } else {
        // Return the last message without the additional flag
        return lastMessage.data();
      }
    } else {
      return null; // No messages found
    }
  } catch (e) {
    print("Error fetching last message: $e");
    return null;
  }
}
