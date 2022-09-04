import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/AlertModel.dart';
import 'package:sea/models/CommentModel.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GameUpdateModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/LocationModel.dart';
import 'package:sea/models/MessageModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/models/PollModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/models/UserSegment.dart';
import 'package:sea/screens/groups/groups.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:tuple/tuple.dart';

import 'fb_database.dart';
import 'fb_messaging.dart';

final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>(
        (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FBDatabase>((ref) {
  // final auth = ref.watch(authStateChangesProvider);

  // if (auth.asData?.value?.uid != null) {
  //   return FBDatabase();
  // }
  // throw UnimplementedError();

  return FBDatabase();
});

final tenantStreamProvider = StreamProvider.autoDispose.family<TenantModel, String>((ref, tenantID) {
  final database = ref.watch(databaseProvider);
  return database.getTenantStream(tenantID: tenantID);
});

final allTenantsStreamProvider = StreamProvider.autoDispose<List<TenantModel>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.tenantsStream();
});

final userSegmentsStreamProvider = StreamProvider.autoDispose<List<UserSegment>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.userSegmentsStream();
});

final groupsStreamProvider = StreamProvider.autoDispose.family<List<GroupModel>, GroupQuery>((ref, query) {
  final database = ref.watch(databaseProvider);
  return database.groupsStream(query);
});

final getGroupStreamProvider = StreamProvider.autoDispose.family<GroupModel, String>((ref, groupID) {
  final database = ref.watch(databaseProvider);
  return database.getGroupStream(groupID: groupID);
});

final getGroupPermissionsStreamProvider = StreamProvider.autoDispose.family<GroupPermissionsModel, String>((ref, groupPermissionsID) {
  final database = ref.watch(databaseProvider);
  return database.getGroupPermissionsStream(groupPermissionsID: groupPermissionsID);
});

final getGameStreamProvider = StreamProvider.autoDispose.family<GameModel, String>((ref, gameID) {
  final database = ref.watch(databaseProvider);
  return database.getGameStream(gameID: gameID);
});

final gamesStreamProvider = StreamProvider.autoDispose.family<List<GameModel>, Tuple3<String, bool, String>>((ref, query) {
  final database = ref.watch(databaseProvider);
  return database.gamesStream(query: query);
});

final getPollStreamProvider = StreamProvider.autoDispose.family<PollModel, String>((ref, pollID) {
  final database = ref.watch(databaseProvider);
  return database.getPollStream(pollID: pollID);
});

final getOpponentStreamProvider = StreamProvider.autoDispose.family<OpponentModel, String>((ref, opponentID) {
  final database = ref.watch(databaseProvider);
  return database.getOpponentStream(opponentID: opponentID);
});

final getUserStreamProvider = StreamProvider.autoDispose.family<SEAUser, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.getUserStream(uid: uid);
});

final usersStreamProvider = StreamProvider.autoDispose<List<SEAUser>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.usersStream();
});

final getManyUsersStreamProvider = StreamProvider.autoDispose.family<List<SEAUser>, List<dynamic>>((ref, uids) {
  final database = ref.watch(databaseProvider);
  return database.getManyUsersStream(uids: uids);
});

final getPostStreamProvider = StreamProvider.autoDispose.family<PostModel, String>((ref, postID) {
  final database = ref.watch(databaseProvider);
  return database.getPostStream(postID: postID);
});

final getPostCommentsStreamProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, postID) {
  final database = ref.watch(databaseProvider);
  return database.getCommentsForPost(postID: postID);
});

final getGameUpdatesStreamProvider = StreamProvider.autoDispose.family<List<GameUpdateModel>, String>((ref, gameID) {
  final database = ref.watch(databaseProvider);
  return database.getUpdatesForGame(gameID: gameID);
});

final eventsStreamProvider = StreamProvider.autoDispose.family<List<EventModel>, Tuple4<SEAUser?, bool?, String?, String?>>((ref, query) {
  final database = ref.watch(databaseProvider);
  return database.eventsStream(query: query);
});

final getTodaysEventsStreamProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getTodaysEventsStream();
});

final getEventStreamProvider = StreamProvider.autoDispose.family<EventModel, String>((ref, eventID) {
  final database = ref.watch(databaseProvider);
  return database.getEventStream(eventID: eventID);
});

final conversationsStreamProvider = StreamProvider.autoDispose.family<List<ConversationModel>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.conversationsStream(userID: uid);
});

final groupConversationsStreamProvider = StreamProvider.autoDispose.family<List<ConversationModel>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.groupConversationsStream(userID: uid);
});

final groupLocationsStreamProvider = StreamProvider.autoDispose.family<List<LocationModel>, String>((ref, groupID) {
  final database = ref.watch(databaseProvider);
  return database.groupLocationsStream(groupID: groupID);
});

final userLocationsStreamProvider = StreamProvider.autoDispose.family<List<LocationModel>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.userLocationsStream(uid: uid);
});

final getConversationStreamProvider = StreamProvider.autoDispose.family<ConversationModel, String>((ref, conversationID) {
  final database = ref.watch(databaseProvider);
  return database.getConversationStream(conversationID: conversationID);
});

final conversationMessagesStreamProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, conversationID) {
  final database = ref.watch(databaseProvider);
  return database.conversationMessagesStream(conversationID: conversationID);
});

final alertsStreamProvider = StreamProvider.autoDispose.family<List<AlertModel>, Tuple2<SEAUser, bool>>((ref, alertQuery) {
  final database = ref.watch(databaseProvider);
  return database.alertsStream(user: alertQuery.item1);
});

final fcmTokenStreamProvider = StreamProvider.autoDispose((ref) {
  return FBMessaging.firebaseMessaging.getToken().asStream();
});