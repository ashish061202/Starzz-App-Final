import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/config.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/chat/file_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MessageUtility {
  static Future<void> sendMessage(
      String message, String recipientPhoneNumber) async {
    try {
      final wabaidController = Get.find<WABAIDController>();
      String phoneNumberId = wabaidController.phoneNumber;
      String enteredWABAID = wabaidController.enteredWABAID;
      // Assuming you have the necessary setup for WhatsAppApi
      WhatsAppApi whatsApp = WhatsAppApi();
      whatsApp.setup(
        accessToken: AppConfig.apiKey, // Replace with your actual API key
        fromNumberId:
            int.tryParse(phoneNumberId), // Make sure phoneNumberId is defined
      );

      // Retrieve the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Send message using WhatsAppApi
      var response = await whatsApp.messagesText(
        message: message,
        to: int.parse(recipientPhoneNumber),
      );

      // Handle the response as needed
      print('+++ RESPONSE NORMAL $response');
      var messageId = response['messages'][0]['id'];
      print("messageId :- $messageId");

      // Store the message in Firestore or perform other necessary actions
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(enteredWABAID)
          .collection("discussion")
          .doc(recipientPhoneNumber)
          .collection("messages")
          .add({
        "from": phoneNumberId,
        "id": messageId,
        "text": {"body": message},
        "type": "text",
        "timestamp": DateTime.now(),
        "fcmToken": fcmToken, // Include FCM token in the message data
      });
    } catch (error) {
      // Handle errors
      print('Error sending message: $error');
    }
  } 
}
