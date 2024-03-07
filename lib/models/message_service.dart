/*import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<String?> getEmojiForMessageId(String messageId) async {
    try {
      DocumentSnapshot emojiSnapshot = await _firestore
          .collection('emojiReactions')
          .where('message_id', isEqualTo: messageId)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first;
        } else {
          return null; // No matching emoji, return null
        }
      });

      if (emojiSnapshot != null) {
        return emojiSnapshot['emoji'];
      } else {
        return null; // Return null in case of no emoji snapshot
      }
    } catch (e) {
      print('Error fetching emoji: $e');
      return null; // Handle the error and return null
    }
  }
}*/
// Okay lets use another approach , just take the emoji reaction firestore data , fetch the emjoi from it and create a emoji card for the same. fine!!! now find the message which reacted by the fetched emoji and attach the emoji card to that particular message. the field name (id) of message is present in message data of firestore and in emoji reaction data of firestore there is a (message_id) field which is same as the (id) field of reacted message data of firestore. now we have to just take emoji make it a card and overlap/attach on the corner of the reacted message card which is already exist in chat page and which is reacted by emoji.

// Apply this behavior in following all types of message showing code :-

// class ReplyCard extends StatefulWidget {
//   ReplyCard({super.key, required this.message, required this.time}) {
//     whatsAppApi = WhatsAppApi()
//       ..setup(
//           accessToken: AppConfig.apiKey,
//           fromNumberId: int.parse(AppConfig.phoneNoID));
//   }

//   final Message message;
//   final String time;
//   late WhatsAppApi whatsAppApi;
//   late String phoneNumber;

//   @override
//   State<ReplyCard> createState() => _ReplyCardState();
// }

// class _ReplyCardState extends State<ReplyCard> {
// @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width - 45,
//         ),
//         child: widget.message.type == 'audio'
//             ? Stack(
//                 children: [
//                   FutureBuilder(
//                       future: widget.whatsAppApi
//                           .getMediaUrl(mediaId: widget.message.value['id']),
//                       builder: ((context, AsyncSnapshot<dynamic> snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done) {
//                           return Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 8, bottom: 8, right: 64, left: 10),
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.5,
//                               padding: EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xffffffff),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: GestureDetector(
//                                   onTap: () {
//                                     isPlaying
//                                         ? pause()
//                                         : _loadFile(snapshot.data['url'], {
//                                             "Authorization":
//                                                 "Bearer ${AppConfig.apiKey}"
//                                           });
//                                   },
//                                   onSecondaryTap: () {
//                                     stop();
//                                   },
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           isPlaying
//                                               ? const Icon(Icons.pause)
//                                               : const Icon(Icons.play_arrow),
//                                           // Text(
//                                           //   'Audio-${doc['timestamp']}',
//                                           //   maxLines: 10,
//                                           // ),
//                                         ],
//                                       ),
//                                     ],
//                                   )),
//                             ),
//                           );
//                         } else {
//                           return const CircularProgressIndicator();
//                         }
//                       })),
//                   Positioned(
//                     bottom: 10,
//                     right: 70,
//                     child: Row(
//                       children: [
//                         Text(
//                           widget.time,
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//             : Card(
//                 elevation: 1,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//                 // color: Color(0xffdcf8c6),
//                 margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//                 child: Stack(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         left: 8,
//                         right: 50,
//                         top: 5,
//                         bottom: 10,
//                       ),
//                       child: widget.message.type == 'document'
//                           ? FutureBuilder(
//                               future: widget.whatsAppApi.getMediaUrl(
//                                 mediaId: widget.message.value['id'],
//                               ),
//                               builder:
//                                   (context, AsyncSnapshot<dynamic> snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.done) {
//                                   print(
//                                       'pdfLink ========= ${snapshot.data['url']?.toString() ?? 'default_pdf_url'}');

//                                   return GestureDetector(
//                                     onTap: () async {
//                                       final pdfUrl =
//                                           snapshot.data['url']?.toString() ??
//                                               '';
//                                       final headers = {
//                                         "Authorization":
//                                             "Bearer ${AppConfig.apiKey}",
//                                       };
//                                       await Get.toNamed(
//                                         PDFViewerPage.id,
//                                         arguments: {
//                                           'link': pdfUrl,
//                                           'headers': headers,
//                                         },
//                                       );
//                                     },
//                                     child: Text(
//                                       widget.message.value['filename'],
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   );
//                                 } else if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   // Only show CircularProgressIndicator while loading
//                                   return const CircularProgressIndicator();
//                                 } else {
//                                   // Handle other states if needed
//                                   return const Text('Error loading data');
//                                 }
//                               },
//                             )
//                           : widget.message.type == "image"
//                               ? FutureBuilder(
//                                   future: widget.whatsAppApi.getMediaUrl(
//                                       mediaId: widget.message.value['id']),
//                                   builder: (context,
//                                       AsyncSnapshot<dynamic> snapshot) {
//                                     if (snapshot.connectionState ==
//                                         ConnectionState.done) {
//                                       print(
//                                           'ImageLink ======== ${snapshot.data?['url']?.toString() ?? 'default_image_url'}');
//                                       return CachedNetworkImage(
//                                         progressIndicatorBuilder: (context, url,
//                                                 downloadProgress) =>
//                                             CircularProgressIndicator(
//                                                 value:
//                                                     downloadProgress.progress),
//                                         errorWidget: (context, url, error) =>
//                                             const Icon(Icons.error),
//                                         imageUrl:
//                                             snapshot.data?['url']?.toString() ??
//                                                 'default_image_url',
//                                         httpHeaders: const {
//                                           "Authorization":
//                                               "Bearer ${AppConfig.apiKey}"
//                                         },
//                                       );
//                                     }

