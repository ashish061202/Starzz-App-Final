import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:starz/config.dart';

Future<Map<String, dynamic>?> getLastMessage(String phoneNumber) async {
  try {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection("accounts")
            .doc(AppConfig.WABAID)
            .collection("discussion")
            .doc(phoneNumber)
            .collection("messages")
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>> lastMessage =
          querySnapshot.docs.first;
      return lastMessage.data();
    } else {
      return null; // No messages found
    }
  } catch (e) {
    print("Error fetching last message: $e");
    return null;
  }
}