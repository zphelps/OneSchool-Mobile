
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:sea/models/NotificationModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/fb_database.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';


class FBMessaging {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static sendNotification(String token, String title, String body,
      Map<String, dynamic>? payload) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': payload ?? <String, dynamic>{},
          'to': token
        },
      ),
    );
  }

  static sendPayLoad(String token, {Map<String, dynamic>? callData}) async {
    print('sendPayLoad $token');
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'data': {'callData': callData},
          'to': token
        },
      ),
    );
  }
}