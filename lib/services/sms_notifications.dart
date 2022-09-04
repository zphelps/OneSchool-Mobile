
import 'package:sea/models/UserSegment.dart';

import 'fb_database.dart';

class SMSNotifications {

  static Future sendAlertSMS({required List<String> userSegmentIDs, required String body}) async {
    final users = await FBDatabase.getAllUsers();
    for(var user in users) {
      for(var segment in user.userSegmentIDs ?? []) {
        if(userSegmentIDs.contains(segment) && user.phoneNumber!=null) {
          await FBDatabase.addSMSNotification({
            'to': '+${user.phoneNumber}',
            'body': body,
          });
          break;
        }
      }
    }

  }
}