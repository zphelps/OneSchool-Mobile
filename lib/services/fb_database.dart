
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:sea/models/CommentModel.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GameUpdateModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/LocationModel.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/models/MessageModel.dart';
import 'package:sea/models/NotificationModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/models/PollChoiceModel.dart';
import 'package:sea/models/PollModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/screens/groups/groups.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../enums.dart';
import '../models/AlertModel.dart';
import '../models/UserSegment.dart';
import '../screens/feed/feed_query.dart';

class FBDatabase {

  static String? tenantID;
  static final _database = FirebaseFirestore.instance;

  ///Tenant Functions
  static Future<TenantModel> getTenant() async  => await _database.collection('tenants').doc(tenantID)
      .get().then((value) => TenantModel.fromMap(value.data(), value.id));

  static Future<void> updateTenantConfiguration(String field, dynamic value) => _database.collection('tenants').doc(tenantID)
      .update(
      {
        field: value,
      }
  );

  ///SMS Notification Functions
  static Future<void> addSMSNotification(Map<String, dynamic> emailPayload) => _database.collection('sms').doc(const Uuid().v4()).set(emailPayload);

  ///Email Notification Functions
  static Future<void> addEmailNotification(Map<String, dynamic> emailPayload) => _database.collection('email').doc(const Uuid().v4()).set(emailPayload);

  ///Notification Functions
  static Future<void> addNotification(SEAUser user, NotificationModel notificationModel) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(user.id).collection('notifications').doc().set(notificationModel.toMap());

  ///User Data Functions
  static Future<void> createUserData(SEAUser user) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(user.id).set(user.toMap());

