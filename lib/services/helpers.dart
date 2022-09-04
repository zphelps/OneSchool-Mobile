
import 'dart:math';
import 'dart:ui';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/MessageModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/RSVPPermissionsModel.dart';
import 'package:sea/screens/groups/groups.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../models/NotificationModel.dart';
import '../models/SEAUser.dart';
import 'fb_auth.dart';
import 'fb_database.dart';
import 'fb_messaging.dart';


///DateTime Helpers
String timeAgo(String dateTimeString) {
  return timeago.format(DateTime.parse(dateTimeString));
}

bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month
      && date1.day == date2.day;
}

///Game Helpers
String gameStatusString(GameModel gameModel) {
  final datetime = DateTime.parse(gameModel.dateTimeString);
  if(DateTime.now().isBefore(datetime) && !gameModel.isMarkedDone) {
    return 'Upcoming';
  }
  else if(!gameModel.isMarkedDone && DateTime.now().isBefore(datetime.add(const Duration(hours: 3)))){
    return 'Live';
  }
  else if(!gameModel.isMarkedDone
      && gameModel.homeTeamScore == null
      && gameModel.opposingTeamScore == null
      && DateTime.now().isAfter(datetime.add(const Duration(hours: 3)))){
    return 'No Score';
  }
  else if(gameModel.isMarkedDone && gameModel.homeTeamScore != null && gameModel.opposingTeamScore != null) {
    return 'FINAL';
  }
  else if(DateTime.now().isAfter(datetime.add(const Duration(hours: 3))) && gameModel.homeTeamScore != null && gameModel.opposingTeamScore != null) {
    return 'FINAL';
  }
  return 'Upcoming';
}

String getGameUpdateText(int homeScore, int opponentScore, String homeTeamName, String opposingTeamName) {
  if(homeScore > opponentScore) {
    return 'SCORE UPDATE: $homeTeamName leads $opposingTeamName $homeScore-$opponentScore';
  }
  else if(homeScore < opponentScore) {
    return 'SCORE UPDATE: $opposingTeamName leads $homeTeamName $opponentScore-$homeScore';
  }
  else {
    return 'SCORE UPDATE: The game is tied $opponentScore-$homeScore';
  }
}

///Event Helpers
Future<Metadata?> getURLMetadata(String url) async {
  return await AnyLinkPreview.getMetadata(
    link: url,
  );
}

bool userCanRSVP(EventModel eventModel, SEAUser user) {
  if(eventModel.rsvpPermissions.publicCanRSVP!) {
    return true;
  }
  else if(eventModel.rsvpPermissions.followersCanRSVP! && user.groupsFollowing!.contains(eventModel.groupID)) {
    return true;
  }
  else if(eventModel.rsvpPermissions.membersCanRSVP! && user.groupsMemberOf!.contains(eventModel.groupID)) {
    return true;
  }
  return false;
}


///Post Management Helpers
bool userHasLikedPost(PostModel postModel, String uid) {
  return (postModel.likes ?? []).contains(uid);
}

///Group Management Helper Functions
bool isMemberOfGroup(GroupModel groupModel, String uid) {
  return groupModel.memberIDs.contains(uid);
}

bool isFollowerOfGroup(GroupModel groupModel, String uid) {
  return groupModel.followerIDs.contains(uid);
}

bool isRequestedMemberOfGroup(GroupModel groupModel, String uid) {
  return groupModel.memberRequestIDs.contains(uid);
}

bool isCreatorOfGroup(GroupModel groupModel, String uid) {
  return groupModel.creatorID == uid;
}

bool isOwnerOfGroup(GroupModel groupModel, String uid) {
  return groupModel.ownerIDs.contains(uid);
}

GroupAssociation getGroupAssociation(GroupModel groupModel, String uid) {
  if(isCreatorOfGroup(groupModel, uid)) {
    return GroupAssociation.creator;
  }
  else if(isOwnerOfGroup(groupModel, uid)) {
    return GroupAssociation.owner;
  }
  else if(isMemberOfGroup(groupModel, uid)) {
    return GroupAssociation.member;
  }
  else if(isFollowerOfGroup(groupModel, uid)) {
    return GroupAssociation.follower;
  }
  else {
    return GroupAssociation.none;
  }
}

Future<void> requestToJoinGroup(String uid, GroupModel groupModel) async {
  await FBDatabase.requestToJoinGroup(groupModel.id, uid);
  await PushNotifications.sendMemberRequestPushNotifications(groupModel, uid);
}

Future<void> withdrawRequestToJoinGroup(String uid, GroupModel groupModel) async {
  await FBDatabase.removeRequestToJoinGroup(groupModel.id, uid);
}

Future<void> followGroup(String uid, String groupID) async {
  await FBDatabase.addFollowerToGroup(groupID, uid);
  await FBDatabase.addGroupUserIsFollowing(uid, groupID);
}

Future<void> unfollowGroup(String uid, String groupID) async {
  await FBDatabase.removeFollowerFromGroup(groupID, uid);
  await FBDatabase.removeGroupUserIsFollowing(uid, groupID);
}

///Media Query Functions
double getViewportWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getViewportHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Generate Material Colors Swatch
int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);

MaterialColor generateMaterialColorSwatch(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}


///Messaging Functions

String getMessageBodyPreview(MessageModel messageModel) {
  String? messageBody;
  if(messageModel.imageURL != null && messageModel.videoURL != null) {
    messageBody = 'Sent a video';
  }
  else if(messageModel.imageURL != null) {
    messageBody = 'Sent an image';
  }
  else {
    messageBody = messageModel.body;
  }
  return messageBody;
}

String getMessageNotificationTitle(MessageModel messageModel, ConversationModel conversationModel) {
  if(conversationModel.isGroupConversation) {
    return '${messageModel.senderFirstName} ${messageModel.senderLastName} [${conversationModel.name}]';
  }
  return '[Private Message] ${messageModel.senderFirstName} ${messageModel.senderLastName}';
}


Future sendMessage(MessageModel messageModel, ConversationModel conversationModel, List<SEAUser> recipients) async {
  await FBDatabase.sendMessage(messageModel, conversationModel.id, conversationModel.creatorID);
  recipients.removeWhere((element) => element.id == FBAuth().getUserID()!);
  await Future.forEach(recipients, (SEAUser recipient) async {
    if(recipient.pushNotificationSettings.allowPushNotifications && !recipient.pushNotificationSettings.conversationsMuted.contains(conversationModel.id)) {
      await FBMessaging.sendNotification(recipient.fcmToken!, getMessageNotificationTitle(messageModel, conversationModel), getMessageBodyPreview(messageModel),
          {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'conversationModel': conversationModel.toMap(),
            'isGroup': conversationModel.isGroupConversation,
            'members': recipients.map((e) => e.toMap()).toList()
          });
    }
  });
}

//helper method to show progress
late ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Colors.grey,
      progressWidget: Container(
          padding: const EdgeInsets.all(8.0),
          child: const CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation(Colors.grey),
          )),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
          color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}
