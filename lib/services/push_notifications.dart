
import 'package:sea/models/CommentModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/AlertModel.dart';
import '../models/EventModel.dart';
import '../models/GroupModel.dart';
import '../models/NotificationModel.dart';
import '../models/UserSegment.dart';
import 'fb_database.dart';
import 'fb_messaging.dart';
import 'helpers.dart';

class PushNotifications {

  static Future sendNotification(SEAUser user, String title, String body) async {
    final notification = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      body: body,
      createdAt: DateTime.now().toString(),
    );
    await FBDatabase.addNotification(
      user,
      notification,
    );
    print(user.fcmToken);
    await FBMessaging.sendNotification(
        user.fcmToken!,
        title,
        body,
        {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'notificationID': notification.id,
        }
    );
  }

  static Future sendAlertNotification(AlertModel alertModel, List<UserSegment> audience) async {
    List<SEAUser> allUsers = await FBDatabase.getAllUsers();

    final userWhoCreatedPost = await FBDatabase.getUserData(alertModel.creatorID);
    for(SEAUser user in allUsers) {
      if(user.id != userWhoCreatedPost.id && user.pushNotificationSettings.allowPushNotifications && user.userSegmentIDs != null && user.userSegmentIDs!.any((element) => audience.contains(element))) {
        print(user.firstName);
        await sendNotification(user, '[ALERT] ${alertModel.title}', alertModel.body);
      }
    }
  }

  static Future sendNewPostNotification(PostModel postModel, GroupModel? groupModel, List<UserSegment>? audience) async {

    List<String> uidsNotified = [];
    List<SEAUser> allUsers = await FBDatabase.getAllUsers();

    if(audience != null) {
      final userWhoCreatedPost = await FBDatabase.getUserData(postModel.authorID);
      for(SEAUser user in allUsers) {
        if(user.pushNotificationSettings.allowPushNotifications && user.userSegmentIDs != null && user.userSegmentIDs!.any((element) => audience.contains(element))) {
          print(user.firstName);
          await sendNotification(user, 'New Post from ${userWhoCreatedPost.firstName} ${userWhoCreatedPost.lastName}', postModel.body);
        }
      }
    }

    if(groupModel != null) {
      if(postModel.privacyLevel.isVisibleToPublic! && allUsers.isNotEmpty) {
        print('Public If');
        for(SEAUser user in allUsers) {
          if(user.pushNotificationSettings.newPublicEvents && user.pushNotificationSettings.allowPushNotifications) {
            print(user.firstName);
            await sendNotification(user, 'New Post [${groupModel.name}]', postModel.body);
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
      else if(postModel.privacyLevel.isVisibleToFollowers! && allUsers.isNotEmpty) {
        print('Followers If');
        for(SEAUser user in allUsers) {
          if(isFollowerOfGroup(groupModel, user.id) && user.pushNotificationSettings.newEventFromFollowingGroup && user.pushNotificationSettings.allowPushNotifications) {
            await sendNotification(user, 'New Post [${groupModel.name}]', postModel.body);
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
      else if(postModel.privacyLevel.isVisibleToMembers! && allUsers.isNotEmpty) {
        print('Members If');
        for(SEAUser user in allUsers) {
          if(isMemberOfGroup(groupModel, user.id) && user.pushNotificationSettings.newEventFromMemberGroup && user.pushNotificationSettings.allowPushNotifications) {
            await sendNotification(user, 'New Post [${groupModel.name}]', postModel.body);
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
    }
  }

  static Future sendNewEventNotification(EventModel eventModel) async {

    List<String> uidsNotified = [];
    List<SEAUser> allUsers = await FBDatabase.getAllUsers();

    if(eventModel.groupID == null) {
      final creator = await FBDatabase.getUserData(eventModel.creatorID);
      for(SEAUser user in allUsers) {
        if(user.pushNotificationSettings.allowPushNotifications && !uidsNotified.contains(user.id)) {
          print(user.firstName);
          for(var segment in eventModel.userSegmentIDs!) {
            if((user.userSegmentIDs ?? []).contains(segment)) {
              await sendNotification(user, eventModel.title!, 'New event created by ${creator.firstName} ${creator.lastName}');
              uidsNotified.add(user.id);
            }
          }
        }
      }
    }
    else {
      final groupModel = await FBDatabase.getGroup(eventModel.groupID!);
      if(eventModel.privacyLevel.isVisibleToPublic! && allUsers.isNotEmpty) {
        for(SEAUser user in allUsers) {
          if(user.pushNotificationSettings.newPublicEvents && user.pushNotificationSettings.allowPushNotifications) {
            print(user.firstName);
            await sendNotification(user, eventModel.title!, 'New event created by ${groupModel.name}');
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
      else if(eventModel.privacyLevel.isVisibleToFollowers! && allUsers.isNotEmpty) {
        for(SEAUser user in allUsers) {
          if(isFollowerOfGroup(groupModel, user.id) && user.pushNotificationSettings.newEventFromFollowingGroup && user.pushNotificationSettings.allowPushNotifications) {
            await sendNotification(user, eventModel.title!, 'New event created by ${groupModel.name}');
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
      else if(eventModel.privacyLevel.isVisibleToMembers! && allUsers.isNotEmpty) {
        for(SEAUser user in allUsers) {
          if(isMemberOfGroup(groupModel, user.id) && user.pushNotificationSettings.newEventFromMemberGroup && user.pushNotificationSettings.allowPushNotifications) {
            await sendNotification(user, eventModel.title!, 'New event created by ${groupModel.name}');
            uidsNotified.add(user.id);
          }
        }
        allUsers.removeWhere((element) => uidsNotified.contains(element.id));
      }
    }
  }

  static Future sendLikedPostNotification(PostModel postModel) async {
    final userWhosePostWasLiked = await FBDatabase.getUserData(postModel.authorID);
    final userWhoLikedPost = await FBDatabase.getUserData(FBAuth().getUserID()!);

    if(userWhosePostWasLiked.pushNotificationSettings.likesOnPosts
        && userWhosePostWasLiked.pushNotificationSettings.allowPushNotifications) {
      await sendNotification(
        userWhosePostWasLiked,
        postModel.groupID != null ? await FBDatabase.getGroup(postModel.groupID!).then((value) => value.name) : '',
        '${userWhoLikedPost.firstName} ${userWhoLikedPost.lastName} liked your post.',
      );
    }
  }

  static Future sendCommentOnPostNotification(String postID, CommentModel commentModel) async {
    final postModel = await FBDatabase.getPost(postID);
    final userWhosePostWasCommentedOn = await FBDatabase.getUserData(postModel.authorID);
    final group = await FBDatabase.getGroup(postModel.groupID!);
    final userWhoCommentedOnPost = await FBDatabase.getUserData(FBAuth().getUserID()!);

    if(userWhosePostWasCommentedOn.pushNotificationSettings.commentsOnPosts
        && userWhosePostWasCommentedOn.pushNotificationSettings.allowPushNotifications) {
      await sendNotification(
        userWhosePostWasCommentedOn,
        group.name,
        '${userWhoCommentedOnPost.firstName} ${userWhoCommentedOnPost.lastName} commented "${commentModel.body}"',
      );
    }
  }

  static Future sendUpdatedEventNotification(EventModel eventModel) async {
    if(eventModel.isGoingIDs != null) {
      for(String uid in eventModel.isGoingIDs!) {
        final user = await FBDatabase.getUserData(uid);
        if(user.pushNotificationSettings.allowPushNotifications
            && user.pushNotificationSettings.eventAttendingDetailsChanged) {
          print('sending...');
          if(eventModel.groupID != null) {
            final groupModel = await FBDatabase.getGroup(eventModel.groupID!);
            await sendNotification(user, 'Event Updated [${groupModel.name}]', '${eventModel.title}');
          }
          else {
            await sendNotification(user, 'Event Updated', '${eventModel.title}');
          }
        }
      }
    }
  }

  static Future sendCancelledEventNotification(EventModel eventModel) async {
    if(eventModel.isGoingIDs != null) {
      for(String uid in eventModel.isGoingIDs!) {
        final user = await FBDatabase.getUserData(uid);
        if(user.pushNotificationSettings.allowPushNotifications
            && user.pushNotificationSettings.eventAttendingCancelled) {
          print('sending...');
          if(eventModel.groupID != null) {
            final group = await FBDatabase.getGroup(eventModel.groupID!);
            await sendNotification(user, 'Event Cancelled [${group.name}]', '${eventModel.title}');
          }
          else {
            final creator = await FBDatabase.getUserData(eventModel.creatorID);
            await sendNotification(user, 'Event Cancelled [${creator.firstName} ${creator.lastName}]', '${eventModel.title}');
          }

        }
      }
    }
  }

  static Future sendMemberRequestPushNotifications(GroupModel groupModel, String uidOfMemberRequesting) async {
    final userRequestingAccess = await FBDatabase.getUserData(uidOfMemberRequesting);

    final creator = await FBDatabase.getUserData(groupModel.creatorID);
    if(creator.pushNotificationSettings.allowPushNotifications) {
      final creatorToken = await FBDatabase.getUserFCMToken(groupModel.creatorID);
      if(creatorToken != null) {
        final title = groupModel.name;
        final body = '${userRequestingAccess.firstName} ${userRequestingAccess.lastName} has requested to join the group.';
        await sendNotification(creator, title, body);
      }
    }

    for(String uid in groupModel.ownerIDs) {
      if(uid != groupModel.creatorID) {
        final owner = await FBDatabase.getUserData(uid);
        if(owner.pushNotificationSettings.allowPushNotifications) {
          final token = await FBDatabase.getUserFCMToken(uid);
          if(token != null) {
            final title = groupModel.name;
            final body = '${userRequestingAccess.firstName} ${userRequestingAccess.lastName} has requested to join the group.';
            await sendNotification(creator, title, body);
          }
        }
      }
    }
  }

}