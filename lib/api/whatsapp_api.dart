library whatsapp;

import 'dart:async';
import 'dart:convert';
import 'package:STARZ/screens/chat/chat_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
//import 'package:starz/config.dart';

class WhatsAppApi {
  String? _accessToken;
  int? _fromNumberId;
  Map<String, String>? _headers;

  /// Configure the WhatsApp API with access token and from number id.
  /// [accessToken] is the access token of the WhatsApp API.
  /// [fromNumberId] is the from number id of the WhatsApp API.
  setup({accessToken, int? fromNumberId}) {
    _accessToken = accessToken;
    _fromNumberId = fromNumberId;
    _headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_accessToken"
    };
  }

  /// Generate the short link of the WhatsApp.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [message] is the message to be sent.
  /// [compress] is the compress of the WhatsApp's link.
  downloadPDF(String id) async {
    var link = await getMediaUrl(mediaId: id);
    var res = await http.get(Uri.parse(link['url']),
        headers: {"Authorization": "Bearer $_accessToken"});

    print(res.bodyBytes);
  }

  short({int? to, String? message, bool? compress}) {
    if (compress == true) {
      return 'https://wa.me/$to?text=$message';
    } else {
      return 'https://api.whatsapp.com/send?phone=$to&text=$message';
    }
  }

  /// Send the template to the client.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [templateName] is the template name.
  Future messagesTemplate({
    int? to,
    String? mediaUrl,
    String? text,
    String? templateName,
    Map<String, String>? variables,
    String? language,
    Component? templateHeaderFormat,
    Map<String, dynamic>? location,
  }) async {
    final templateBlock = {
      "type": "button",
      "sub_type": "flow",
      "index": "0",
    };

    try {
      var url = 'https://graph.facebook.com/v19.0/$_fromNumberId/messages';
      Uri uri = Uri.parse(url);

      Map<String, dynamic> headerComponent = {
        "type": "HEADER",
        "parameters": []
      };

      if (mediaUrl != null && templateHeaderFormat != null) {
        if (templateHeaderFormat.format == 'IMAGE') {
          print('++++++++++++ITS IMAGE FORMAT HEADER TEMPLATE++++++++++++');
          headerComponent["parameters"] = [
            {
              "type": "image",
              "image": {"link": mediaUrl},
            },
          ];
        } else if (templateHeaderFormat.format == 'VIDEO') {
          print('++++++++++++ITS VIDEO FORMAT HEADER TEMPLATE++++++++++++');
          headerComponent["parameters"] = [
            {
              "type": "video",
              "video": {"link": mediaUrl},
            },
          ];
        } else if (templateHeaderFormat.format == 'DOCUMENT') {
          print('++++++++++++ITS DOCUMENT FORMAT HEADER TEMPLATE++++++++++++');
          headerComponent["parameters"] = [
            {
              "type": "document",
              "document": {"link": mediaUrl},
            },
          ];
        }
      } else if (templateHeaderFormat?.format == 'LOCATION') {
        print('++++++++++++ITS LOCATION FORMAT HEADER TEMPLATE++++++++++++');
        headerComponent = {
          "type": "header",
          "parameters": [
            {
              "type": "location",
              "location": location ??
                  {
                    "latitude": 0.0,
                    "longitude": 0.0,
                    "name": "Location Name",
                    "address": "Location Address",
                  },
            },
          ],
        };
      } else {
        headerComponent = {"type": "header", "parameters": []};
      }

      Map data = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": to,
        "type": "template",
        "template": {
          "name": templateName,
          "language": {"code": language},
          "components": [
            templateBlock,
            headerComponent,
            {
              "type": "body",
              "parameters": [
                // Iterate over the variables map and add them as text parameters
                for (var entry in variables!.entries)
                  {
                    "type": "text",
                    "text": entry.value, // Use the value from the variables map
                  },
              ],
            },
          ],
        },
      };

      var body = json.encode(data);
      print('Request Payload ++++++++++ $body');

      var response = await http.post(uri, headers: _headers, body: body);
      print('Response Status Code ++++++++++ ${response.statusCode}');
      print('Response ++++++++++ $response');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Response ++++++++++ ${response.body}');
        Fluttertoast.showToast(
          msg: '$templateName Template sent successfully!\nto $to',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return json.decode(response.body);
      } else {
        print('Failed to send template message. Status Code: ${response.body}');
        if (responseData.containsKey("error")) {
          // If there was an error, attempt to send using components array directly
          print("Attempting to send using components array directly...");

          var url = 'https://graph.facebook.com/v19.0/$_fromNumberId/messages';
          Uri uri = Uri.parse(url);

          Map destructedData = {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": to,
            "type": "template",
            "template": {
              "name": templateName,
              "language": {"code": language},
              "components": [
                headerComponent,
                {
                  "type": "body",
                  "parameters": [
                    // Iterate over the variables map and add them as text parameters
                    for (var entry in variables!.entries)
                      {
                        "type": "text",
                        "text":
                            entry.value, // Use the value from the variables map
                      },
                  ],
                },
              ],
            },
          };

          var body = json.encode(destructedData);
          print('Request Payload ++++++++++ $body');

          var componentsResponse =
              await http.post(uri, headers: _headers, body: body);
          print(
              'Component Response Status Code ++++++++++ ${componentsResponse.statusCode}');
          print('Component Response ++++++++++ $componentsResponse');

          final Map<String, dynamic> componentsResponseData =
              jsonDecode(componentsResponse.body);

          if (componentsResponseData.containsKey("error")) {
            print(
                "Error with components array: ${componentsResponseData['error']}");
          } else {
            print("Message sent using components array directly");
            if (componentsResponse.statusCode == 200) {
              print(
                  'Destructed Response ++++++++++ ${componentsResponse.body}');
              Fluttertoast.showToast(
                msg: '$templateName Template sent successfully!\nto $to',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return json.decode(componentsResponse.body);
            }
          }
        } else {
          // Display the toast message only if the response status code is not 200
          Fluttertoast.showToast(
            msg: 'Failed to send $templateName\nTemplate message to $to',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return response.body;
        }
      }
    } catch (e) {
      print('Exception while sending template message: $e');
      Fluttertoast.showToast(
        msg: 'Error sending template message',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }

  ///Function for starting the conversation for first time
  Future addMessagesTemplate({int? to, String? templateName}) async {
    try {
      var url = 'https://graph.facebook.com/v19.0/$_fromNumberId/messages';
      Uri uri = Uri.parse(url);

      Map data = {
        "messaging_product": "whatsapp",
        "recipient_type": "individual",
        "to": to,
        "type": "template",
        "template": {
          "name": templateName,
          "language": {"code": "en"},
          "components": [
            // {
            //   "type": "header",
            //   "parameters": [
            //     {
            //       "type": "image",
            //       "image": {
            //         "link":
            //             "https://media.licdn.com/dms/image/C4D1BAQHNIK5YNTcgWA/company-background_10000/0/1605548774095/starzventures_cover?e=2147483647&v=beta&t=ucC-jW6F52W7udmMLWBqs3f_4JbM0TF-4fF1M-c1_Ls"
            //       },
            //     },
            //   ],
            // },
            {"type": "body", "parameters": []}
          ]
        }
      };

      var body = json.encode(data);

      var response = await http.post(uri, headers: _headers, body: body);
      print('Response ++++++++++ $response');
      if (response.statusCode == 200) {
        print('Response ++++++++++ ${response.body}');
        Fluttertoast.showToast(
          msg: '$to Added',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return json.decode(response.body);
      } else {
        print('Failed to send template message. Status Code: ${response.body}');
        Fluttertoast.showToast(
          msg: 'Failed to add $to',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return response.body;
      }
    } catch (e) {
      print('Exception while sending template message: $e');
      return null;
    }
  }

  ///Function for catalog sending message of single product
  ///One product at a time
  ///Graph API to send catalog message one at a time
  Future messagesSingleCatalog(
      {int? to,
      String? catalogId,
      String? productRetailerId,
      String? bodyText,
      String? footerText}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "interactive",
      "interactive": {
        "type": "product",
        "body": {"text": bodyText},
        "footer": {"text": footerText},
        "action": {
          "catalog_id": catalogId,
          "product_retailer_id": productRetailerId
        }
      }
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    print('Response ++++++++++ $response');
    try {
      print('Response ++++++++++ ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  ///Function for catalog sending message of single product
  ///One product at a time
  ///Graph API to send catalog message one at a time
  Future messagesMultiCatalog({
    int? to,
    String? catalogId,
    List<String>? productRetailerIds,
    String? bodyText,
    String? footerText,
    String? headerText,
    String? sectionTitle,
  }) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "interactive",
      "interactive": {
        "type": "product_list",
        "header": {"type": "text", "text": headerText},
        "body": {"text": bodyText},
        "footer": {"text": footerText},
        "action": {
          "catalog_id": catalogId,
          "sections": [
            {
              "title": sectionTitle,
              "product_items": productRetailerIds
                  ?.map((retailerId) => {"product_retailer_id": retailerId})
                  .toList(),
            }
          ]
        }
      }
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    print('Response ++++++++++ $response');
    try {
      print('Response ++++++++++ ${response.body}');
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Send the text message to the client.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [message] is the message to be sent.
  /// [previewUrl] is used to preview the URL in the chat window.
  Future messagesText({
    int? to,
    String? message,
    bool? previewUrl,
  }) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "text",
      "text": {"preview_url": previewUrl, "body": message}
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  Future messagesContacts(
      {int? to, String? phoneNumber, String? fullName}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "contacts",
      "contacts": [
        {
          'name': {'first_name': fullName, 'formatted_name': fullName},
          'phones': [
            {'phone': phoneNumber, 'type': 'Mobile'}
          ],
        }
      ]
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Send the media files to the client.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [mediaType] is the type of media such as image, document, sticker, audio or video
  /// [mediaId] use this edge to retrieve and delete media.
  Future messagesMedia({
    to,
    mediaType,
    mediaId,
    // String? templateBody,
    // String? templateFooter,
  }) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);
    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": mediaType,
      "$mediaType": {"id": mediaId}
    };

    // if (templateBody != null && templateFooter != null) {
    //   // Include template text if provided
    //   data["text"] = {
    //     "body": templateBody,
    //     "footer": templateFooter,
    //   };
    // }

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      print('Error decoding response: $e');
      return response.body;
    }
  }

  /// Send the location to the client.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [longitude] is the longitude of the location.
  /// [latitude] is the latitude of the location.
  /// [name] is the name of the location.
  /// [address] is the full address of the location.
  Future messagesLocation({to, longitude, latitude, name, address}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "to": to,
      "type": "location",
      "location": {
        "longitude": longitude,
        "latitude": latitude,
        "name": name,
        "address": address
      }
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  Future messagesLocationReply(
      {to, longitude, latitude, name, address, messageId}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "to": to,
      "type": "location",
      "context": {'id': messageId},
      "location": {
        "longitude": longitude,
        "latitude": latitude,
        "name": name,
        "address": address
      }
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Send media messages to the client.
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [mediaType] is type of media such as image, document, sticker, audio or video
  /// [mediaLink] is media to be sent.
  /// [caption] is caption of media
  Future messagesMediaByLink({to, mediaType, mediaLink, caption}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": mediaType,
      "$mediaType": {"caption": caption, "link": mediaLink}
    };

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Emoji React to Any Message
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [messageId] is the message id.
  /// [emoji] is the emoji to be sent.
  // Future messagesReaction({to, messageId, emoji}) async {
  //   var url = 'https://graph.facebook.com/v17.0/$_fromNumberId/messages';

  //   Map data = {
  //     "messaging_product": "whatsapp",
  //     "recipient_type": "individual",
  //     "to": to,
  //     "type": "reaction",
  //     "reaction": {"message_id": messageId, "emoji": emoji}
  //   };

  //   var body = json.encode(data);

  //   var response =
  //       await http.post(Uri.parse(url), headers: _headers, body: body);
  //   try {
  //     return json.decode(response.body);
  //   } catch (e) {
  //     return response.body;
  //   }
  // }

  /// Reply to a message
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [messageId] is the message id.
  /// [message] is the message to be sent.
  /// [previewUrl] is used to preview the URL in the chat window.
  Future messagesReply({to, messageId, message, phoneNumber}) async {
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "context": {"message_id": messageId},
      "type": "text",
      "text": {"body": message},
      "fcm": fcmToken
    };

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  Future messagesContactsReply(
      {int? to, String? phoneNumber, String? fullName, messageId}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';
    Uri uri = Uri.parse(url);

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "context": {"message_id": messageId},
      "type": "contacts",
      "contacts": [
        {
          'name': {'first_name': fullName, 'formatted_name': fullName},
          'phones': [
            {'phone': phoneNumber, 'type': 'Mobile'}
          ],
        }
      ]
    };

    var body = json.encode(data);

    var response = await http.post(uri, headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Reply to a media by ID
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [messageId] is the message id.
  /// [mediaType] is type of media such as image, document, sticker, audio or video
  /// [mediaId] is id of media to be replay.
  Future messagesReplyMedia({
    to,
    messageId,
    mediaType,
    mediaId,
    // String? templateBody,
    // String? templateFooter,
  }) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "context": {"message_id": messageId},
      "type": mediaType,
      "$mediaType": {"id": mediaId}
    };

    // if (templateBody != null && templateFooter != null) {
    //   // Include template text if provided
    //   data["text"] = {
    //     "body": templateBody,
    //     "footer": templateFooter,
    //   };
    // }

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      print('Error decoding response: $e');
      return response.body;
    }
  }

  /// Reply to a media by URL
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [messageId] is the message id.
  /// [mediaType] is type of media such as image, document, sticker, audio or video
  /// [mediaLink] is link of media to be sent.
  /// [caption] is caption of media to be sent.
  Future messagesReplyMediaUrl(
      {to, messageId, mediaType, mediaLink, caption}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "context": {"message_id": messageId},
      "type": mediaType,
      "$mediaType": {"link": mediaLink, "caption": caption}
    };

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Register a phone number
  /// [pin] is 6-digit pin for register number.
  Future registerNumber({pin}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/register';

    Map data = {"messaging_product": "whatsapp", "pin": pin};

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Set Two Step Verification Code
  /// [pin] is 6-digit pin for two step verification.
  Future setTwoStepVerification({pin}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/register';

    Map data = {"pin": pin};

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Deregister a phone number
  /// [pin] is 6-digit pin for deregister number.
  Future deregisterNumber({pin}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/deregister';

    Map data = {"pin": pin};

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Get Shared WhatsApp Business Account Id
  /// [inputToken] is token generated after embedding the signup flow
  Future getWhatsAppBusinessAccounts({inputToken}) async {
    var url =
        'https://graph.facebook.com/v18.0/debug_token?input_token=$inputToken';

    var response = await http.get(Uri.parse(url), headers: _headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Get Shared WhatsApp Business Accounts Lists (WABAs)
  /// [accountId] is Business manager account Id
  Future getWhatsAppBusinessAccountsList({accountId}) async {
    var parseAccountId = accountId.toString();
    var url =
        'https://graph.facebook.com/v18.0/$parseAccountId/client_whatsapp_business_accounts';

    var response = await http.get(Uri.parse(url), headers: _headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Send message with action buttons for choice
  /// [to] is the phone number with country code but without the plus (+) sign.
  /// [bodyText] is the main body text of message
  /// [buttons] is list of action buttons with id and text
  messagesButton({to, bodyText, buttons}) async {
    var url = 'https://graph.facebook.com/v18.0/$_fromNumberId/messages';

    var buttonsList = [];
    for (var i = 0; i < buttons.length; i++) {
      buttonsList.add({
        "type": "reply",
        "reply": {"id": buttons[i]["id"], "title": buttons[i]["text"]}
      });
    }

    Map data = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "interactive",
      "interactive": {
        "type": "button",
        "body": {"text": bodyText},
        "action": {"buttons": buttonsList}
      }
    };

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  ///Upload Media to WhatsApp Business
  ///[mediaFile] is the file object to be send
  ///[mediaName] is the name of file
  uploadMedia({required mediaFile, mediaType, mediaName}) async {
    var uri =
        Uri.parse('https://graph.facebook.com/v18.0/$_fromNumberId/media');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers!);
    request.fields['messaging_product'] = 'whatsapp';

    // Set the Content-Disposition header with the filename
    request.headers['Content-Disposition'] =
        'attachment; filename="$mediaName"';

    request.files.add(http.MultipartFile.fromBytes(
        'file', File(mediaFile.path).readAsBytesSync(),
        filename: mediaName, contentType: mediaType));

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    print('response ========= $respStr');
    try {
      return json.decode(respStr);
    } catch (e) {
      return respStr;
    }
  }

  /// Retrive URL of media
  /// [mediaId] is id of media file
  Future getMediaUrl({mediaId}) async {
    var url = 'https://graph.facebook.com/v18.0/$mediaId';

    var response = await http.get(Uri.parse(url), headers: _headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  Future getMediaUrlForRply({mediaId}) async {
    var url = 'https://graph.facebook.com/v18.0/$mediaId';

    var response = await http.get(Uri.parse(url), headers: _headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Delete uploaded media
  /// [mediaId] is id of media file
  Future deleteMedia({mediaId}) async {
    var url = 'https://graph.facebook.com/v18.0/$mediaId';

    var response = await http.delete(Uri.parse(url), headers: _headers);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }

  /// Update WhatsApp Business Account Details
  /// [businessAddress] is address of business
  /// [businessDescription] is description of business
  /// [businessIndustry] is industry of business
  /// [businessAbout] is about of your business
  /// [businessEmail] is email of your business
  /// [businessWebsites] is list of website to update
  /// [businessProfileId] is image handle id to update profile picture of business
  Future updateProfile(
      {businessAddress,
      businessDescription,
      businessIndustry,
      businessAbout,
      businessEmail,
      required List businessWebsites,
      businessProfileId}) async {
    var url =
        'https://graph.facebook.com/v18.0/$_fromNumberId/whatsapp_business_profile';

    Map data = {
      "messaging_product": "whatsapp",
      "address": businessAddress,
      "description": businessDescription,
      "vertical": businessIndustry,
      "about": businessAbout,
      "email": businessEmail,
      "websites": businessWebsites,
      "profile_picture_handle": businessProfileId
    };

    var body = json.encode(data);

    var response =
        await http.post(Uri.parse(url), headers: _headers, body: body);
    try {
      return json.decode(response.body);
    } catch (e) {
      return response.body;
    }
  }
}