  static Future<List<SEAUser>> getAllUsers() async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('users').get();
    return snap.docs.map((e) => SEAUser.fromMap(e.data(), e.id)).toList();
  }

  static Future<List<UserSegment>> getUserSegments() async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('user segments').get();
    return snap.docs.map((e) => UserSegment.fromMap(e.data(), e.id)).toList();
  }

  static Future<UserSegment> getUserSegment(String segmentID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('user segments').doc(segmentID).get();
    return UserSegment.fromMap(snap.data(), snap.id);
  }

  static Future<String?> getUserFCMToken(String uid) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('users').doc(uid).get();
    return SEAUser.fromMap(snap.data(), snap.id).fcmToken;
  }

  static Future<SEAUser> getUserData(String uid) async  => await _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).get().then((value) => SEAUser.fromMap(value.data(), value.id));

  static Future<List<SEAUser>> getManyUsers(List<dynamic> uids) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('users').where('id', whereIn: uids).get();
    return snap.docs.map((e) => SEAUser.fromMap(e.data(), e.id)).toList();
  }

  static Future<List<AlertModel>> getPinnedAlerts(SEAUser user) async {

    final snap = await _database.collection('tenants').doc(tenantID).collection('alerts')
        .where('pinned', isEqualTo: true).orderBy('postedAt').get();

    final alerts = snap.docs.map((e) => AlertModel.fromMap(e.data(), e.id)).where((element) {
          if(user.userRole == UserRole.administrator || user.userRole == UserRole.manager) {
            return true;
          }
          else {
            for(var segment in user.userSegmentIDs ?? []) {
              if(element.userSegmentIDs.contains(segment)) {
                return true;
              }
            }
            return false;
          }
        }).toList();
    List<AlertModel> cleanedAlerts = [];
    await Future.forEach(alerts, (AlertModel alert) async {
      if(DateTime.parse(alert.postedAt).add(alert.pinDuration).isBefore(DateTime.now())) {
        await unpinAlert(alert.id);
      }
      else {
        cleanedAlerts.add(alert);
      }
    });
    return cleanedAlerts;
  }

  static Future<void> createAlert(AlertModel alertModel) => _database.collection('tenants').doc(tenantID)
      .collection('alerts').doc(alertModel.id).set(alertModel.toMap());


  static Future<void> unpinAlert(String alertID) => _database.collection('tenants').doc(tenantID)
      .collection('alerts').doc(alertID).update(
      {
        'pinned': false,
      }
  );

  static Future<void> updatePushNotificationSetting(String uid, String field, bool value) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'pushNotificationSettings.$field': value,
      }
  );

  static Future<void> updateUserProfilePhoto(String uid, String imageURL) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'profileImageURL': imageURL,
      }
  );

  static Future<void> updateUserPhoneNumber(String uid, int phone) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'phoneNumber': phone,
      }
  );

  static Future<void> updateUserFCMToken(String uid, String token) => _database.collection('tenants').doc(FBAuth().getTenantID())
      .collection('users').doc(uid).update(
      {
        'fcmToken': token,
      }
  );

  static Future<void> addGroupUserIsMemberOf(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsMemberOf': FieldValue.arrayUnion([groupID]),
      }
  );

  static Future<void> addGroupUserIsOwnerOf(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsOwnerOf': FieldValue.arrayUnion([groupID]),
      }
  );

  static Future<void> addGroupUserIsFollowing(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsFollowing': FieldValue.arrayUnion([groupID]),
      }
  );

  static Future<void> removeGroupUserIsMemberOf(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsMemberOf': FieldValue.arrayRemove([groupID]),
      }
  );

  static Future<void> removeGroupUserIsOwnerOf(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsOwnerOf': FieldValue.arrayRemove([groupID]),
      }
  );

  static Future<void> removeGroupUserIsFollowing(String uid, String groupID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'groupsFollowing': FieldValue.arrayRemove([groupID]),
      }
  );

  static Future<void> muteConversation(String uid, String conversationID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'pushNotificationSettings.conversationsMuted': FieldValue.arrayUnion([conversationID]),
      }
  );

  static Future<void> unmuteConversation(String uid, String conversationID) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).update(
      {
        'pushNotificationSettings.conversationsMuted': FieldValue.arrayRemove([conversationID]),
      }
  );

  static Future<List<dynamic>> getGroupsUserIsFollowing(String uid) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).get().then((user) => (SEAUser.fromMap(user.data(), user.id).groupsFollowing ?? ['']).toList());

  static Future<List<dynamic>> getGroupsUserIsMemberOf(String uid) => _database.collection('tenants').doc(tenantID)
      .collection('users').doc(uid).get().then((user) => (SEAUser.fromMap(user.data(), user.id).groupsMemberOf ?? ['']).toList());

  ///Group Permission Functions
  static Future<void> createGroupPermissions(GroupPermissionsModel groupPermissionsModel) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).set(groupPermissionsModel.toMap());
  }

  static Future<void> addUserWhoCanCreatePosts(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canCreatePosts': FieldValue.arrayUnion([uid]),
    });
  }

  static Future<void> addUserWhoCanCreateEvents(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canCreateEvents': FieldValue.arrayUnion([uid]),
    });
  }

  static Future<void> addUserWhoCanAddFiles(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canAddFiles': FieldValue.arrayUnion([uid]),
    });
  }

  static Future<void> removeUserWhoCanCreatePosts(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canCreatePosts': FieldValue.arrayRemove([uid]),
    });
  }

  static Future<void> removeUserWhoCanCreateEvents(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canCreateEvents': FieldValue.arrayRemove([uid]),
    });
  }

  static Future<void> removeUserWhoCanAddFiles(GroupPermissionsModel groupPermissionsModel, String uid) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsModel.id).update({
      'canAddFiles': FieldValue.arrayRemove([uid]),
    });
  }

  static Future<String?> getGroupPermissionsID(String groupID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('groups').doc(groupID).get();
    return GroupModel.fromMap(snap.data(), snap.id).groupPermissionsID;
  }

  static Future<GroupPermissionsModel> getGroupPermissions(String groupPermissionsID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('groups permissions').doc(groupPermissionsID).get();
    return GroupPermissionsModel.fromMap(snap.data(), snap.id);
  }

  ///Group Functions
  static Future<void> createGroup(GroupModel groupModel) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups').doc(groupModel.id).set(groupModel.toMap());
  }

  static Future<GroupModel> getGroup(String groupID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('groups').doc(groupID).get();
    return GroupModel.fromMap(snap.data(), snap.id);
  }

  static Future<List<GroupModel>> getAllGroupsUserCanPostFrom() async {
    final user = await getUserData(FBAuth().getUserID()!);
    final tenant = await getTenant();
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('groups').get();
    final groups =  snap.docs.map((e) => GroupModel.fromMap(e.data(), e.id)).toList();
    List<GroupModel> groupsToReturn = [];
    if(tenant.userRolesThatCanPostInMainFeed.contains(user.userRole)) {
      return groups;
    }
    else {
      await Future.forEach(groups, (GroupModel group) async {
        final permissions = await getGroupPermissions(group.groupPermissionsID!);
        if(permissions.canCreatePosts.contains(user.id)) {
          groupsToReturn.add(group);
        }
      });
      return groupsToReturn;
    }
  }

  static Future<void> setGroupPermissions(String groupID, String groupPermissionsID) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'groupPermissionsID': groupPermissionsID,
        }
    );
  }

  static Future<void> updateGroupInfo(String groupID, String name, String description) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('groups').doc(groupID).update({
      'name': name,
      'description': description,
    });
  }

  static Future<void> setGroupProfilePhoto(String groupID, String imageURL) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'profileImageURL': imageURL,
        }
    );
  }

  static Future<void> setGroupBackgroundPhoto(String groupID, String imageURL) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'backgroundImageURL': imageURL,
        }
    );
  }

  static Future<void> setGroupDescription(String groupID, String description) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'description': description,
        }
    );
  }

  static Future<void> addOwnerToGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'ownerIDs': FieldValue.arrayUnion([uid]),
        }
    );
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'memberIDs': FieldValue.arrayUnion([uid]),
        }
    );
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'followerIDs': FieldValue.arrayUnion([uid]),
        }
    );
    await addGroupUserIsOwnerOf(uid, groupID);
  }

  static Future<void> removeOwnerFromGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'ownerIDs': FieldValue.arrayRemove([uid]),
        }
    );
    await removeGroupUserIsOwnerOf(uid, groupID);
  }

  static Future<void> addMemberToGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'memberIDs': FieldValue.arrayUnion([uid]),
        }
    );
    await addGroupUserIsMemberOf(uid, groupID);
    await removeRequestToJoinGroup(groupID, uid);
  }

  static Future<void> removeMemberFromGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'memberIDs': FieldValue.arrayRemove([uid]),
        }
    );
    await removeGroupUserIsMemberOf(uid, groupID);
  }

  static Future<void> addFollowerToGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'followerIDs': FieldValue.arrayUnion([uid]),
        }
    );
    await removeGroupUserIsFollowing(uid, groupID);
  }

  static Future<void> removeFollowerFromGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'followerIDs': FieldValue.arrayRemove([uid]),
        }
    );
    await removeGroupUserIsFollowing(uid, groupID);
  }

  static Future<void> requestToJoinGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'memberRequestIDs': FieldValue.arrayUnion([uid]),
        }
    );
  }

  static Future<void> removeRequestToJoinGroup(String groupID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'memberRequestIDs': FieldValue.arrayRemove([uid]),
        }
    );
  }

  static Future<void> makeGroupPrivate(String groupID) async {
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'isPrivate': true,
        }
    );
    await _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).update(
        {
          'followerIDS': [],
        }
    );
  }

  ///Comment Functions
  static Future<void> postComment(CommentModel commentModel) async {
    await _database.collection('tenants').doc(tenantID)
        .collection('comments').doc(commentModel.id).set(commentModel.toMap());
    await _database.collection('tenants').doc(tenantID)
        .collection('posts').doc(commentModel.postID).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  ///Poll Functions
  static Future<void> createPoll(PollModel pollModel) => _database.collection('tenants').doc(tenantID)
      .collection('polls').doc(pollModel.id).set(pollModel.toMap());

  static Future<void> updatePoll(PollModel pollModel) => _database.collection('tenants').doc(tenantID)
      .collection('polls').doc(pollModel.id).update(pollModel.toMap());

  ///Post Functions
  static Future<void> createPost(PostModel postModel) => _database.collection('tenants').doc(tenantID)
      .collection('posts').doc(postModel.id).set(postModel.toMap());

  static Future<PostModel> getPost(String postID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('posts').doc(postID).get();
    return PostModel.fromMap(snap.data(), snap.id);
  }

  static Future<void> likePost(String postID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('posts').doc(postID).update(
        {
          'likes': FieldValue.arrayUnion([uid]),
        }
    );
  }

  static Future<void> unlikePost(String postID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('posts').doc(postID).update(
        {
          'likes': FieldValue.arrayRemove([uid]),
        }
    );
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getPostRawData(Tuple5<String?, String?, bool?, bool, SEAUser?> query, DocumentSnapshot? lastVisible) async {
    if(query.item1 != null) {
      if (lastVisible == null) {
        return await _database
            .collection('tenants').doc(tenantID).collection('posts')
            .where('groupID', isEqualTo: query.item1)
            .where('containsMedia', isEqualTo: query.item3)
            .orderBy('postedAt', descending: true)
            .limit(15)
            .get();
      } else {
        return await _database
            .collection('tenants').doc(tenantID).collection('posts')
            .where('groupID', isEqualTo: query.item1)
            .where('containsMedia', isEqualTo: query.item3)
            .orderBy('postedAt', descending: true)
            .startAfter([lastVisible['postedAt']])
            .limit(10)
            .get();
      }
    }
    else {
      if (lastVisible == null) {
        return await _database
            .collection('tenants').doc(tenantID).collection('posts')
            .where('containsMedia', isEqualTo: query.item3)
            .orderBy('postedAt', descending: true)
            .limit(15)
            .get();
      } else {
        return await _database
            .collection('tenants').doc(tenantID).collection('posts')
            .where('containsMedia', isEqualTo: query.item3)
            .orderBy('postedAt', descending: true)
            .startAfter([lastVisible['postedAt']])
            .limit(10)
            .get();
      }
    }
  }

  ///Event Functions
  static Future<void> createEvent(EventModel eventModel) => _database.collection('tenants').doc(tenantID)
      .collection('events').doc(eventModel.id).set(eventModel.toMap());

  static Future<void> updateEvent(EventModel eventModel) => _database.collection('tenants').doc(tenantID)
      .collection('events').doc(eventModel.id).update(eventModel.toMap());

  static Future<void> deleteEvent(String eventID) => _database.collection('tenants').doc(tenantID)
      .collection('events').doc(eventID).delete();

  static Future<EventModel> getEvent(String eventID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('events').doc(eventID).get();
    return EventModel.fromMap(snap.data(), snap.id);
  }

  static Future<void> addUserToEventAttendees(String eventID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('events').doc(eventID).update(
        {
          'isGoingIDs': FieldValue.arrayUnion([uid]),
        }
    );
  }

  static Future<void> removeUserFromEventAttendees(String eventID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('events').doc(eventID).update(
        {
          'isGoingIDs': FieldValue.arrayRemove([uid]),
        }
    );
  }

  static Future<void> addUserToEventNonAttendees(String eventID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('events').doc(eventID).update(
        {
          'isNotGoingIDs': FieldValue.arrayUnion([uid]),
        }
    );
  }

  static Future<void> removeUserFromEventNonAttendees(String eventID, String uid) async {
    await _database.collection('tenants').doc(tenantID).collection('events').doc(eventID).update(
        {
          'isNotGoingIDs': FieldValue.arrayRemove([uid]),
        }
    );
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getEventsRawData(Tuple4<SEAUser?, bool?, String?, String?> query, DocumentSnapshot? lastVisible) async {
    if(query.item3 != null) {
      if (lastVisible == null) {
        return await _database
            .collection('tenants').doc(tenantID).collection('events')
            .where('groupID', isEqualTo: query.item3)
            .where('isGoingIDs', arrayContains: (query.item2 ?? false) ? query.item1!.id : null)
            .where('dateTimeString', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
            .orderBy('dateTimeString')
            .limit(15)
            .get();
      } else {
        return await _database
            .collection('tenants').doc(tenantID).collection('events')
            .where('groupID', isEqualTo: query.item3)
            .where('isGoingIDs', arrayContains: (query.item2 ?? false) ? query.item1!.id : null)
            .where('dateTimeString', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
            .orderBy('dateTimeString')
            .startAfter([lastVisible['id']])
            .limit(5)
            .get();
      }
    }
    else {
      if (lastVisible == null) {
        return await _database
            .collection('tenants').doc(tenantID).collection('events')
            .where('isGoingIDs', arrayContains: (query.item2 ?? false) ? query.item1!.id : null)
            .where('dateTimeString', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
            .orderBy('dateTimeString')
            .limit(15)
            .get();
      } else {
        return await _database
            .collection('tenants').doc(tenantID).collection('events')
            .where('isGoingIDs', arrayContains: (query.item2 ?? false) ? query.item1!.id : null)
            .where('dateTimeString', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
            .orderBy('dateTimeString')
            .startAfter([lastVisible['id']])
            .limit(5)
            .get();
      }
    }
  }

  ///Game Functions
  static Future<void> createGame(GameModel gameModel) => _database.collection('tenants').doc(tenantID)
      .collection('games').doc(gameModel.id).set(gameModel.toMap());

  static Future<GameModel> getGame(String gameID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('games').doc(gameID).get();
    return GameModel.fromMap(snap.data(), snap.id);
  }

  static Future<void> postGameUpdate(GameUpdateModel gameUpdateModel) => _database.collection('tenants').doc(tenantID)
      .collection('game updates').doc(gameUpdateModel.id).set(gameUpdateModel.toMap());

  static Future<void> updateScore(String gameID, int homeScore, int opponentScore) => _database.collection('tenants').doc(tenantID)
      .collection('games').doc(gameID).update(
      {
        'homeTeamScore': homeScore,
        'opposingTeamScore': opponentScore,
      }
  );

  static Future<void> setGameIsDone(String gameID, bool isDone) => _database.collection('tenants').doc(tenantID)
      .collection('games').doc(gameID).update(
      {
        'isMarkedDone': isDone,
      }
  );

  ///Opponent Functions
  static Future<void> createOpponent(OpponentModel opponentModel) => _database.collection('tenants').doc(tenantID)
      .collection('opponents').doc(opponentModel.id).set(opponentModel.toMap());

  static Future<OpponentModel> getOpponent(String opponentID) async {
    final snap = await _database.collection('tenants').doc(tenantID)
        .collection('opponents').doc(opponentID).get();
    return OpponentModel.fromMap(snap.data());
  }

  ///Location Functions
  static Future<void> createLocation(LocationModel locationModel) => _database.collection('tenants').doc(tenantID)
      .collection('locations').doc(locationModel.id).set(locationModel.toMap());

  ///Messaging Functions
  static Future<void> sendMessage(MessageModel messageModel, String conversationID, String conversationCreatorID) async {
    await _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationID).collection('messages').doc(messageModel.id).set(messageModel.toMap());
    await _database.collection('tenants').doc(tenantID).collection('conversations').doc(conversationID).update(
      {
        'lastMessage': getMessageBodyPreview(messageModel),
        'lastMessageDate': messageModel.createdAt,
      }
    );
  }

  static Future<void> createNewConversation(ConversationModel conversationModel) async {
    await _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationModel.id).set(conversationModel.toMap());
  }

  static Future<void> deleteConversation(String conversationID) async {
    final messages = await _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationID).collection('messages').get();
    for (DocumentSnapshot ds in messages.docs){
      ds.reference.delete();
    }
    await _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationID).delete();
  }

  static Future<ConversationModel?> getConversation(String conversationID) async {
    try{
      return await _database.collection('tenants').doc(tenantID).collection('conversations')
          .doc(conversationID).get().then((value) => ConversationModel.fromMap(value.data(), value.id));
    }
    catch (e) {
      return null;
    }
  }

  static Future<ConversationModel?> conversationsAlreadyIn({required String userID, required String recipientID}) async {
    final conversationsBothUsersAreIn = await _database.collection('tenants').doc(tenantID).collection('conversations')
        .where('recipients', isEqualTo: [userID, recipientID])
        .get().then((value) => value.docs.map((e) => ConversationModel.fromMap(e.data(), e.id)));
    return conversationsBothUsersAreIn.isEmpty ? null : conversationsBothUsersAreIn.first;
  }


  ///Streams
  Stream<TenantModel> getTenantStream({required String tenantID}) {
    return _database.collection('tenants').doc(tenantID).snapshots().map((config) {
      return TenantModel.fromMap(config.data(), config.id);
    });
  }

  Stream<List<TenantModel>> tenantsStream() {
    return _database.collection('tenants').snapshots().map((tenant) =>
        tenant.docs.map((e) => TenantModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<List<GroupModel>> groupsStream(GroupQuery query) {
    final uid = FBAuth().getUserID()!;
    switch(query) {
      case GroupQuery.following: {
        return _database.collection('tenants').doc(tenantID).collection('groups').where('followerIDs', arrayContains: uid).where('isPrivate', isEqualTo: false).orderBy('name')
            .snapshots().map((groups) => groups.docs.map((e) => GroupModel.fromMap(e.data(), e.id))
            .where((element) => !element.ownerIDs.contains(uid) && !element.memberIDs.contains(uid) && element.creatorID != uid).toList());
      }
      case GroupQuery.memberOf: {
        return _database.collection('tenants').doc(tenantID).collection('groups').where('memberIDs', arrayContains: uid).orderBy('name').snapshots().map((groups) =>
            groups.docs.map((e) => GroupModel.fromMap(e.data(), e.id)).toList());
      }
      case GroupQuery.all: {
        return _database.collection('tenants').doc(tenantID).collection('groups').orderBy('name').snapshots().map((groups) =>
            groups.docs.map((e) => GroupModel.fromMap(e.data(), e.id)).toList());
      }
    }
  }

  Stream<GroupModel> getGroupStream({required String groupID}) {
    return _database.collection('tenants').doc(tenantID).collection('groups').doc(groupID).snapshots().map((config) {
      return GroupModel.fromMap(config.data(), config.id);
    });
  }

  Stream<GroupPermissionsModel> getGroupPermissionsStream({required String groupPermissionsID}) {
    return _database.collection('tenants').doc(tenantID).collection('groups permissions').doc(groupPermissionsID).snapshots().map((config) {
      return GroupPermissionsModel.fromMap(config.data(), config.id);
    });
  }

  Stream<GameModel> getGameStream({required String gameID}) {
    return _database.collection('tenants').doc(tenantID).collection('games').doc(gameID).snapshots().map((config) {
      return GameModel.fromMap(config.data(), config.id);
    });
  }

  Stream<List<GameModel>> gamesStream({required Tuple3<String, bool, String> query}) {
    if(query.item2) {
      return _database.collection('tenants').doc(tenantID).collection('games').where('groupID', isEqualTo: query.item1)
          .where('dateTimeString', isLessThan: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
          .where('season', isEqualTo: query.item3)
          .snapshots().map((config) => config.docs.map((e) => GameModel.fromMap(e.data(), e.id)).toList());
    }
    return _database.collection('tenants').doc(tenantID).collection('games').where('groupID', isEqualTo: query.item1)
        .where('dateTimeString', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString())
        .where('season', isEqualTo: query.item3)
        .snapshots().map((config) => config.docs.map((e) => GameModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<OpponentModel> getOpponentStream({required String opponentID}) {
    return _database.collection('tenants').doc(tenantID).collection('opponents').doc(opponentID).snapshots().map((config) {
      return OpponentModel.fromMap(config.data());
    });
  }

  Stream<SEAUser> getUserStream({required String uid}) {
    return _database.collection('tenants').doc(tenantID).collection('users').doc(uid).snapshots().map((config) {
      return SEAUser.fromMap(config.data(), config.id);
    });
  }

  Stream<List<SEAUser>> usersStream() {
    return _database.collection('tenants').doc(tenantID).collection('users').snapshots()
        .map((users) => users.docs.map((e) => SEAUser.fromMap(e.data(), e.id)).toList());
  }

  Stream<List<UserSegment>> userSegmentsStream() {
    return _database.collection('tenants').doc(tenantID).collection('user segments').snapshots()
        .map((segments) => segments.docs.map((e) => UserSegment.fromMap(e.data(), e.id)).toList());
  }

  Stream<List<SEAUser>> getManyUsersStream({required List<dynamic> uids}) {
    return _database.collection('tenants').doc(tenantID).collection('users').where('id', whereIn: uids).snapshots()
        .map((users) => users.docs.map((e) => SEAUser.fromMap(e.data(), e.id)).toList());
  }

  Stream<PostModel> getPostStream({required String postID}) {
    return _database.collection('tenants').doc(tenantID).collection('posts').doc(postID).snapshots().map((config) {
      return PostModel.fromMap(config.data(), config.id);
    });
  }

  Stream<List<CommentModel>> getCommentsForPost({required String postID}) {
    return _database.collection('tenants').doc(tenantID).collection('comments').where('postID', isEqualTo: postID).orderBy('postedAt', descending: true).snapshots()
        .map((comments) => comments.docs.map((e) => CommentModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<PollModel> getPollStream({required String pollID}) {
    return _database.collection('tenants').doc(tenantID).collection('polls').doc(pollID).snapshots().map((config) {
      return PollModel.fromMap(config.data(), config.id);
    });
  }

  Stream<List<GameUpdateModel>> getUpdatesForGame({required String gameID}) {
    return _database.collection('tenants').doc(tenantID).collection('game updates').where('gameID', isEqualTo: gameID).orderBy('postedAt', descending: true).snapshots()
        .map((gameUpdates) => gameUpdates.docs.map((e) => GameUpdateModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<EventModel> getEventStream({required String eventID}) {
    return _database.collection('tenants').doc(tenantID).collection('events').doc(eventID).snapshots().map((config) {
      return EventModel.fromMap(config.data(), config.id);
    });
  }

  Stream<List<EventModel>> getTodaysEventsStream() {
    return _database.collection('tenants').doc(tenantID).collection('events').snapshots()
        .map((events) => events.docs.map((e) => EventModel.fromMap(e.data(), e.id))
        .where((element) {
          return isSameDate(DateTime.now(), DateTime.parse(element.dateTimeString));
    }).toList());
  }

  Stream<List<EventModel>> eventsStream({required Tuple4<SEAUser?, bool?, String?, String?> query}) {
    if(query.item3 != null) {
      return _database.collection('tenants').doc(tenantID).collection('events')
          .where('groupID', isEqualTo: query.item3).snapshots()
          .map((events) => events.docs.map((e) => EventModel.fromMap(e.data(), e.id))
          .where((event) {
        if((event.privacyLevel.isVisibleToPublic ?? false)
            || ((event.privacyLevel.isVisibleToFollowers ?? false) && query.item1!.groupsFollowing!.contains(event.groupID))
            || ((event.privacyLevel.isVisibleToMembers ?? false) && query.item1!.groupsMemberOf!.contains(event.groupID))) {
          return true;
        }
        return false;
      }).toList());
    }
    else if(query.item2 ?? false) {
      return _database.collection('tenants').doc(tenantID).collection('events').snapshots()
          .map((events) => events.docs.map((e) => EventModel.fromMap(e.data(), e.id)).toList());
    }
    else {
      return _database.collection('tenants').doc(tenantID).collection('events').snapshots()
          .map((events) => events.docs.map((e) => EventModel.fromMap(e.data(), e.id))
          .where((event) {
        if((event.privacyLevel.isVisibleToPublic ?? false)
            || ((event.privacyLevel.isVisibleToFollowers ?? false) && query.item1!.groupsFollowing!.contains(event.groupID))
            || ((event.privacyLevel.isVisibleToMembers ?? false) && query.item1!.groupsMemberOf!.contains(event.groupID))) {
          return true;
        }
        return false;
      }).toList());
    }
  }

  Stream<List<ConversationModel>> conversationsStream({required String userID}) {
    return _database.collection('tenants').doc(tenantID).collection('conversations')
        .where('isGroupConversation', isEqualTo: false).where('recipients', arrayContains: userID)
        .orderBy('lastMessageDate', descending: true).snapshots().map((conversation) =>
        conversation.docs.map((e) => ConversationModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<List<ConversationModel>> groupConversationsStream({required String userID}) {
    return _database.collection('tenants').doc(tenantID).collection('conversations')
        .where('isGroupConversation', isEqualTo: true).where('recipients', arrayContains: userID)
        .orderBy('lastMessageDate', descending: true).snapshots().map((conversation) =>
        conversation.docs.map((e) => ConversationModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<ConversationModel> getConversationStream({required String conversationID,}) {
    return _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationID).snapshots().map((config) { return ConversationModel.fromMap(config.data(), config.id); });
  }

  Stream<List<MessageModel>> conversationMessagesStream({required String conversationID}) {
    return _database.collection('tenants').doc(tenantID).collection('conversations')
        .doc(conversationID).collection('messages').orderBy('createdAt', descending: true).snapshots().map((messages) => messages.docs.map((e) => MessageModel.fromMap(e.data(), e.id)).toList());
  }

  Stream<List<LocationModel>> groupLocationsStream({required String groupID}) {
    return _database.collection('tenants').doc(tenantID).collection('locations')
        .where('groupID', isEqualTo: groupID).orderBy('name').snapshots().map((locations) =>
        locations.docs.map((e) => LocationModel.fromMap(e.data())).toList());
  }

  Stream<List<LocationModel>> userLocationsStream({required String uid}) {
    return _database.collection('tenants').doc(tenantID).collection('locations')
        .where('creatorID', isEqualTo: uid).orderBy('name').snapshots().map((locations) =>
        locations.docs.map((e) => LocationModel.fromMap(e.data())).toList());
  }



  Stream<List<AlertModel>> alertsStream({required SEAUser user}) {
    return _database.collection('tenants').doc(tenantID).collection('alerts')
        .where('pinned', isEqualTo: true).orderBy('postedAt', descending: true).snapshots().map((alerts) =>
        alerts.docs.map((e) => AlertModel.fromMap(e.data(), e.id)).where((element) {
          if(user.userRole == UserRole.administrator || user.userRole == UserRole.manager) {
            return true;
          }
          else {
            for(var segment in user.userSegmentIDs ?? []) {
              if(element.userSegmentIDs.contains(segment)) {
                return true;
              }
            }
            return false;
          }
        }).toList());
  }

  // Stream<List<PostModel>> postsStream(FeedQuery query) {
  //   final uid = FBAuth().getUserID()!;
  //
  //   if(query.groupID != null) {
  //     return _database.collection('tenants').doc(tenantID).collection('posts').where('groupID', isEqualTo: query.groupID).snapshots().map((posts) =>
  //         posts.docs.map((e) => PostModel.fromMap(e.data(), e.id)).toList());
  //   }
  //   else if(query.following ?? false) {
  //     return _database.collection('tenants').doc(tenantID).collection('posts').where('groupID', whereIn: query.groupID).snapshots().map((posts) =>
  //         posts.docs.map((e) => PostModel.fromMap(e.data(), e.id)).toList());
  //   }
  // }

  // static Future<Note> loadNote(String noteID, String uid) async {
  //   final snapshot = await _database.collection('users').doc(uid).collection('notes').doc(noteID).get();
  //   print(snapshot.data());
  //   // final doc = NotusDocument.fromJson(jsonDecode(snapshot.data()!['data']));
  //   return Note.fromMap(snapshot.data(), noteID);
  // }
  //
  // static Future<void> createUserData(UserModal user) => _database.collection('users').doc(user.id).set(user.toMap());
  //
  // static Future<void> deleteUserData(String userID) async {
  //   var notes = await _database.collection('users').doc(userID).collection('notes').get();
  //   for (var doc in notes.docs) {
  //     await doc.reference.delete();
  //   }
  //   var categories = await _database.collection('users').doc(userID).collection('categories').get();
  //   for (var doc in categories.docs) {
  //     await doc.reference.delete();
  //   }
  //   await _database.collection('users').doc(userID).delete();
  // }
  //
  // static Future<void> setUserFirstName(String newFirstName, String uid) => _database.collection('users').doc(uid).update(
  //     {
  //       'firstName': newFirstName,
  //     }
  // );
  //
  // static Future<void> setUserLastName(String newLastName, String uid) => _database.collection('users').doc(uid).update(
  //     {
  //       'lastName': newLastName,
  //     }
  // );
  //
  // static Future<void> saveNote(Note note, String uid) => _database.collection('users').doc(uid).collection('notes').doc(note.id).set(note.toMap());
  //
  // static Future<void> deleteNote(String noteID, String uid) =>  _database.collection('users').doc(uid).collection('notes').doc(noteID).delete();
  //
  // static Future<void> addCategory(NoteCategory category, String uid) => _database.collection('users').doc(uid).collection('categories').doc(category.id).set(category.toMap());
  //
  // static Future<void> deleteCategory(String categoryID, String uid) async {
  //   _database.collection('users').doc(uid).collection('categories').doc(categoryID).delete();
  //   _database.collection('notes').where('category', isEqualTo: categoryID).get().then((snap) async {
  //     final notes = snap.docs.map((e) => Note.fromMap(e.data(), e.id)).toList();
  //     for(Note n in notes) {
  //       await deleteNote(n.id, uid);
  //     }
  //   });
  // }
  //
  // static Future<void> addNoteToCategory(String categoryID, String noteID, String uid) async {
  //   _database.collection('users').doc(uid).collection('categories').doc(categoryID).update(
  //       {
  //         'notes': FieldValue.arrayUnion([noteID]),
  //       }
  //   );
  //   _database.collection('users').doc(uid).collection('notes').doc(noteID).update(
  //       {
  //         'category': categoryID,
  //       }
  //   );
  // }
  //
  // static Future<int> getNumOfNotesInCategory(String categoryID, String uid) async {
  //   final QuerySnapshot<Map<String, dynamic>> snap;
  //   if(categoryID.isEmpty) {
  //     snap = await _database.collection('users').doc(uid).collection('notes').get();
  //   }
  //   else {
  //     snap = await _database.collection('users').doc(uid).collection('notes').where('category', isEqualTo: categoryID).get();
  //   }
  //   print(uid);
  //   return snap.docs.map((e) => Note.fromMap(e.data(), e.id)).toList().length;
  // }
  //
  // Stream<List<UserModal>> getUserData(String userID) {
  //   return _database.collection('users').where('id', isEqualTo: userID)
  //       .snapshots().map((event) => event.docs.map((user) => UserModal.fromMap(user.data(), user.id)).toList());
  //   // return _database.collection('users').doc(userID).get().asStream().map((user) => UserModal.fromMap(user.data(), user.id));
  // }
  //
  // Stream<List<Note>> getNotesStream({required String uid, String searchQuery = '', String categoryID = ''}) {
  //   if(categoryID != '') {
  //     return _database.collection('users').doc(uid).collection('notes').where('category', isEqualTo: categoryID).snapshots().map((note) =>
  //         note.docs.map((e) => Note.fromMap(e.data(), e.id)).toList());
  //   }
  //   else if(searchQuery != '') {
  //     return _database.collection('users').doc(uid).collection('notes').snapshots().map((note) =>
  //         note.docs.map((e) => Note.fromMap(e.data(), e.id)).where((note) {
  //           if(note.title.toLowerCase().contains(searchQuery.toLowerCase())) {
  //             return true;
  //           }
  //           else if(note.body.toLowerCase().contains(searchQuery.toLowerCase())) {
  //             return true;
  //           }
  //           return false;
  //         }).toList());
  //   }
  //   return _database.collection('users').doc(uid)
  //       .collection('notes').snapshots().map((note) =>
  //       note.docs.map((e) => Note.fromMap(e.data(), e.id)).toList());
  // }
  //
  // Stream<List<NoteCategory>> getCategoriesStream({required String categoryID, required String uid}) {
  //   if(categoryID != '') {
  //     return _database.collection('users').doc(uid).collection('categories').where('id', isEqualTo: categoryID).snapshots().map((category) =>
  //         category.docs.map((e) => NoteCategory.fromMap(e.data(), e.id)).toList());
  //   }
  //   return _database.collection('users').doc(uid).collection('categories').snapshots().map((category) =>
  //       category.docs.map((e) => NoteCategory.fromMap(e.data(), e.id)).toList());
  // }


}