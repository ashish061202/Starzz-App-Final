import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:multiple_result/multiple_result.dart';
import 'package:starz/models/phone_number_model.dart';

import '../config.dart';
import '../models/retrieve_media_model.dart';

class APIService {
  static var client = http.Client();

//!Register API
  static Future<Result<bool, String>> registerUser(String pin) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.registerAPI);
    try {
      var response = await client.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(
          {
            "messaging_product": "whatsapp",
            "pin": pin,
          },
        ),
      );
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body)['error']['message']);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  ///!Deregister
  static Future<Result<bool, String>> deregisterUser() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.deregister);
    try {
      var response = await client.post(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body)['error']['message']);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!Get Business Profile
  static Future<Result<Map<String, dynamic>, String>>
      getBusinessProfile() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.getBusinessIdProfile);
    try {
      var response = await client.get(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body));
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!update whatsapp_business_profile
  static Future<Result<Map<String, dynamic>, String>>
      updateWhatsappBusinessProfile(
    String address,
    String businessDescription,
    String businessIndustry,
    String profileAboutText,
    String businessEmail,
    List<String> websitesUrls,
    String IMAGE_HANDLE_ID,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.updateWhatsappBusinessProfile);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "address": address,
            "description": businessDescription,
            "vertical":
                businessIndustry, //? vertical must be one of {OTHER, AUTO, BEAUTY, APPAREL, EDU, ENTERTAIN, EVENT_PLAN, FINANCE, GROCERY, GOVT, HOTEL, HEALTH, NONPROFIT, PROF_SERVICES, RETAIL, TRAVEL, RESTAURANT}.
            "about": profileAboutText,
            "email": businessEmail,
            "websites": websitesUrls,
            "profile_picture_handle": IMAGE_HANDLE_ID,
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body));
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!Retrieve media url
  static Future<Result<RetrieveMediaModel, String>> retrieveMediaUrl(
      String imageId) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        imageId +
        "?phone_number_id=" +
        AppConfig.phoneNoID);
    try {
      var response = await client.get(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return Success(retrieveMediaModelFromJson(response.body));
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

//!Delete Media
  static Future<Result<bool, String>> deleteMedia(String mediaId) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        mediaId +
        "?phone_number_id=" +
        AppConfig.phoneNoID);
    try {
      var response = await client.delete(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!Download Media
  static Future<Result<bool, String>> downMedia(String mediaId) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL + AppConfig.version + mediaId);
    try {
      var response = await client.get(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //?! SEND MESSAGES SECTION

  //!send text message
  static Future<Result<String, String>> sendTextMessage(
      String body, String recipientPhoneNumber) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "type": "text",
            "text": {"preview_url": false, "body": body}
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!reply text message
  static Future<Result<String, String>> replyTextMessage(String body,
      String recipientPhoneNumber, String messageIdOfPrevMsg) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "context": {"message_id": messageIdOfPrevMsg},
            "type": "text",
            "text": {"preview_url": false, "body": body}
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!reply text message with PreviewUrl
  static Future<Result<String, String>> sendTextMessageWithPreviewUrl(
    String body,
    String recipientPhoneNumber,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "to": recipientPhoneNumber,
            "text": {
              "preview_url": true,
              "body":
                  body, //"Please visit https://youtu.be/hpltvTEiRrY to inspire your day!"
            }
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!reply text message with reaction
  static Future<Result<String, String>> sendTextMessageWithReaction(
    String emoji,
    String recipientPhoneNumber,
    String messageId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "type": "reaction",
            "reaction": {
              "message_id": messageId,
              "emoji": emoji,
            }
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!send image message byId
  static Future<Result<String, String>> sendImageMessageById(
    String imageId,
    String recipientPhoneNumber,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "type": "image",
            "image": {
              "id": imageId,
            }
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!send reply to image by  messageId
  static Future<Result<String, String>> sendReplyImageByMsgId(
    String imageId,
    String recipientPhoneNumber,
    String prevMsgId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "context": {"message_id": prevMsgId},
            "type": "image",
            "image": {"id": imageId}
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!send image message by Url
  static Future<Result<String, String>> sendImageMessageByImageUrl(
    String recipientPhoneNumber,
    String imageLink,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "type": "image",
            "image": {
              "link": imageLink,
            }
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!reply image message by Url
  static Future<Result<String, String>> replyImageMessageByImageUrl(
    String recipientPhoneNumber,
    String imageLink,
    String prevMsgId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "context": {
              "message_id": prevMsgId,
            },
            "type": "image",
            "image": {
              "link": imageLink,
            }
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!send audio message by Id
  static Future<Result<String, String>> sendAudioMessageById(
    String recipientPhoneNumber,
    String audioId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "type": "audio",
            "audio": {"id": audioId}
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!reply to audio message by Id
  static Future<Result<String, String>> replyToAudioMessageById(
    String recipientPhoneNumber,
    String audioId,
    String messageId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": recipientPhoneNumber,
            "context": {"message_id": messageId},
            "type": "audio",
            "audio": {"id": audioId}
          }));
      if (response.statusCode == 200) {
        return Success(jsonDecode(response.body)['messages'][0]['id']);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!mark message as read
  static Future<Result<bool, String>> markMessageAsRead(
    String incomingMessageId,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.sendMessage);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "messaging_product": "whatsapp",
            "status": "read",
            "message_id": incomingMessageId,
          }));
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!get phone numbers
  Future<Result<PhoneNumberModel, String>> getPhoneNumber() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.WABAID +
        AppConfig.phoneNumbers);
    try {
      var response = await client.get(
        url,
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        return Success(PhoneNumberModel.fromJson(jsonDecode(response.body)));
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!request Verification code
  static Future<Result<bool, String>> requestVerificationCode() async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.requestCode);
    try {
      var response = await client.post(url,
          headers: requestHeaders,
          body: jsonEncode({"code_method": "SMS", "locale": "en_US"}));
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  //!Verify code
  static Future<Result<bool, String>> verifyCode(
    String code,
  ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${AppConfig.apiKey}"
    };
    var url = Uri.parse(AppConfig.apiURL +
        AppConfig.version +
        AppConfig.phoneNoID +
        AppConfig.verifyCode);
    try {
      var response = await client.post(url,
          headers: requestHeaders, body: jsonEncode({"code": code}));
      if (response.statusCode == 200) {
        return const Success(true);
      } else {
        return Error(jsonDecode(response.body));
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
