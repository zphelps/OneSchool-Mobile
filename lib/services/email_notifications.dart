
import 'package:sea/models/UserSegment.dart';

import 'fb_database.dart';

class EmailNotifications {

  static Future sendAlertEmail({required List<String> userSegmentIDs, required String schoolName, required String date, required String title, required String body}) async {
    final users = await FBDatabase.getAllUsers();
    final List<String> to = [];
    for(var user in users) {
      for(var segment in user.userSegmentIDs ?? []) {
        if(userSegmentIDs.contains(segment)) {
          to.add(user.email);
          break;
        }
      }
    }
    print(to);
    await FBDatabase.addEmailNotification({
      'to': to,
      'template': {
        'name': 'alert 2',
        'data': {
          'title': title,
          'body': body,
          'schoolName': schoolName,
          'date': date,
        }
      }
    });
  }
}