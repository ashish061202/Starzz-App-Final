import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';
//import 'package:http/http.dart';
//import 'package:starz/api/api_service.dart';
import 'package:starz/api/whatsapp_api.dart';
import 'package:starz/controllers/conctacts_controller.dart';
import 'package:sizer/sizer.dart';
//import 'package:starz/screens/chat/chat_page.dart';

import '../../config.dart';

// ignore: must_be_immutable
class PhoneContactsPage extends GetView<ConctactsController> {
  PhoneContactsPage({super.key});

  static const id = "/phone_contacts";
  bool fromChat = Get.arguments['fromChat'];
  int? to = Get.arguments['to'];
  WhatsAppApi? whatsApp = Get.arguments['whatsAppApi'];
  String? swipedMessageId = Get.arguments['swipedMessageId'];

  sendContact(message, fullName) async {
    if (to != null) {
      var value;
      if (swipedMessageId == null) {
        value = await whatsApp?.messagesContacts(
            to: to, phoneNumber: message, fullName: fullName);
      } else {
        value = await whatsApp?.messagesContactsReply(
            to: to,
            phoneNumber: message,
            fullName: fullName,
            messageId: swipedMessageId);
      }

      Map<String, dynamic> firestoreObject = {};

      if (swipedMessageId == null) {
        firestoreObject = {
          "from": AppConfig.phoneNoID,
          "id": value['messages'][0]['id'],
          "contacts": [
            {
              'name': {'first_name': fullName, 'formatted_name': fullName},
              'phones': [
                {'phone': message, 'type': 'Mobile'}
              ],
            }
          ],
          "type": "contacts",
          "timestamp": DateTime.now()
        };
      } else {
        firestoreObject = {
          "from": AppConfig.phoneNoID,
          "id": value['messages'][0]['id'],
          "context": {'from': AppConfig.phoneNoID, "id": swipedMessageId},
          "contacts": [
            {
              'name': {'first_name': fullName, 'formatted_name': fullName},
              'phones': [
                {'phone': message, 'type': 'Mobile'}
              ],
            }
          ],
          "type": "contacts",
          "timestamp": DateTime.now()
        };
      }

      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(AppConfig.WABAID)
          .collection("discussion")
          .doc(to.toString())
          .collection("messages")
          .add(firestoreObject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My conctacts")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
              controller: controller.searchQuery,
              onChanged: (value) {
                controller.updateFilteredContacts();
              },
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                  itemBuilder: (context, index) {
                    Contact currentContact = controller.filteredContacts[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await Get.defaultDialog(
                              radius: 10,
                              title:
                                  fromChat ? "Send Contact?" : "Add contact?",
                              middleText: fromChat
                                  ? "Would you like to share the following number : ${currentContact.phones.first.number.removeAllWhitespace}"
                                  : "Would you like to add the following number : ${currentContact.phones.first.number.removeAllWhitespace}",
                              confirm: ElevatedButton(
                                  onPressed: () async {
                                    int to = 0;
                                    if (currentContact
                                        .phones.first.number.removeAllWhitespace
                                        .startsWith("+")) {
                                      to = int.parse(currentContact.phones.first
                                          .number.removeAllWhitespace
                                          .substring(1));
                                    } else {
                                      to = int.parse(
                                          "91${currentContact.phones.first.number.removeAllWhitespace}");
                                    }

                                    if (fromChat) {
                                      sendContact('+$to',
                                          "${currentContact.name.first} ${currentContact.name.last}");
                                    } else {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             ChatPage()));
                                      await controller.whatsapp
                                          .messagesTemplate(
                                              templateName: "hello_world",
                                              to: to);
                                    }
                                    Get.showSnackbar(const GetSnackBar(
                                      messageText: Text("Message Sent"),
                                    ));
                                  },
                                  child: const SizedBox(
                                    width: double.infinity,
                                    child: Center(child: Text("Yes")),
                                  )),
                              cancel: OutlinedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const SizedBox(
                                    width: double.infinity,
                                    child: Center(child: Text("No")),
                                  )),
                            );
                          },
                          child: ListTile(
                              title: Text(
                                  "${currentContact.name.first} ${currentContact.name.last}"),
                              subtitle: Text(
                                currentContact?.phones.isNotEmpty == true
                                    ? currentContact!.phones.first.number
                                            ?.removeAllWhitespace ??
                                        "No phone number"
                                    : "No phone number",
                                style: TextStyle(fontSize: 16),
                              )
                              //Text(currentContact
                              // .phones.first.number.removeAllWhitespace),
                              ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const Divider(
                            thickness: 1,
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: controller.filteredContacts.length),
            ),
          ),
        ],
      ),
    );
  }
}
