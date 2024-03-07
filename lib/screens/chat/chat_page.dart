//import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:STARZ/screens/chat/ContactDetailsScreen.dart';
import 'package:STARZ/screens/chat/file_helper.dart';
import 'package:STARZ/screens/chat/notification_util.dart';
import 'package:STARZ/widgets/custom_card_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as LocalNotifications;
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
//import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:STARZ/api/whatsapp_api.dart';
import 'package:STARZ/main.dart';
import 'package:STARZ/models/message.dart';
import 'package:STARZ/screens/auth/wabaid_controller.dart';
import 'package:STARZ/screens/chat/camera_screen.dart';
import 'package:STARZ/screens/chat/profile_photo_view.dart';
import 'package:STARZ/services/location.dart';
import 'package:STARZ/widgets/background_image.dart';
import 'package:STARZ/widgets/reply_message_card_reply.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../widgets/own_message_card.dart';
import '../../widgets/reply_card.dart';
import '../../config.dart';
import '../phone_contacts/phone_contacts_page.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:firebase_cloud_messaging/firebase_cloud_messaging.dart';
//import 'package:camera/camera.dart';

class TemplateMessage {
  String name;
  String id;
  String text;
  String? footerText;
  String language;
  String status;
  String category;
  List<Component> components;
  String? imageUrl;
  Example? example;

  TemplateMessage({
    required this.name,
    required this.id,
    required this.text,
    required this.language,
    required this.status,
    required this.category,
    required this.components,
    required this.footerText,
    this.imageUrl,
    this.example,
  });

  // Factory method to create TemplateMessage from API response
  factory TemplateMessage.fromJson(Map<String, dynamic> json) {
    List<Component> components = (json['components'] as List<dynamic>?)
            ?.map((component) => Component.fromJson(component))
            .toList() ??
        [];

    // Check if 'HEADER' components exist
    Component? headerComponent = components.firstWhereOrNull((component) =>
        component.type == 'HEADER' && component.format == 'IMAGE' ||
        component.format == 'VIDEO' ||
        component.format == 'DOCUMENT' ||
        component.format == 'LOCATION');

    // Check if 'BODY' components exist
    Component? bodyComponent = components.firstWhereOrNull(
        (component) => component.type == 'BODY' && component.text != null);

    // Check if 'FOOTER' components exist
    Component? footerComponent = components.firstWhereOrNull(
        (component) => component.type == 'FOOTER' && component.text != null);

    return TemplateMessage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      text: bodyComponent?.text ?? '',
      language: json['language'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      imageUrl: headerComponent?.example.headerHandle.firstOrNull,
      components: components,
      example: bodyComponent?.example,
      footerText: footerComponent?.text,
      // Add more fields if needed
    );
  }
}

class Component {
  String type;
  String format;
  String? text;
  Example example;

  Component(
      {required this.type,
      required this.format,
      required this.example,
      required this.text});

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      type: json['type'] ?? '',
      format: json['format'] ?? '',
      text: json['text'],
      example: Example.fromJson(json['example'] ?? {}),
    );
  }
}

class Example {
  List<String> headerHandle;
  List<List<String>>? bodyText;
  String? footerText;

  Example({required this.headerHandle, this.bodyText, this.footerText});

  factory Example.fromJson(Map<String, dynamic> json) {
    List<dynamic>? components = json['components'] as List<dynamic>?;

    List<String> headerHandle = (json['header_handle'] as List<dynamic>?)
            ?.map((handle) => handle.toString())
            .toList() ??
        [];
    List<List<String>>? bodyText = (json['body_text'] as List<dynamic>?)
            ?.map<List<String>>((item) =>
                (item as List<dynamic>).map((e) => e.toString()).toList())
            .toList() ??
        [];

    String? footerText;

    if (components != null) {
      for (var component in components) {
        if (component['type'] == 'FOOTER' && component['text'] != null) {
          footerText = component['text'].toString();
          break;
        }
      }
    }

    return Example(
      headerHandle: headerHandle,
      bodyText: bodyText,
      footerText: footerText,
    );
  }
}

class CatalogItem {
  String id;
  String name;
  String retailerId;
  // Add more fields as needed

  CatalogItem({
    required this.id,
    required this.name,
    required this.retailerId,
    // Add more constructor parameters as needed
  });