//                                     return const CircularProgressIndicator();
//                                   })
//                               : widget.message.type == "video"
//                                   ? FutureBuilder(
//                                       future: widget.whatsAppApi.getMediaUrl(
//                                           mediaId: widget.message.value['id']),
//                                       builder: (context,
//                                           AsyncSnapshot<dynamic> snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.done) {
//                                           Text(
//                                               'videoLink ========= ${snapshot.data['url']}');
//                                           return GestureDetector(
//                                             onTap: () {
//                                               Get.toNamed(VideoPlayerScreen.id,
//                                                   arguments: {
//                                                     'link':
//                                                         snapshot.data['url'],
//                                                     'headers': const {
//                                                       "Authorization":
//                                                           "Bearer ${AppConfig.apiKey}"
//                                                     },
//                                                   });
//                                             },
//                                             child: const Text(
//                                               'Click to view the video!',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                           );
//                                         }

//                                         return const CircularProgressIndicator();
//                                       })
//                                   : widget.message.type == 'location'
//                                       ? GestureDetector(
//                                           onTap: () {
//                                             MapUtils.openMap(
//                                                 widget
//                                                     .message.value['latitude'],
//                                                 widget.message
//                                                     .value['longitude']);
//                                           },
//                                           child: const Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Icon(
//                                                 Icons.location_on,
//                                                 size: 50.0,
//                                               ),
//                                               Text(
//                                                 'Click to open in maps',
//                                                 style: TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                               )
//                                             ],
//                                           ))
//                                       : widget.message.type == 'contacts'
//                                           ? GestureDetector(
//                                               onTap: () {
//                                                 launch(
//                                                     "tel://${widget.message.value[0]['phones'][0]['phone']}");
//                                               },
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 children: [
//                                                   const CircleAvatar(
//                                                       child: Icon(Icons.phone)),
//                                                   const SizedBox(
//                                                     width: 8.0,
//                                                   ),
//                                                   Text(widget.message.value[0]
//                                                       ['name']['first_name'])
//                                                 ],
//                                               ),
//                                             )
//                                           : GestureDetector(
//                                               onTap: () {
//                                                 if (isPhoneNumber()) {
//                                                   launch(
//                                                       "tel://${widget.message.value['body']}");
//                                                 }
//                                               },
//                                               child: Text(
//                                                 widget.message.type == 'text'
//                                                     ? widget
//                                                         .message.value['body']
//                                                     : 'Not supported',
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   color: isPhoneNumber()
//                                                       ? Colors.blue
//                                                       : Colors.black54,
//                                                 ),
//                                               ),
//                                             ),
//                     ),
//                     Positioned(
//                       bottom: 4,
//                       right: 10,
//                       child: Text(
//                         widget.time,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

// Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
//   ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
//   ui.FrameInfo frame = await codec.getNextFrame();
//   return frame.image;
// }

// No man emoji field is never gonna be present in message data , because emoji reaction data is stored individually in firestore which looks like 
// from
// "917304652722"
// (string)

// id
// "wamid.HBgMOTE3MzA0NjUyNzIyFQIAEhggNjI5MjFDNEY1NDI0NENDMUEwNUE5M0Q1MTkzNjk4MUQA"
// (string)

// reaction
// (map)

// emoji
// "😮"
// (string)

// message_id
// "wamid.HBgMOTE3MzA0NjUyNzIyFQIAERgSQzE3MkNFNzZEODczQkEzOUZEAA=="
// (string)

// timestamp
// December 29, 2023 at 12:48:05 PM UTC+5:30
// (timestamp)

// type
// "reaction"

// And the reacted message data structure of firestore looks like 

// from
// "170851489447426"
// (string)

// id
// "wamid.HBgMOTE3MzA0NjUyNzIyFQIAERgSQzE3MkNFNzZEODczQkEzOUZEAA=="
// (string)

// text
// (map)

// body
// "Ashish "
// (string)

// timestamp
// December 28, 2023 at 11:29:52 AM UTC+5:30
// (timestamp)

// type
// "text"

// As you can see the (id) field of message data matches the (message_id) field of emoji reaction data , because emoji reaction data stored with the (id) of the reacted message in firestore but individually , soo make the logic according to it , and create a separate card of emoji from emoji reaction data , and attach that card to the reacted message's card by matching the (id) of reacted message and (message_id) from emoji reaction data 
