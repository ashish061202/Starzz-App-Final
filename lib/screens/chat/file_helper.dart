import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<File> get localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/unread_messages.txt');
  }

  static Future<void> writeUnreadCount(int unreadCount) async {
    final file = await localFile;
    await file.writeAsString('$unreadCount');
  }

  static Future<int> readUnreadCount() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }
}