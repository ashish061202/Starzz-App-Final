import 'package:STARZ/screens/chat/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:get/get.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/controllers/conctacts_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../config.dart';

class PhoneContactsPage extends GetView<ConctactsController> {
  PhoneContactsPage({super.key});

  static const id = "/phone_contacts";
  bool fromChat = Get.arguments['fromChat'];
  int? to = Get.arguments['to'];
  WhatsAppApi? whatsApp = Get.arguments['whatsAppApi'];
  String? swipedMessageId = Get.arguments['swipedMessageId'];
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollController _alphabetScrollController = ScrollController();

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
      appBar: AppBar(
        title: Text(
          "My contacts",
          style: TextStyle(
            color: Get.isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: Get.isDarkMode
            ? Colors.black54
            : const Color.fromRGBO(97, 64, 196, 1),
      ),
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
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ScrollablePositionedList.builder(
                      itemScrollController: _scrollController,
                      itemCount: controller.filteredContacts.length,
                      itemBuilder: (context, index) {
                        Contact currentContact =
                            controller.filteredContacts[index];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await Get.defaultDialog(
                                  radius: 10,
                                  title: fromChat
                                      ? "Send Contact?"
                                      : "Add contact?",
                                  middleText: fromChat
                                      ? "Would you like to share the following number : ${currentContact.phones.first.number.removeAllWhitespace}"
                                      : "Would you like to add the following number : ${currentContact.phones.first.number.removeAllWhitespace}",
                                  confirm: ElevatedButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        int to = 0;
                                        String phoneNumber = currentContact
                                            .phones
                                            .first
                                            .number
                                            .removeAllWhitespace
                                            .replaceAll("-", "");
                                        if (phoneNumber.startsWith("+")) {
                                          to = int.parse(currentContact.phones
                                              .first.number.removeAllWhitespace
                                              .substring(1));
                                        } else {
                                          to = int.parse("91$phoneNumber");
                                        }

                                        if (fromChat) {
                                          sendContact('+$to',
                                              "${currentContact.name.first} ${currentContact.name.last}");
                                        } else {
                                          Get.back();
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             ChatPage(prefs: SharedPreferences,)));
                                          await controller.whatsapp
                                              .addMessagesTemplate(
                                                  templateName: "hello",
                                                  to: to);
                                        }
                                        // After sending the message, navigate to ChatPage
                                        Get.toNamed(ChatPage.id, arguments: {
                                          "roomId": to.toString(),
                                          "prefs": prefs,
                                          "to": to.toString(),
                                          "userName&Num":
                                              "${currentContact.name.first} ${currentContact.name.last!}",
                                        });
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
                                    style: const TextStyle(fontSize: 16),
                                  )
                                  //Text(currentContact
                                  // .phones.first.number.removeAllWhitespace),
                                  ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: const Divider(
                                thickness: 1,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // Alphabetical scrollbar
                SizedBox(
                  width: 20.0, // Add a fixed width here
                  child: Scrollbar(
                    controller: _alphabetScrollController,
                    thickness: 8.0,
                    trackVisibility: true,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          trackVisibility:
                              const ScrollbarThemeData().trackVisibility,
                        ),
                      ),
                      child: ListView.separated(
                        controller: _alphabetScrollController,
                        itemCount: 26,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 2.0),
                        itemBuilder: (context, index) {
                          String alphabet = String.fromCharCode(65 + index);
                          return GestureDetector(
                            onTap: () {
                              // Scroll to the corresponding index
                              _scrollController.scrollTo(
                                index: controller
                                    .getIndexOfFirstContactWithLetter(alphabet),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                alphabet,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*//Unlock only for trigger access
/*
ScriptApp.newTrigger("main")
  .timeBased()
  .everyMinutes(10)
  .create();
*/
// Set the specific time for the trigger (in 24-hour format)


const WHATSAPP_ACCESS_TOKEN = "EAAMEyX45PoMBO9E8i4nnhRcAZCB9yHDdAZBdGYWj7gZCZBfSyGkihb163kzXFIsrR2ara6JmlHbmu259ZBmdZAouZANF0A0faJNvjEp5TuQybMAW03XyvYnN5Q5lX21c5aRgPJRcxrFZCAISw9jP8DDcdvjXNtkQ4CIkBY2AnYsjGCNlNeuXauNfOI5nWPw72KmpZAZBp23YdCzLIsJ2cqnhCCT3hFw8n2oF5vZB4crGNsZD";
const WHATSAPP_TEMPLATE_NAME = "media_test";
const LANGUAGE_CODE = "en";

const sendMessage_ = ({
  recipient_number,
  customer_name,
  item_name,
  delivery_date,
}) => {
  const apiUrl = "https://graph.facebook.com/v17.0/170851489447426/messages";    
  const request = UrlFetchApp.fetch(apiUrl, {
    muteHttpExceptions: true,
    method: "POST",
    headers: {
      Authorization: Bearer ${WHATSAPP_ACCESS_TOKEN},
      "Content-Type": "application/json",
    },
    payload: JSON.stringify({
      messaging_product: "whatsapp",
      type: "template",
      to: recipient_number,
      template: {
        name: WHATSAPP_TEMPLATE_NAME,
        language: { code: LANGUAGE_CODE },
      
        components: [
//  flow code
   /*        [
    {
      "type": "body",
      "text": "This is a flows as template demo"
    },
    {
      "type": "BUTTONS",
      "buttons": [
        {
          "type": "FLOW",
          "text": "Open flow!",
          "flow_id": "378506304641341",
          "navigate_screen":  "Flows Json screen name",
          "flow_action": "navigate"
        }
      ]
    }
  ],*/
// flow code
          {
            type: "header", 
            parameters: [
            
             /*0 {
                
                type: "video", 
                video: {
                  link: "https://youtu.be/54KcLBAHnhw" // Video URL
                },
              },
              {
                
                type: "documents", 
                video: {
                  link: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf" // Doc URL
                },
              },
              */
             {
                type: "image", 
                image: {
                  link: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/1200px-Image_created_with_a_mobile_phone.png" // Image URL
                },
              },
            ],
          },
      

          {
            type: "body",
            parameters: [
            
          /*  { 
                type: "text",
                text: customer_name,
              },
           */
             /*
              {
                type: "text",
                text: item_name,
              },
              {
                type: "text",
                text: delivery_date,
              },
              */
            ],
          },
        ],
      },
    }),
  });

  
  const { error } = JSON.parse(request);
  const status = error ? Error: ${JSON.stringify(error)} : Message sent to ${recipient_number};
  Logger.log(status);
};

const getSheetData_ = () => {
  const [header, ...rows] = SpreadsheetApp.getActiveSheet().getDataRange().getDisplayValues();
  const data = [];
  rows.forEach((row) => {
    const recipient = { };
    header.forEach((title, column) => {
      recipient[title] = row[column];
    });
    data.push(recipient);
  });
  return data;
};

const main = () => {
  const data = getSheetData_();
  data.forEach((recipient) => {
      const status = sendMessage_({
        recipient_number: recipient["Phone Number"].replace(/[^\d]/g, ""),
     //customer_name: recipient["Customer Name"],
        //item_name: recipient["Item Name"],
        //delivery_date: recipient["Delivery Date"],
      });
  });
}; */