  // Factory method to create CatalogItem from API response
  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      retailerId: json['retailer_id'] ?? '',
      // Map additional fields from the API response
      // Example: description: json['description'] ?? '',
    );
  }
}

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage({
    Key? key,
    required this.prefs,
  }) : super(key: key) {
    roomId = Get.arguments['roomId'];
    phoneNumber = Get.arguments['to'];
    userName = Get.arguments['userName&Num'];
    whatsApp = WhatsAppApi();
    whatsApp.setup(
        accessToken: AppConfig.apiKey,
        fromNumberId: int.tryParse(phoneNumberId));
  }

  late WhatsAppApi whatsApp;
  static const id = "/chatPage";
  late String phoneNumber;
  late String userName;
  final wabaidController = Get.find<WABAIDController>();
  late String phoneNumberId = wabaidController.phoneNumber;
  late String roomId;
  final SharedPreferences prefs;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Stream<dynamic> messagesStream;
  List<Message> messages = [];
  bool isWidgetMounted = false;
  bool isUserScrolling = false;
  bool shouldScrollToBottom = true;
  bool isAutoScrollEnabled = true;
  bool showInkEffect = false;
  int highlightedIndex = -1;
  late FirebaseMessaging _firebaseMessaging;
  late LocalNotifications.FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin;
  late String enteredWABAID;
  final wabaidController = Get.find<WABAIDController>();
  late String phoneNumberId = wabaidController.phoneNumber;

  bool show = false;
  FocusNode focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool sendButton = false;
  final audioRecorder = FlutterSoundRecorder();
  bool isAudioRecordedReady = false;
  bool isRecording = false;
  Message? swipedMessage;
  bool? _isNumberVisible;
  String? lastNotifiedMessageId;
  bool isChatPageOpen = false;
  bool isChatPageOpenedDuringSession = false;
  late Timestamp? lastNotifiedMessageTimestamp = null;
  bool shouldNotifyOnOpen = true;
  DateTime? _lastDisplayedDate;
  Map<String, DateTime> _lastDisplayedDates = {};
  // List<DateTime> _groupedDates = [];
  // int _messagesInSameGroup = 0;
  // Set<String> _displayedDates = {};
  Map<String, bool> isAnySuggestionUsed = {};
  late SharedPreferences prefs;
  bool autoReplySent = false;
  bool isAutoReplySent = false;
  late CollectionReference _reference;
  late TextEditingController catalogIdController;
  late SharedPreferences _prefs;
  Set<String> storedCatalogIds = {};

  @override
  void initState() {
    super.initState();
    catalogIdController = TextEditingController();
    _initializeSharedPreferencesForCatalogs();

    final wabaidController = Get.find<WABAIDController>();
    enteredWABAID = wabaidController.enteredWABAID;
    print("Entered WABAID: $enteredWABAID");

    _reference = FirebaseFirestore.instance
        .collection('accounts')
        .doc(enteredWABAID)
        .collection('templates');

    // Subscribe to FCM topic based on the phone number
    //FirebaseMessaging.instance.subscribeToTopic(widget.phoneNumber);

    _initSharedPreferences();

    // Load unread count from file when chat page is opened
    _loadUnreadCountFromFile();

    _firebaseMessaging = FirebaseMessaging.instance;

    // Set the flag to true when the chat page is open
    isChatPageOpen = true;
    // // Set the flag to true when the chat page is opened during the current session
    // isChatPageOpenedDuringSession = false;

    // Initialize flutter_local_notifications
    const LocalNotifications.AndroidInitializationSettings
        initializationSettingsAndroid =
        LocalNotifications.AndroidInitializationSettings('android');
    const LocalNotifications.InitializationSettings initializationSettings =
        LocalNotifications.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null, // Set iOS to null to disable iOS notifications
    );
    flutterLocalNotificationsPlugin =
        LocalNotifications.FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Get FCM token
    _getFirebaseCloudMessagingToken();

    _scrollController.addListener(_scrollListener);

    _isNumberVisible = widget.prefs.getBool(widget.phoneNumber) ?? true;

    isWidgetMounted = true;

    messagesStream = FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .doc(widget.phoneNumber)
        .collection("messages")
        .orderBy("timestamp")
        .snapshots();

    print("Fetching messages for Phone Number: $phoneNumberId");

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });

    initRecord();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _initializeSharedPreferencesForCatalogs() async {
    _prefs = await SharedPreferences.getInstance();
    storedCatalogIds = _prefs.getStringList('storedCatalogIds')?.toSet() ?? {};
  }

  // Add this method to extract suggestions based on the message text
  List<String> _getMessageSuggestions(Message message) {
    List<String> suggestions = [];

    if (message.value != null &&
        message.value['body'] != null &&
        message.from == widget.phoneNumber) {
      String messageText = message.value['body'].toLowerCase();
      //For how are you messages regExp
      RegExp howAreYouRegExp = RegExp(
          r'^(?:h+e+y+\s*|h+e+l+o+\s*)?(h+o+w+\s*(a+r+e+|r+)\s*(y+o+u+|u+h+)?|h+r+u+|r+|u+)\b',
          caseSensitive: false);

      //For right now messages regExp
      RegExp rightNowRegExp = RegExp(
          r'^(?:r\s*(?:y\s*t\s*|i\s*g\s*h\s*t\s*)?(?:n\s*o\s*w\s*)?)\??$|^(?:r\s*n\??)$',
          caseSensitive: false);

      //For done/done? messages regExp
      RegExp doneRegExp = RegExp(
        r'^\b(?:d+o+n+e+\s*|d+o+n+e+\?+\s*)\b',
        caseSensitive: false,
      );

      //For relax message regExp
      RegExp relaxRegExp = RegExp(
        r'^(?:r+\s*|r+e+\s*|r+e+l+\s*|r+e+l+a+\s*|r+e+l+a+x+\s*)$',
        caseSensitive: false,
      );

      //suggestions for how are you messages
      if (howAreYouRegExp.hasMatch(messageText)) {
        suggestions.addAll(['Good!', 'I\'m good', 'Good, and you?']);
      } //suggestions for right now messages
      else if (rightNowRegExp.hasMatch(messageText)) {
        suggestions.addAll(['Yes', 'No']);
      } //suggestions for done/done? messages
      else if (doneRegExp.hasMatch(messageText)) {
        suggestions.addAll(['Yes', 'No', 'Ok']);
      } //suggestions for relax message
      else if (relaxRegExp.hasMatch(messageText)) {
        suggestions.addAll(['Okay']);
      }
    }

    // Filter out all suggestions if any one of them has been used
    String key = '${message.id}_suggestions_used';
    bool areSuggestionsUsed = prefs.getBool(key) ?? false;

    if (areSuggestionsUsed ||
        message.from == phoneNumberId ||
        messages.indexOf(message) != 0) {
      suggestions.clear();
    }

    return suggestions;
  }

  void _loadUnreadCountFromFile() async {
    int unreadCount = await FileHelper.readUnreadCount();
    // Use unreadCount as needed (e.g., update a badge)
  }

  void _updateUnreadCount(int newUnreadCount) async {
    // Update unread count in file
    await FileHelper.writeUnreadCount(newUnreadCount);
  }

  bool _isFirstMessageInGroup(int index) {
    if (index == messages.length - 1) {
      return true;
    }

    DateTime currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
      messages[index].timestamp.millisecondsSinceEpoch,
    ).toLocal().toLocal();
    DateTime previousMessageDate = DateTime.fromMillisecondsSinceEpoch(
      messages[index + 1].timestamp.millisecondsSinceEpoch,
    ).toLocal().toLocal();

    // Check if the current message is from a different date
    if (!_isSameDay(currentMessageDate, previousMessageDate)) {
      return true;
    }

    // Check if the previous message is from a different date than the one before it
    if (index >= 2) {
      DateTime previousMessageBeforeDate = DateTime.fromMillisecondsSinceEpoch(
        messages[index - 2].timestamp.millisecondsSinceEpoch,
      ).toLocal().toLocal();

      return !_isSameDay(previousMessageDate, previousMessageBeforeDate);
    }

    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _shouldDisplayDateTag(Message message) {
    DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(
        message.timestamp.millisecondsSinceEpoch);
    String groupKey =
        '${messageTime.day}-${messageTime.month}-${messageTime.year}';

    if (!_lastDisplayedDates.containsKey(groupKey) ||
        !_isSameDayAndTime(_lastDisplayedDates[groupKey]!, messageTime)) {
      _lastDisplayedDates[groupKey] = messageTime;
      return true;
    }

    return false;
  }

  bool _isSameDayAndTime(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day &&
        date1.hour == date2.hour &&
        date1.minute == date2.minute &&
        date1.second == date2.second;
  }

  String getFormattedDateTag(DateTime date) {
    DateTime now = DateTime.now();

    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      // Today
      return 'Today';
    } else if (now.year == date.year &&
        now.month == date.month &&
        now.day - date.day == 1) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other dates
      return DateFormat.yMMMd().format(date);
    }
  }

  Future<void> _getFirebaseCloudMessagingToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");

    // Subscribe to FCM topics
    _firebaseMessaging.subscribeToTopic('chat_messages');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Handling a foreground message: ${message.messageId}");
      await _handleNotification(
        message.notification?.title,
        message.notification?.body,
      );
      // Update your UI or handle the incoming message as needed
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("Handling a foreground message (opened app): ${message.messageId}");
      // Handle when the app is opened from a terminated state
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    await _handleNotification(
      message.notification?.title,
      message.notification?.body,
    );
  }

  void _onMessage(RemoteMessage message) {
    print("Handling a foreground message: ${message.messageId}");
    try {
      NotificationUtil.showNotification(
        message.notification?.title,
        message.notification?.body,
      );
      print("Notification handled successfully in foreground!");
    } catch (e) {
      print("Error showing notification in foreground: $e");
    }

    // Update your UI or handle the incoming message as needed
  }

  Future<void> _handleNotification(String? title, dynamic body) async {
    String notificationBody;

    if (body is String) {
      notificationBody = body;
    } else if (body is Map<String, dynamic>) {
      // Extract the "body" field from the map
      dynamic bodyField = body['body'];

      // Check if the "body" field is a String
      if (bodyField is String) {
        notificationBody = bodyField;
      } else {
        // Handle other types accordingly or provide a default value
        notificationBody = 'Default Value';
      }
    } else {
      // Handle other types accordingly or provide a default value
      notificationBody = 'No Notifications';
    }
    const LocalNotifications.AndroidNotificationDetails
        androidPlatformChannelSpecifics =
        LocalNotifications.AndroidNotificationDetails(
      '"chat_messages"', // replace with your channel ID
      '"Chat Messages"', // replace with your channel name
      importance: LocalNotifications.Importance.max,
      priority: LocalNotifications.Priority.high,
      showWhen: false,
    );
    const LocalNotifications.NotificationDetails platformChannelSpecifics =
        LocalNotifications.NotificationDetails(
            android: androidPlatformChannelSpecifics, iOS: null);

    await flutterLocalNotificationsPlugin.show(
      0, // notification ID
      title ?? '', // title
      notificationBody, // body
      platformChannelSpecifics,
      payload: 'chat_message', // optional payload
    );
  }

  Widget _buildReplyInfo() {
    String replyContent = swipedMessage != null
        ? swipedMessage!.type == 'text'
            ? swipedMessage!.value['body']
            : (swipedMessage!.type == 'document'
                ? swipedMessage!.value['filename']
                : swipedMessage!.type)
        : _isNumberVisible ?? true
            ? "+${widget.phoneNumber}"
            : '************';
    if (replyContent.length > 35) {
      // Trim the content and add an ellipsis
      replyContent = '${replyContent.substring(0, 36)}...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[300], // Adjust the color as needed
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Replying to $replyContent',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.5,
              ),
            ),
          ),
          if (swipedMessage != null)
            IconButton(
              onPressed: () {
                setState(() {
                  swipedMessage = null;
                });
              },
              icon: Icon(Icons.cancel, color: Colors.redAccent[100]),
            ),
          // if (swipedMessage != null && swipedMessage!.type == 'image')
          //   // Display CachedNetworkImage if the swiped message is an image
          //   Container(
          //     width: 40, // Adjust the size as needed
          //     height: 40,
          //     child: FutureBuilder(
          //       future: widget.whatsApp
          //           .getMediaUrl(mediaId: swipedMessage!.value['id']),
          //       builder: (context, AsyncSnapshot<dynamic> snapshot) {
          //         if (snapshot.connectionState == ConnectionState.done) {
          //           if (snapshot.hasError) {
          //             // Display an error message if fetching the image URL fails
          //             return const Text('Error loading image');
          //           }

          //           String imageUrl = snapshot.data?['url']?.toString() ??
          //               'default_image_url';
          //           return CachedNetworkImage(
          //             imageUrl: imageUrl,
          //             fit: BoxFit.cover,
          //           );
          //         } else {
          //           return const CircularProgressIndicator();
          //         }
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {}
  }

  void _deleteMessage(String documentId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print("Deleting message with ID: $documentId");
                try {
                  // Delete the document with the specified ID from Firestore
                  await FirebaseFirestore.instance
                      .collection("accounts")
                      .doc(enteredWABAID)
                      .collection("discussion")
                      .doc(widget.phoneNumber)
                      .collection("messages")
                      .doc(documentId)
                      .delete();

                  print("Message deleted successfully!");

                  // Update local messages list
                  setState(() {
                    messages.removeWhere((message) => message.id == documentId);
                  });

                  print("Message deleted successfully!");
                  print("Remaining messages:");
                  messages.forEach((message) => print(message.id));
                } catch (e) {
                  print("Error deleting message: $e");
                }

                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Add this function to handle clearing the chat
  void _clearChat() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat'),
          content: Text(
              "Are you sure you want to clear the chat for ${widget.phoneNumber}"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print("Clearing chat for phone number: ${widget.phoneNumber}");
                try {
                  // Delete all documents in the messages collection for the given phone number
                  await FirebaseFirestore.instance
                      .collection("accounts")
                      .doc(enteredWABAID)
                      .collection("discussion")
                      .doc(widget.phoneNumber)
                      .collection("messages")
                      .get()
                      .then((snapshot) {
                    for (QueryDocumentSnapshot doc in snapshot.docs) {
                      doc.reference.delete();
                    }
                  });
                  // Update local messages list
                  setState(() {
                    messages.clear();
                  });
                } catch (e) {
                  print("Error clearing chat: $e");
                }
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  Future initRecord() async {
    final granted = await checkPermission();
    if (!granted) {
      throw 'Microphone permission not granted';
    }

    await audioRecorder.openRecorder();
    isAudioRecordedReady = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    audioRecorder.closeRecorder();
    isWidgetMounted = false;
    // Set the flag to false when the chat page is disposed (closed)
    isChatPageOpen = false;
    super.dispose();
  }

  void sendMessage(String message, String recipientPhoneNumber) {
    setMessage('source', message);
    // Set the flag to true when a new message is added
    shouldScrollToBottom = true;
  }

  void sendAutoReply() {
    // Retrieve the greeting message from the saved preferences
    String? greetingMessage = widget.prefs.getString('greeting_message');

    // Send the auto-reply message
    //sendMessage(greetingMessage!, widget.phoneNumber);
  }

  void setMessage(String type, String message) async {
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var response = await widget.whatsApp.messagesText(
      message: message,
      to: int.parse(widget.phoneNumber),
    );

    print('+++ RESPONSE NORMAL $response');
    if (response != null && response.containsKey('messages')) {
      var messagesList = response['messages'];

      if (messagesList != null && messagesList.isNotEmpty) {
        var messageId = messagesList[0]['id'];

        await FirebaseFirestore.instance
            .collection("accounts")
            .doc(enteredWABAID)
            .collection("discussion")
            .doc(widget.phoneNumber)
            .collection("messages")
            .add({
          "from": phoneNumberId,
          "id": messageId,
          "text": {"body": message},
          "type": "text",
          "timestamp": DateTime.now(),
          "fcmToken": fcmToken, // Include FCM token in the message data
        });
        // Update unread count
        int currentUnreadCount = await FileHelper.readUnreadCount();
        int newUnreadCount = currentUnreadCount + 1;
        _updateUnreadCount(newUnreadCount);

        // Set the flag to true when a new message is added
        shouldScrollToBottom = true;

        // Set the auto-reply flag to true
        autoReplySent = true;
      } else {
        // Handle the case where 'messages' is empty or null
        print('Error: messages list is empty or null');
      }
    } else {
      // Handle the case where 'response' is null or doesn't contain 'messages'
      print('Error: response is null or does not contain key "messages"');
    }
  }

  void sendTextReply(String message) async {
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var response = await widget.whatsApp.messagesReply(
        to: int.parse(widget.phoneNumber),
        messageId: swipedMessage!.id,
        message: message);

    print('+++ RESPONSE NORMAL $response'); // Print the entire response
    var messageId = response['messages'][0]['id'];
    print("messageId :- $messageId");
    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .doc(widget.phoneNumber)
        .collection("messages")
        .add({
      "from": phoneNumberId,
      "id": messageId,
      "text": {"body": message},
      "type": "text",
      "timestamp": DateTime.now(),
      "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id},
      "fcmToken": fcmToken, // Include FCM token in the reply message data
    });
    setState(() {
      swipedMessage = null;
    });
  }

  void sendLocationMessage(latitude, longitude) async {
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    var response;

    if (swipedMessage == null) {
      response = await widget.whatsApp.messagesLocation(
          to: int.parse(widget.phoneNumber),
          longitude: longitude,
          latitude: latitude,
          name: '',
          address: '');
    } else {
      response = await widget.whatsApp.messagesLocationReply(
          to: int.parse(widget.phoneNumber),
          longitude: longitude,
          latitude: latitude,
          name: '',
          address: '',
          messageId: swipedMessage!.id);
    }
    if (swipedMessage == null) {
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(enteredWABAID)
          .collection("discussion")
          .doc(widget.phoneNumber)
          .collection("messages")
          .add({
        "from": phoneNumberId, //phoneNumber,
        "id": response['messages'][0]['id'],
        "location": {"longitude": longitude, 'latitude': latitude},
        "type": "location",
        "timestamp": DateTime.now(),
        "fcmToken": fcmToken
      });
      setState(() {
        swipedMessage = null;
      });
    } else {
      await FirebaseFirestore.instance
          .collection("accounts")
          .doc(enteredWABAID)
          .collection("discussion")
          .doc(widget.phoneNumber)
          .collection("messages")
          .add({
        "from": phoneNumberId, //phoneNumber,
        "id": response['messages'][0]['id'],
        "context": {'from': widget.phoneNumber, 'id': swipedMessage!.id},
        "location": {"longitude": longitude, 'latitude': latitude},
        "type": "location",
        "timestamp": DateTime.now(),
        "fcmToken": fcmToken
      });
      setState(() {
        swipedMessage = null;
      });
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future checkLocationPermission() async {
    var currentStatus = await Permission.location.status;
    if (currentStatus.isGranted) {
      print('LOCATION GRANTED');
      Location location = Location();
      await location.getCurrentLocation();
      sendLocationMessage(location.latitude, location.longitude);
      // showPlacePicker();
    } else if (currentStatus.isDenied) {
      print('LOCATION DENIED');
      Map<Permission, PermissionStatus> status = await [
        Permission.location,
      ].request();
      if (await Permission.location.isPermanentlyDenied) {
        openAppSettings();
      }
      print('LOCATION $status');
    }
  }

  void showPlacePicker() async {
    try {
      LocationResult? result = await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  PlacePicker("AIzaSyDbNh4C7T3AQLBr9GGJgS0MvJ6DNw52KMg")));
      print('THIS IS THE RESULT $result');
    } catch (error) {
      print('THIS IS THE RESULT ERROR $error');
    }
  }

  Future record() async {
    if (!isAudioRecordedReady) return;
    setState(() {
      isRecording = true;
    });
    await audioRecorder.startRecorder(toFile: 'audio.aac');
  }

  Future stopRecording() async {
    if (!isAudioRecordedReady) return;

    setState(() {
      isRecording = false;
    });
    final path = await audioRecorder.stopRecorder();
    final audioFile = File(path!);

    print('Recorded audio: $audioFile');

    var id = (await widget.whatsApp.uploadMedia(
        mediaType: MediaType.parse("audio/aac"),
        mediaFile: audioFile,
        mediaName: audioFile.path.split('/').last))['id'];

    var link = await widget.whatsApp.getMediaUrl(mediaId: id);
    print(link);

    var mesgRes;
    if (swipedMessage == null) {
      mesgRes = await widget.whatsApp.messagesMedia(
          mediaId: id, mediaType: "audio", to: widget.phoneNumber);
    } else {
      mesgRes = await widget.whatsApp.messagesReplyMedia(
          mediaId: id,
          mediaType: "audio",
          messageId: swipedMessage!.id,
          to: widget.phoneNumber);
    }

    var messageObject;
    // Retrieve the FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (swipedMessage == null) {
      messageObject = {
        "audio": {"mime_type": "audio/aac", "sha256": link['sha256'], "id": id},
        "type": "audio",
        "from": phoneNumberId, //phoneNumber,
        "id": mesgRes['messages'][0]['id'],
        "timestamp": DateTime.now(),
        "fcmToken": fcmToken
      };
    } else {
      messageObject = {
        "audio": {"mime_type": "audio/aac", "sha256": link['sha256'], "id": id},
        "type": "audio",
        "from": phoneNumberId, //phoneNumber,
        "id": mesgRes['messages'][0]['id'],
        "timestamp": DateTime.now(),
        "context": {'from': swipedMessage!.from, 'id': swipedMessage!.id},
        "fcmToken": fcmToken
      };
    }

    await FirebaseFirestore.instance
        .collection("accounts")
        .doc(enteredWABAID)
        .collection("discussion")
        .doc(widget.phoneNumber)
        .collection("messages")
        .add(messageObject);
    setState(() {
      swipedMessage = null;
    });
  }

  Future<void> _sendTemplateImageMessage() async {
    try {
      // Retrieve the template message data from Firestore
      QuerySnapshot<Map<String, dynamic>> snapshot = await _reference
          .orderBy('timestamp', descending: true)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      // Assume you want to get the latest template message
      if (snapshot.docs.isNotEmpty) {
        var latestTemplate = snapshot.docs.first.data();

        // Print the data to debug
        print('Latest Template Data: $latestTemplate');

        // Construct the template message using the retrieved data
        String imageUrl = latestTemplate['image'];
        // Encode the Firebase Storage URL
        String encodedImageUrl = Uri.encodeFull(imageUrl);
        print('Encoded file path : $encodedImageUrl');
        // String templateBody = latestTemplate['templateBody'];
        // String templateFooter = latestTemplate['templateFooter'];

        await widget.whatsApp.messagesTemplate(
          templateName: "media_test",
          to: int.parse(widget.phoneNumber),
          mediaUrl:
              "https://photos.google.com/photo/AF1QipOmAGba4ZBdfQ2hjeSWcodfTew3Gv5oQ6G7pCmx",
          text: "",
        );

        // Send the image template message
        //sendMessageWithImage(imageUrl, templateBody, templateFooter);
      } else {
        // If no template message is available, use a default template
        String defaultTemplateMessage = "This is a default template message.";

        // Print the default template message to debug
        print('Default Template Message: $defaultTemplateMessage');

        // Send the default template message
        sendMessage(defaultTemplateMessage, widget.phoneNumber);
      }
    } catch (e, stackTrace) {
      print('Error retrieving template message: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> sendMessageWithImage(
      String imageUrl, String templateBody, String templateFooter) async {
    try {
      // Download the image to a temporary file
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;
        // Get the temporary directory path
        Directory tempDir = await getTemporaryDirectory();
        String tempFilePath = '${tempDir.path}/temp_image.jpeg';
        File tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(imageBytes);

        // Upload the image using the retrieved URL
        var id = (await widget.whatsApp.uploadMedia(
          mediaType:
              MediaType.parse("image/jpeg"), // Adjust the media type if needed
          //mediaUrl: imageUrl,
          mediaFile: tempFile,
          mediaName: 'template_image',
        ))['id'];

        // Send the image message using WhatsApp API
        var mesgRes;
        if (swipedMessage == null) {
          mesgRes = await widget.whatsApp.messagesMedia(
            mediaId: id,
            mediaType: "image",
            to: widget.phoneNumber,
          );
        } else {
          mesgRes = await widget.whatsApp.messagesReplyMedia(
            mediaId: id,
            messageId: swipedMessage!.id,
            mediaType: "image",
            to: widget.phoneNumber,
          );
        }

        var link = await widget.whatsApp.getMediaUrl(mediaId: id);

        // Create the message object and save it to Firestore
        var messageObject = {
          "image": {
            "mime_type": "image/jpeg", // Adjust the mime type if needed
            "sha256": link['sha256'],
            "id": id,
            "url": imageUrl,
            "templateBody": templateBody,
            "templateFooter": templateFooter,
          },
          "type": "image",
          "from": phoneNumberId,
          "id": mesgRes['messages'][0]['id'],
          "timestamp": DateTime.now(),
          "fcmToken": await FirebaseMessaging.instance.getToken(),
        };

        //messages.add(Message.fromJson(messageObject as String));

        // ignore: unused_local_variable
        var res = await FirebaseFirestore.instance
            .collection("accounts")
            .doc(enteredWABAID)
            .collection("discussion")
            .doc(widget.phoneNumber)
            .collection("messages")
            .add(messageObject);

        print('Image uploaded and message saved to Firestore');
      } else {
        print('Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<TemplateMessage>> fetchTemplateMessages(
      String accessToken) async {
    var url =
        'https://graph.facebook.com/v17.0/$enteredWABAID/message_templates?access_token=$accessToken';
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 400) {
      print('Bad Request 1: ${response.body}');
      // Handle the error or return an empty list
      return [];
    } else if (response.statusCode == 200) {
      print('Bad Request 2: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming 'data' contains a 'messages' field with an array of messages
      if (responseData.containsKey('data')) {
        print('Bad Request 3: ${response.body}');
        final List<dynamic> templateData = responseData['data'];
        // Mapping the templates to TemplateMessage objects
        final List<TemplateMessage> templateMessages =
            templateData.map((template) {
          // Assuming you have an 'id' and 'text' field in your TemplateMessage class
          return TemplateMessage.fromJson(template);
        }).toList();

        return templateMessages;
      } else {
        print('Bad Request: No "data" field in the response');
        return [];
      }
    } else {
      print('Bad Request 5: ${response.body}');
      print('Status Code : ${response.statusCode}');
      throw Exception(
          'Failed to load template messages. Status code: ${response.statusCode}');
    }
  }

  Future<void> _showTemplateDialog(
      List<TemplateMessage> templateMessages) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Message Templates',
            style: GoogleFonts.baloo2(
              textStyle: const TextStyle(
                color: Colors.green,
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: templateMessages.length,
              itemBuilder: (BuildContext context, int index) {
                final template = templateMessages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle tap event for the template
                        _openInputDialog(template);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${template.name}\nID: ${template.id}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(height: 10.0),
                              if (template.imageUrl != null)
                                Container(
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                      image: NetworkImage(template.imageUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: template.imageUrl != null &&
                                              template.imageUrl!
                                                  .contains(".mp4") ||
                                          template.imageUrl!.contains(".pdf")
                                      ? Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: Center(
                                            child: Text(
                                              template.imageUrl!
                                                      .contains(".mp4")
                                                  ? 'Video Preview'
                                                  : 'Document Preview',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              const SizedBox(height: 10.0),
                              Text(
                                'Text: ${template.text}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),
                              ),
                              const SizedBox(height: 10.0),
                              if (template.example != null &&
                                  template.example!.bodyText != null)
                                for (List<String> bodyText
                                    in template.example!.bodyText!)
                                  Text(
                                    'Body Text: ${bodyText.join(', ')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                              const SizedBox(height: 10.0),
                              if (template.example != null &&
                                  template.example!.footerText != null)
                                Text(
                                  'Footer Text: ${template.footerText}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.language.isNotEmpty)
                                Text(
                                  'Language: ${template.language}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.status.isNotEmpty)
                                Text(
                                  'Status: ${template.status}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                              const SizedBox(height: 10.0),
                              if (template.category.isNotEmpty)
                                Text(
                                  'Category: ${template.category}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDataAndShowDialog() async {
    try {
      List<TemplateMessage> templateMessages = await fetchTemplateMessages(
          'EAAMEyX45PoMBO18lFTrAnLeKbiDi2qJAL7Nec61OLZAayaIqcWYAczQn3jGlWuWGwWZBFOjFk1ZBTBNqhjZCZAvLpww7XlgJps4SCsKUlgDmgNZBx6hl82AQdzJCZAZB12nxyIuvKAKUNBrcNFgfbSfN6lMXxqxZBdF5carAwaQSZA2KJWZAzjAXoLBjbLJq9BkIWGa');
      _showTemplateDialog(templateMessages);
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> _openInputDialog(TemplateMessage template) async {
    // Check if header format is LOCATION
    if (template.components.any((component) =>
        component.type == 'HEADER' && component.format == 'LOCATION')) {
      List<TextEditingController> controllersList = [];
      // Show a dialog to enter location details
      TextEditingController latitudeController = TextEditingController();
      TextEditingController longitudeController = TextEditingController();
      TextEditingController nameController = TextEditingController();
      TextEditingController addressController = TextEditingController();

      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Location Details'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // Add input fields for location details
                  TextField(
                    controller: latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                  TextField(
                    controller: longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Location Name'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration:
                        const InputDecoration(labelText: 'Location Address'),
                  ),
                  // Add input fields for bodyText if present
                  ...template.example?.bodyText
                          ?.expand((List<String> bodyText) {
                        return bodyText.map((String variable) {
                          TextEditingController controller =
                              TextEditingController();
                          // Store the controller for later use
                          controllersList.add(controller);
                          return TextField(
                            controller: controller,
                            decoration:
                                InputDecoration(labelText: 'Enter $variable'),
                          );
                        });
                      }).toList() ??
                      [],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Check if any of the fields are empty
                  if (latitudeController.text.isEmpty ||
                      longitudeController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      controllersList
                          .any((controller) => controller.text.isEmpty)) {
                    // Show a toast warning if any field is empty
                    Fluttertoast.showToast(
                      msg: 'All fields are required.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else {
                    Navigator.of(context).pop(true); // User confirmed
                  }
                },
                child: const Text('Send'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // User canceled
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      // If user canceled the confirmation, return
      if (confirm == false) {
        return;
      }

      // Extract entered values
      double latitude, longitude;
      String locationName, locationAddress;

      if (latitudeController.text.isNotEmpty &&
          longitudeController.text.isNotEmpty) {
        latitude = double.parse(latitudeController.text);
        longitude = double.parse(longitudeController.text);
      } else {
        // Handle invalid or empty latitude/longitude
        // Show an error message or return, depending on your requirements
        return;
      }

      locationName = nameController.text;
      locationAddress = addressController.text;

      // If bodyText is present, handle entered parameters
      if (template.example?.bodyText != null) {
        // Handle the entered parameters
        Map<String, String> enteredVariables = {};
        template.example!.bodyText!.forEach((List<String> bodyText) {
          bodyText.asMap().forEach((index, variable) {
            TextEditingController controller = controllersList[index];
            String enteredText = controller.text;
            enteredVariables[variable] = enteredText;
          });
        });

        // Call the API function with the entered values and variables
        widget.whatsApp.messagesTemplate(
          templateName: template.name,
          to: int.parse(widget.phoneNumber),
          mediaUrl:
              null, // Change to the actual mediaUrl or set it to null if not applicable
          text: "",
          location: {
            'latitude': latitude,
            'longitude': longitude,
            'name': locationName,
            'address': locationAddress,
          },
          variables: enteredVariables,
          language: template.language,
          templateHeaderFormat: template.components.firstWhereOrNull(
            (component) => component.type == 'HEADER',
          ),
        );
      } else {
        // Call the API function without bodyText
        widget.whatsApp.messagesTemplate(
          templateName: template.name,
          to: int.parse(widget.phoneNumber),
          mediaUrl:
              null, // Change to the actual mediaUrl or set it to null if not applicable
          text: "",
          location: {
            'latitude': latitude,
            'longitude': longitude,
            'name': locationName,
            'address': locationAddress,
          },
          variables: {},
          language: template.language,
          templateHeaderFormat: template.components.firstWhereOrNull(
            (component) => component.type == 'HEADER',
          ),
        );
      }
    } else
    // Check if bodyText is not null or empty
    if (template.example?.bodyText == null ||
        template.example!.bodyText!.isEmpty) {
      // Check if header format is IMAGE or VIDEO
      if (template.components.any((component) =>
          component.type == 'HEADER' &&
          (component.format == 'IMAGE' ||
              component.format == 'VIDEO' ||
              component.format == 'DOCUMENT' ||
              component.format == 'LOCATION'))) {
        // Show a dialog to enter the image URL
        TextEditingController imageUrlController = TextEditingController();
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter Image/Video URL'),
              content: TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image/Video URL'),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Check if the image URL is empty
                    if (imageUrlController.text.isEmpty) {
                      // Show a toast warning if the image URL is empty
                      Fluttertoast.showToast(
                        msg: 'Image/Video URL is required.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    } else {
                      Navigator.of(context).pop(true); // User confirmed
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        // Send the template with the entered image/video URL
        widget.whatsApp.messagesTemplate(
          templateName: template.name,
          to: int.parse(widget.phoneNumber),
          mediaUrl: imageUrlController.text,
          text: "",
          variables: {}, // No variables for templates without bodyText
          language: template.language,
          templateHeaderFormat: template.components.firstWhereOrNull(
            (component) =>
                component.type == 'HEADER' &&
                (component.format == 'IMAGE' || component.format == 'VIDEO'),
          ),
        );
      } else if (template.components.any((component) =>
          component.type == 'HEADER' && component.format == 'TEXT')) {
        // Show a confirmation dialog
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'Are you sure to send this message template?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        // Send the template without an image URL
        widget.whatsApp.messagesTemplate(
          templateName: template.name,
          to: int.parse(widget.phoneNumber),
          mediaUrl: null,
          text: "",
          variables: {}, // No variables for templates without bodyText
          language: template.language,
          templateHeaderFormat: template.components.firstWhereOrNull(
            (component) => component.type == 'HEADER',
          ),
        );
      } else {
        // The template doesn't have a 'HEADER' component
        // Show a confirmation dialog
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                'Do you want to send this template?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        // If user canceled the confirmation, return
        if (confirm == false) {
          return;
        }

        // Send the template without a 'HEADER' component
        widget.whatsApp.messagesTemplate(
          templateName: template.name,
          to: int.parse(widget.phoneNumber),
          mediaUrl: null,
          text: "",
          variables: {}, // No variables for templates without bodyText
          language: template.language,
          templateHeaderFormat:
              null, // Set to null for templates without 'HEADER'
        );
      }
    } else {
      List<TextEditingController> controllersList = [];

      // Create controllers for variables and imageUrl
      TextEditingController imageUrlController = TextEditingController();
      controllersList.add(imageUrlController);

      // Create a map to store the entered variables
      Map<String, String> enteredVariables = {};

      String? enteredImageUrl;

      List<Widget> inputFields = [];

// Add an input field for imageUrl only if header format is not 'TEXT'
      if (template.components.any((component) =>
          component.type == 'HEADER' &&
          (component.format == 'IMAGE' ||
              component.format == 'VIDEO' ||
              component.format == 'DOCUMENT' ||
              component.format == 'LOCATION'))) {
        inputFields.add(
          TextField(
            controller: imageUrlController,
            onChanged: (value) {
              setState(() {
                // Update the enteredImageUrl when the text changes
                enteredImageUrl = value.isNotEmpty ? value : null;
              });
            },
            decoration: const InputDecoration(labelText: 'Enter Media URL'),
          ),
        );
      }

// Show input fields for bodyText variables
      inputFields.addAll(
        template.example?.bodyText?.expand((List<String> bodyText) {
              return bodyText.map((String variable) {
                // Create a TextEditingController for each variable
                TextEditingController controller = TextEditingController();
                controllersList.add(controller);

                return TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Enter $variable'),
                );
              });
            }).toList() ??
            [],
      );

      // ignore: use_build_context_synchronously
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Parameters for ${template.name} Template'),
            content:
                // StatefulBuilder(
                //   builder: (context, setState) {
                //     return
                SingleChildScrollView(
              child: Column(
                children: inputFields,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Check if the template has body text parameters
                  bool hasBodyTextParameters =
                      template.example?.bodyText?.isNotEmpty ?? false;

// Check if any of the bodyText controllers are empty
                  bool anyFieldEmpty = hasBodyTextParameters
                      ? controllersList
                          .sublist(1)
                          .any((controller) => controller.text.isEmpty)
                      : false;

                  // Check if the imageUrl controller is empty
                  bool imageUrlEmpty = template.components.any((component) =>
                          component.type == 'HEADER' &&
                          (component.format == 'IMAGE' ||
                              component.format == 'VIDEO' ||
                              component.format == 'DOCUMENT' ||
                              component.format == 'LOCATION'))
                      ? imageUrlController.text.isEmpty
                      : false;

                  // Check the values and conditions
                  print('anyFieldEmpty: $anyFieldEmpty');
                  print(
                      'imageUrlController.text: "${imageUrlController.text}"');
                  print(
                      'bodyText controllers: ${controllersList.sublist(1).map((c) => c.text).toList()}');

                  if (imageUrlEmpty && !hasBodyTextParameters) {
                    // Do not show a toast warning if there are no parameters to fill
                  } else if (imageUrlEmpty && hasBodyTextParameters) {
                    // Show a toast warning if there are bodyText parameters and imageUrl is empty
                    Fluttertoast.showToast(
                      msg: 'Please fill in the Media URL field.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else if (anyFieldEmpty) {
                    // Show a toast warning if any bodyText field is empty
                    Fluttertoast.showToast(
                      msg: 'Please fill in all the fields.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    // Handle the entered parameters
                    List<List<String>> enteredParameters = [];
                    template.example?.bodyText
                        ?.forEach((List<String> bodyText) {
                      List<String> enteredTexts = [];
                      bodyText.forEach((variable) {
                        // Get the value from the corresponding TextEditingController
                        TextEditingController controller =
                            controllersList.removeAt(1);
                        String enteredText = controller.text;
                        enteredTexts.add(enteredText);

                        // Store the entered variable and its value
                        enteredVariables[variable] = enteredText;
                      });
                      enteredParameters.add(enteredTexts);
                    });

                    // Get the imageUrl from its controller
                    String imageUrl = imageUrlController.text;

                    // Print or use the entered parameters
                    print('Entered Parameters: $enteredParameters');
                    print('Entered Image URL: $imageUrl');

                    // Pass the entered variables to messagesTemplate
                    widget.whatsApp.messagesTemplate(
                        templateName: template.name,
                        to: int.parse(widget.phoneNumber),
                        mediaUrl: imageUrl,
                        text: "",
                        variables: enteredVariables,
                        language: template.language,
                        templateHeaderFormat: template.components
                            .firstWhereOrNull(
                                (component) => component.type == 'HEADER'));

                    // // Send message with image using the entered image URL
                    // await sendMessageWithImage(
                    //   imageUrl,
                    //   template.text,
                    //   template.footerText ?? "",
                    // );

                    // Close the dialog
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          );
        },
      );
    }
  }
  // // Display the image preview
  // if (enteredImageUrl.isNotEmpty)
  //   Image.network(
  //     enteredImageUrl,
  //     width: 100.0,
  //     height: 100.0,
  //     fit: BoxFit.cover,
  //   ),
  // Add an input field for imageUrl

  Future<List<CatalogItem>> fetchCatalogItems(
      String accessToken, String catalogId) async {
    var url =
        'https://graph.facebook.com/v19.0/$catalogId/products?access_token=$accessToken';
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 400) {
      print('Catalog Bad Request 1: ${response.body}');
      // Handle the error or return an empty list
      return [];
    } else if (response.statusCode == 200) {
      print('Catalog Good Request 2: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data')) {
        print('Catalog Good Request 3: ${response.body}');
        final List<dynamic> catalogItemData = responseData['data'];
        final List<CatalogItem> catalogItems = catalogItemData.map((item) {
          return CatalogItem.fromJson(item);
        }).toList();

        return catalogItems;
      } else {
        print('No "data" field in the response');
        return [];
      }
    } else {
      print('Bad Request 5: ${response.body}');
      print(
          'Failed to load catalog items. Status code: ${response.statusCode}');
      throw Exception(
          'Failed to load catalog items. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchDataAndShowCatalogDialog() async {
    try {
      // Set initial value for the dropdown
      String initialCatalogId = 'Select Catalog ID';
      catalogIdController.text = initialCatalogId;
      // ignore: use_build_context_synchronously
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Enter Catalog ID',
              style: GoogleFonts.baloo2(
                textStyle: const TextStyle(
                  color: Colors.green,
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: catalogIdController.text,
                        items: [
                          DropdownMenuItem<String>(
                            value: initialCatalogId,
                            child: Text(initialCatalogId),
                          ),
                          ...storedCatalogIds.map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            catalogIdController.text = newValue ?? '';
                          });
                        },
                      ),
                      TextField(
                        controller: catalogIdController,
                        decoration: const InputDecoration(
                          labelText: 'Catalog ID',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String enteredCatalogId = catalogIdController.text.trim();
                  if (enteredCatalogId.isNotEmpty &&
                      enteredCatalogId != initialCatalogId &&
                      !storedCatalogIds.contains(enteredCatalogId)) {
                    storedCatalogIds.add(enteredCatalogId);
                    _prefs.setStringList(
                        'storedCatalogIds', storedCatalogIds.toList());
                  }

                  List<CatalogItem> catalogItems = await fetchCatalogItems(
                    'EAAMEyX45PoMBO18lFTrAnLeKbiDi2qJAL7Nec61OLZAayaIqcWYAczQn3jGlWuWGwWZBFOjFk1ZBTBNqhjZCZAvLpww7XlgJps4SCsKUlgDmgNZBx6hl82AQdzJCZAZB12nxyIuvKAKUNBrcNFgfbSfN6lMXxqxZBdF5carAwaQSZA2KJWZAzjAXoLBjbLJq9BkIWGa',
                    enteredCatalogId,
                  );
                  Navigator.of(context).pop(); // Close the current dialog
                  _showCatalogDialog(catalogItems);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors
      print('Error: $e');
    }
  }

  Future<void> _showCatalogDialog(List<CatalogItem> catalogItems) async {
    TextEditingController headerTextController = TextEditingController();
    TextEditingController sectionTitleController = TextEditingController();
    TextEditingController bodyTextController = TextEditingController();
    TextEditingController footerTextController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Catalog Items',
            style: GoogleFonts.baloo2(
              textStyle: const TextStyle(
                color: Colors.green,
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
              itemCount: catalogItems.length,
              itemBuilder: (BuildContext context, int index) {
                final catalogItem = catalogItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Handle tap event for the catalog item
                        _openCatalogItemDialog(catalogItem);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${catalogItem.name}\nID: ${catalogItem.id}\nRetailer ID: ${catalogItem.retailerId}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                              const SizedBox(height: 10.0),
                              // Add more details if needed
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Show input fields for header text and section title
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title:
                          const Text('Enter Details For Multi-Product Catalog'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: headerTextController,
                              decoration: const InputDecoration(
                                labelText: 'Header Text',
                              ),
                            ),
                            TextField(
                              controller: bodyTextController,
                              decoration: const InputDecoration(
                                labelText: 'Body Text',
                              ),
                            ),
                            TextField(
                              controller: footerTextController,
                              decoration: const InputDecoration(
                                labelText: 'Footer Text',
                              ),
                            ),
                            TextField(
                              controller: sectionTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Section Title',
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Extracting catalog IDs and retailer IDs
                            List<String> retailerIds = catalogItems
                                .map((item) => item.retailerId)
                                .toList();

                            // Convert the list of retailer IDs to a comma-separated string
                            String formattedRetailerIds =
                                retailerIds.join(', ');

                            // Call the function to send multi-product catalog
                            widget.whatsApp.messagesMultiCatalog(
                              to: int.parse(widget.phoneNumber),
                              catalogId: catalogIdController.text.trim(),
                              productRetailerIds: retailerIds,
                              headerText: headerTextController.text.trim(),
                              bodyText: bodyTextController.text.trim(),
                              footerText: footerTextController.text.trim(),
                              sectionTitle: sectionTitleController.text.trim(),
                            );

                            sendMessage(
                                "Products:\n$formattedRetailerIds\n\nCatalog sent!",
                                widget.phoneNumber);

                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          child: const Text('Send'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'Send Multi-Product Catalog',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCatalogItemDialog(CatalogItem catalogItem) async {
    TextEditingController bodyController = TextEditingController();
    TextEditingController footerController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Catalog Item Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID: ${catalogItem.id}'),
                Text('Name: ${catalogItem.name}'),
                Text('Retailer ID: ${catalogItem.retailerId}'),
                const SizedBox(height: 20),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body Text'),
                ),
                TextField(
                  controller: footerController,
                  decoration: const InputDecoration(labelText: 'Footer Text'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  widget.whatsApp.messagesSingleCatalog(
                    to: int.parse(widget.phoneNumber),
                    catalogId: catalogIdController.text.trim(),
                    productRetailerId: catalogItem.retailerId,
                    bodyText: bodyController.text.trim(),
                    footerText: footerController.text.trim(),
                  );
                  sendMessage(
                      "Product:\n${catalogItem.retailerId}\n\nCatalog sent!",
                      widget.phoneNumber);
                  Navigator.of(context).pop(); // Close the current dialog
                } catch (e) {
                  // Handle errors
                  print('Error: $e');
                }
              },
              child: const Text('Send Catalog'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void _showBottomSheet(BuildContext context) {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AnimatedPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Your content here
                      bottomSheet(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Stack(
      children: [
        const BackgroundImage(),
        Scaffold(
          //Color.fromRGBO(97, 64, 196, 1),
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              elevation: 0,
              backgroundColor: Get.isDarkMode
                  ? Colors.black54
                  : const Color.fromRGBO(97, 64, 196, 1),
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                    ),
                    Hero(
                      tag:
                          'profileIcon', // Use a unique tag for the Hero widget
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueGrey,
                        child: SvgPicture.asset(
                          "assets/person.svg",
                          color: Colors.white,
                          height: 36,
                          width: 36,
                        ),
                      ),
                      flightShuttleBuilder: (
                        BuildContext flightContext,
                        Animation<double> animation,
                        HeroFlightDirection flightDirection,
                        BuildContext fromHeroContext,
                        BuildContext toHeroContext,
                      ) {
                        // You can customize the animation duration here
                        return RotationTransition(
                          turns: animation,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueGrey,
                            child: SvgPicture.asset(
                              "assets/person.svg",
                              color: Colors.white,
                              height: 36,
                              width: 36,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {
                  // Open the contact details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactDetailsScreen(
                        phoneNumber: widget.phoneNumber,
                        userName: _isNumberVisible ?? true
                            ? Provider.of<CustomCardStateNotifier>(context)
                                    .savedContactNames[widget.phoneNumber] ??
                                widget.userName
                            : '************',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isNumberVisible ?? true
                            ? Provider.of<CustomCardStateNotifier>(context)
                                    .savedContactNames[widget.phoneNumber] ??
                                widget.userName
                            : '************',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.5),
                      ),
                    ],
                  ),
                ),
              ),
              // Add actions part here
              actions: [
                PopupMenuButton<String>(
                  offset: const Offset(0, 45),
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white, // Set the color to white
                  ),
                  onSelected: (value) async {
                    if (value == 'clearChat') {
                      _clearChat();
                    } else if (value == 'sendTemplate') {
                      // Fetch and show template messages
                      fetchDataAndShowDialog();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'clearChat',
                        child: Text('Clear Chat'),
                      ),
                      const PopupMenuItem(
                        value: 'sendTemplate',
                        child: Text('Send Template Message'),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: WillPopScope(
                onWillPop: () {
                  if (show) {
                    setState(() {
                      show = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                  return Future.value(false);
                },
                child: Column(children: [
                  Expanded(
                    //height: MediaQuery.of(context).size.height - 140,
                    child: StreamBuilder<dynamic>(
                      stream: messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData && snapshot.data != null) {
                            List<Message> updatedMessages = [];
                            for (int i = 0; i < snapshot.data!.size; i++) {
                              updatedMessages.add(Message.fromMap(
                                snapshot.data!.docs[i].data(),
                                snapshot.data!.docs[i].id,
                              ));
                            }
                            // Sort messages by timestamp in descending order
                            updatedMessages.sort(
                                (a, b) => b.timestamp.compareTo(a.timestamp));

                            // Update messages list only if the widget is still mounted
                            if (isWidgetMounted) {
                              messages = updatedMessages;

                              if (messages.length == 1 && !isAutoReplySent) {
                                // Send auto-reply here
                                sendAutoReply();
                                // Set the flag to true to indicate that auto-reply has been sent
                                isAutoReplySent = true;
                              }

                              Message emptyMessage =
                                  Message.empty(); // Create a default instance

                              // Assuming the latest message is at index 0
                              Message latestMessage = updatedMessages.isNotEmpty
                                  ? updatedMessages[0]
                                  : emptyMessage; // Use the default instance for empty list

                              // Check if it's a new message that hasn't triggered a notification
                              if (isChatPageOpen &&
                                  lastNotifiedMessageId != latestMessage.id &&
                                  latestMessage.from != phoneNumberId) {
                                // Call the method to handle notification
                                _handleNotification(
                                  latestMessage
                                      .from, // Subtitle of the notification
                                  latestMessage
                                      .value, // Body of the notification
                                );

                                // Update the last notified message ID
                                lastNotifiedMessageId = latestMessage.id;
                              }
                            }
                          }
                        }

                        return ListView.builder(
                          key: UniqueKey(), // Add a key to the ListView.builder
                          controller: _scrollController,
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            bool isFirstMessageInGroup =
                                _isFirstMessageInGroup(index);

                            Widget dateTag = isFirstMessageInGroup
                                ? Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      getFormattedDateTag(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]
                                              .timestamp
                                              .millisecondsSinceEpoch,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Container();

                            Widget messageCard;
                            print(
                                'MESSAGE ++++++++++++++++ ${messages[index]}');

                            if (messages[index].from == phoneNumberId) {
                              if (messages[index].context.isNotEmpty) {
                                messageCard = ReplyMessageCardReply(
                                  message: messages[index],
                                  time: DateFormat("h:mm a").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]
                                              .timestamp
                                              .millisecondsSinceEpoch)),
                                  phoneNumber: widget.phoneNumber,
                                  phoneNumberId: phoneNumberId,
                                  myReply: true,
                                );
                              } else {
                                print('+++ 2');
                                // Check if the clicked message has an 'id'
                                String messageId = messages[index].id;
                                messageCard = OwnMessageCard(
                                  message: messages[index],
                                  time: DateFormat("h:mm a").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]
                                              .timestamp
                                              .millisecondsSinceEpoch)),
                                  phoneNumberId: phoneNumberId,
                                );
                              }
                            } else {
                              print('+++ 3');
                              if (messages[index].context.isNotEmpty) {
                                messageCard = ReplyMessageCardReply(
                                  message: messages[index],
                                  time: DateFormat("h:mm a").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]
                                              .timestamp
                                              .millisecondsSinceEpoch)),
                                  phoneNumber: widget.phoneNumber,
                                  phoneNumberId: phoneNumberId,
                                  // templateName: yourTemplateName,
                                  // templateId: yourTemplateId,
                                  myReply: false,
                                );
                              } else {
                                print('+++ 4');
                                messageCard = ReplyCard(
                                  message: messages[index],
                                  time: DateFormat("h:mm a").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          messages[index]
                                              .timestamp
                                              .millisecondsSinceEpoch)),
                                  phoneNumberId: phoneNumberId,
                                );
                              }
                            }

                            // Add the _sendSuggestion method outside the build method
                            void sendSuggestion(String suggestion) {
                              Future.delayed(Duration.zero, () {
                                // Send the suggestion as a new message
                                sendMessage(suggestion, widget.phoneNumber);

                                // Update the flag to indicate that any suggestion has been used
                                String key =
                                    '${messages[index].id}_suggestions_used';
                                prefs.setBool(key, true);

                                // // Delay for a short duration to wait for the asynchronous operation to complete
                                // await Future.delayed(
                                //     const Duration(milliseconds: 100));

                                // Remove the selected suggestion from the UI
                                setState(() {
                                  _getMessageSuggestions(messages[index])
                                      .clear();
                                });
                              });
                            }

                            return Column(
                              children: <Widget>[
                                dateTag,
                                SwipeTo(
                                  onRightSwipe: (DragUpdateDetails details) {
                                    focusNode.requestFocus();
                                    replyToMessage(messages[index]);
                                  },
                                  child: InkWell(
                                    onLongPress: () {
                                      _deleteMessage(
                                          messages[index].documentId);
                                    },
                                    onTap: () {
                                      print("Clicked on message with context!");

                                      // Check if the clicked message has an 'id'
                                      String messageId = messages[index].id;
                                      if (messageId != null &&
                                          messageId.isNotEmpty) {
                                        // Find the index of the context message in the list
                                        int contextMessageIndex =
                                            messages.indexWhere(
                                          (message) =>
                                              message.id != null &&
                                              message.id == messageId &&
                                              message.context != null &&
                                              message.context.containsKey('id'),
                                        );

                                        if (contextMessageIndex != -1) {
                                          String contextMessageId =
                                              messages[contextMessageIndex]
                                                  .context['id'];
                                          print(
                                              "Context found: $contextMessageId");

                                          // Search for the context message ID within the existing list
                                          int scrollToIndex =
                                              messages.indexWhere(
                                            (message) =>
                                                message.id == contextMessageId,
                                          );

                                          if (scrollToIndex != -1) {
                                            // Scroll to the context message using the _scrollController
                                            _scrollController.animateTo(
                                              scrollToIndex * 70,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: ListTile(
                                      title: Column(
                                        children: [
                                          // Original message card
                                          messageCard,

                                          // Suggestions (if any)
                                          if (_getMessageSuggestions(
                                                  messages[index])
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8.0, 0.0, 0.0, 5.0),
                                              child: Row(
                                                children:
                                                    _getMessageSuggestions(
                                                            messages[index])
                                                        .map((suggestion) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Check if the suggestion has been sent as a message
                                                        if (_getMessageSuggestions(
                                                                messages[index])
                                                            .contains(
                                                                suggestion)) {
                                                          // Handle suggestion tap, send the suggestion as a new message
                                                          sendSuggestion(
                                                              suggestion);
                                                        }
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors
                                                            .transparent, // Change button color as needed
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        side: const BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      child: Text(
                                                        suggestion,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: Card(
                                      margin: const EdgeInsets.only(
                                          left: 2, right: 2, bottom: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Column(
                                        children: [
                                          if (swipedMessage != null)
                                            _buildReplyInfo(),
                                          TextFormField(
                                            controller: _controller,
                                            focusNode: focusNode,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 5,
                                            minLines: 1,
                                            onChanged: (val) {
                                              if (val.isNotEmpty) {
                                                setState(() {
                                                  sendButton = true;
                                                });
                                              } else {
                                                setState(() {
                                                  sendButton = false;
                                                });
                                              }
                                            },
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Type a message",
                                                prefixIcon: IconButton(
                                                    onPressed: () {
                                                      focusNode.unfocus();
                                                      focusNode
                                                              .canRequestFocus =
                                                          false;
                                                      setState(() {
                                                        show = !show;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.emoji_emotions)),
                                                suffixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          _showBottomSheet(
                                                              context);
                                                        },
                                                        icon: const Icon(
                                                            Icons.attach_file)),
                                                    IconButton(
                                                        onPressed: () {
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CameraScreen(
                                                                roomId: widget
                                                                    .roomId,
                                                                phoneNumber: widget
                                                                    .phoneNumber,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                            Icons.camera_alt))
                                                  ],
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(5)),
                                          ),
                                        ],
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                    right: 5,
                                    left: 2,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: isRecording
                                        ? const Color.fromARGB(255, 140, 18, 18)
                                        : const Color(0xff128c7e),
                                    radius: 20,
                                    child: GestureDetector(
                                        onTap: () {
                                          if (sendButton) {
                                            _scrollController.animateTo(
                                                _scrollController
                                                    .position.maxScrollExtent,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeOut);
                                            if (swipedMessage != null) {
                                              sendTextReply(_controller.text);
                                            } else {
                                              sendMessage(
                                                _controller.text,
                                                widget.phoneNumber,
                                              );
                                            }

                                            _controller.clear();
                                            setState(() {
                                              sendButton = false;
                                            });
                                          } else {
                                            isRecording
                                                ? stopRecording()
                                                : record();
                                          }
                                        },
                                        child: Icon(
                                          sendButton ? Icons.send : Icons.mic,
                                          color: Colors.white,
                                        )),
                                  ),
                                )
                              ],
                            ),
                            show ? emojiSelect() : Container(),
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 390,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document",
                      onTap: () async {
                    FilePickerResult? res = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf',
                        ]);

                    if (res == null) {
                      return;
                    }

                    if (res.count > 0) {
                      print(res.names);
                      String filePath = res.files.first.path!;
                      File doc = File(filePath);
                      print('filePath ==================== $filePath');

                      var id = (await widget.whatsApp.uploadMedia(
                        mediaType: MediaType.parse(
                            "application/${res.files[0].extension}"),
                        mediaFile: doc,
                        mediaName: res.files[0].name,
                      ))['id'];

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);

                      var mesgRes = await widget.whatsApp.messagesMedia(
                          mediaId: id,
                          mediaType: "document",
                          to: widget.phoneNumber);
                      // Retrieve the FCM token
                      String? fcmToken =
                          await FirebaseMessaging.instance.getToken();
                      print('mesgRes = $mesgRes');
                      print('mesgRes id = $id');
                      print('mesgRes link = $link');
                      var messageObject = {
                        "document": {
                          "filename": res.files[0].name,
                          "mime_type": "application/${res.files[0].extension}",
                          "sha256": link['sha256'],
                          "id": id,
                          "url": link['url'],
                        },
                        "type": "document",
                        "from": phoneNumberId, //phoneNumber,
                        "id": mesgRes['messages'][0]['id'],
                        "timestamp": DateTime.now(),
                        "fcmToken": fcmToken
                      };

                      await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(enteredWABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    }
                  }),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.insert_photo,
                    Colors.purple,
                    "Photos",
                    onTap: () async {
                      ImagePicker imagePicker = ImagePicker();
                      // ignore: invalid_use_of_visible_for_testing_member
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.gallery);

                      if (file == null) return;

                      File doc = File(file.path);

                      String ext = file.path.split('.').last;

                      var id = (await widget.whatsApp.uploadMedia(
                          mediaType: MediaType.parse(
                              "image/${ext == 'jpg' ? 'jpeg' : ext}"),
                          mediaFile: doc,
                          mediaName: file.path.split('/').last))['id'];
                      var mesgRes;
                      if (swipedMessage == null) {
                        mesgRes = await widget.whatsApp.messagesMedia(
                            mediaId: id,
                            mediaType: "image",
                            to: widget.phoneNumber);
                      } else {
                        mesgRes = await widget.whatsApp.messagesReplyMedia(
                            mediaId: id,
                            messageId: swipedMessage!.id,
                            mediaType: "image",
                            to: widget.phoneNumber);
                      }

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);

                      print('+++ MESSAGE RES $mesgRes');

                      var messageObject;
                      // Retrieve the FCM token
                      String? fcmToken =
                          await FirebaseMessaging.instance.getToken();
                      if (swipedMessage == null) {
                        messageObject = {
                          "image": {
                            "mime_type": "image/${ext == 'jpg' ? 'jpeg' : ext}",
                            "sha256": link['sha256'],
                            "id": id,
                            "url": link['url'],
                          },
                          "type": "image",
                          "from": phoneNumberId, //phoneNumber,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "fcmToken": fcmToken
                        };
                      } else {
                        messageObject = {
                          "image": {
                            "mime_type": "image/${ext == 'jpg' ? 'jpeg' : ext}",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "image",
                          "from": phoneNumberId, //phoneNumber,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "fcmToken": fcmToken,
                          "context": {
                            'from': swipedMessage!.from,
                            'id': swipedMessage!.id
                          }
                        };
                      }

                      // ignore: unused_local_variable
                      var res = await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(enteredWABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.video_file,
                    Colors.purple,
                    "Videos",
                    onTap: () async {
                      ImagePicker imagePicker = ImagePicker();
                      // ignore: invalid_use_of_visible_for_testing_member
                      XFile? file = await imagePicker.pickVideo(
                          source: ImageSource.gallery);

                      if (file == null) return;

                      File doc = File(file.path);

                      String ext = file.path.split('.').last;

                      var id = (await widget.whatsApp.uploadMedia(
                          mediaType: MediaType.parse("video/$ext"),
                          mediaFile: doc,
                          mediaName: file.path.split('/').last))['id'];

                      var mesgRes;
                      if (swipedMessage == null) {
                        mesgRes = await widget.whatsApp.messagesMedia(
                            mediaId: id,
                            mediaType: "video",
                            to: widget.phoneNumber);
                      } else {
                        mesgRes = await widget.whatsApp.messagesReplyMedia(
                            mediaId: id,
                            messageId: swipedMessage!.id,
                            mediaType: "video",
                            to: widget.phoneNumber);
                      }

                      var link = await widget.whatsApp.getMediaUrl(mediaId: id);
                      var messageObject;
                      // Retrieve the FCM token
                      String? fcmToken =
                          await FirebaseMessaging.instance.getToken();
                      if (swipedMessage == null) {
                        messageObject = {
                          "video": {
                            "mime_type": "video/$ext",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "video",
                          "from": phoneNumberId, //phoneNumber,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "fcmToken": fcmToken
                        };
                      } else {
                        messageObject = {
                          "video": {
                            "mime_type": "video/$ext",
                            "sha256": link['sha256'],
                            "id": id
                          },
                          "type": "video",
                          "from": phoneNumberId, //phoneNumber,
                          "id": mesgRes['messages'][0]['id'],
                          "timestamp": DateTime.now(),
                          "fcmToken": fcmToken,
                          "context": {
                            'from': swipedMessage!.from,
                            'id': swipedMessage!.id
                          }
                        };
                      }

                      await FirebaseFirestore.instance
                          .collection("accounts")
                          .doc(enteredWABAID)
                          .collection("discussion")
                          .doc(widget.phoneNumber)
                          .collection("messages")
                          .add(messageObject);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(
                    Icons.location_pin,
                    Colors.teal,
                    "Location",
                    onTap: () {
                      checkLocationPermission();
                    },
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact", onTap: () {
                    if (swipedMessage == null) {
                      Get.toNamed(PhoneContactsPage.id, arguments: {
                        "fromChat": true,
                        'to': int.parse(widget.phoneNumber),
                        'whatsAppApi': widget.whatsApp,
                        'swipedMessageId': null
                      });
                    } else {
                      Get.toNamed(PhoneContactsPage.id, arguments: {
                        "fromChat": true,
                        'to': int.parse(widget.phoneNumber),
                        'whatsAppApi': widget.whatsApp,
                        'swipedMessageId': swipedMessage!.id
                      });
                    }
                  }),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              // ignore: prefer_const_constructors
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                iconCreation(
                  Icons.note_alt,
                  Colors.yellow,
                  "Templates",
                  onTap: () {
                    fetchDataAndShowDialog();
                  },
                ),
                const SizedBox(
                  width: 40,
                ),
                iconCreation(
                  Icons.note_alt,
                  Colors.red,
                  "Catalogs",
                  onTap: () {
                    fetchDataAndShowCatalogDialog();
                  },
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icon, Color color, String text,
      {void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icon,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void replyToMessage(Message message) {
    setState(() {
      swipedMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      swipedMessage = null;
    });
  }

  Widget buildReply() {
    return Container();
  }

  Widget emojiSelect() {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          print(emoji);
          setState(() {
            _controller.text += emoji.emoji;
          });
        },
        onBackspacePressed: () {},
        config: Config(
          columns: 8,
          emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.RECENT,
          bgColor: Colors.white,
          indicatorColor: const Color(0xff128c7e),
          iconColor: Colors.grey,
          iconColorSelected: const Color(0xff128c7e),
          backspaceColor: const Color(0xff128c7e),
          skinToneDialogBgColor: Colors.white,
          skinToneIndicatorColor: Colors.grey,
          enableSkinTones: true,
          recentsLimit: 28,
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.CUPERTINO,
        ),
      ),
    );
  }
}

// // Format timestamp
// DateTime messageTime =
//     DateTime.fromMillisecondsSinceEpoch(
//         messages[index]
//             .timestamp
//             .millisecondsSinceEpoch);
// DateTime now = DateTime.now();

// String formattedTime;
// if (now.difference(messageTime).inDays == 0) {
//   // If the message is from today, display the formatted time
//   formattedTime =
//       DateFormat("h:mm a").format(messageTime);
// } else if (now.difference(messageTime).inDays ==
//     1) {
//   // If the message is from yesterday, display 'Yesterday'
//   formattedTime = 'Yesterday';
// } else {
//   // If the message is older than 2 days, display the date
//   formattedTime =
//       DateFormat.yMMMd().format(messageTime);
// }
