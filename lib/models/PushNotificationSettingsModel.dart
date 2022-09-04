
import 'package:equatable/equatable.dart';

class PushNotificationSettingModel extends Equatable {
  final bool allowPushNotifications;
  final List<dynamic> conversationsMuted;

  //GENERAL
  final bool likesOnPosts;
  final bool commentsOnPosts;
  final bool newPublicPosts;
  final bool newPublicEvents;
  final bool newGroupCreated;

  //GROUPS MEMBER OF
  final bool newPostFromMemberGroup;
  final bool newEventFromMemberGroup;
  final bool newFileFromMemberGroup;

  //GROUPS FOLLOWING
  final bool newPostFromFollowingGroup;
  final bool newEventFromFollowingGroup;
  final bool newFileFromFollowingGroup;

  //EVENTS ATTENDING
  final bool eventAttendingDetailsChanged;
  final bool eventAttendingCancelled;
  final bool eventAttendingNewRSVP;

  //GAMES
  final bool gameLiveUpdates;
  final bool gameDetailsChanged;
  final bool gameCancelled;

  PushNotificationSettingModel({
    required this.allowPushNotifications,
    required this.conversationsMuted,

    required this.likesOnPosts,
    required this.commentsOnPosts,
    required this.newPublicPosts,
    required this.newPublicEvents,
    required this.newGroupCreated,

    required this.newPostFromMemberGroup,
    required this.newEventFromMemberGroup,
    required this.newFileFromMemberGroup,

    required this.newPostFromFollowingGroup,
    required this.newEventFromFollowingGroup,
    required this.newFileFromFollowingGroup,

    required this.eventAttendingDetailsChanged,
    required this.eventAttendingCancelled,
    required this.eventAttendingNewRSVP,

    required this.gameLiveUpdates,
    required this.gameDetailsChanged,
    required this.gameCancelled,
  });

  @override
  List<dynamic> get props => [
    allowPushNotifications,
    conversationsMuted,

    likesOnPosts,
    commentsOnPosts,
    newPublicPosts,
    newPublicEvents,
    newGroupCreated,

    newPostFromMemberGroup,
    newEventFromMemberGroup,
    newFileFromMemberGroup,

    newPostFromFollowingGroup,
    newEventFromFollowingGroup,
    newFileFromFollowingGroup,

    eventAttendingDetailsChanged,
    eventAttendingCancelled,
    eventAttendingNewRSVP,

    gameLiveUpdates,
    gameDetailsChanged,
    gameCancelled,
  ];

  @override
  bool get stringify => true;

  factory PushNotificationSettingModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for push notification settings model');
    }
    final allowPushNotifications = data['allowPushNotifications'] as bool?;
    if (allowPushNotifications == null) {
      throw StateError('missing allowPushNotifications for PushNotificationSetting model');
    }
    final conversationsMuted = data['conversationsMuted'] as List<dynamic>?;
    if (conversationsMuted == null) {
      throw StateError('missing conversationsMuted for PushNotificationSetting model');
    }


    final likesOnPosts = data['likesOnPosts'] as bool?;
    if (likesOnPosts == null) {
      throw StateError('missing likesOnPosts for PushNotificationSetting model');
    }
    final commentsOnPosts = data['commentsOnPosts'] as bool?;
    if (commentsOnPosts == null) {
      throw StateError('missing commentsOnPosts for PushNotificationSetting model');
    }
    final newPublicPosts = data['newPublicPosts'] as bool?;
    if (newPublicPosts == null) {
      throw StateError('missing newPublicPosts for PushNotificationSetting model');
    }
    final newPublicEvents = data['newPublicEvents'] as bool?;
    if (newPublicEvents == null) {
      throw StateError('missing newPublicEvents for PushNotificationSetting model');
    }
    final newGroupCreated = data['newGroupCreated'] as bool?;
    if (newGroupCreated == null) {
      throw StateError('missing newGroupCreated for PushNotificationSetting model');
    }


    final newPostFromMemberGroup = data['newPostFromMemberGroup'] as bool?;
    if (newPostFromMemberGroup == null) {
      throw StateError('missing newPostFromMemberGroup for PushNotificationSetting model');
    }
    final newEventFromMemberGroup = data['newEventFromMemberGroup'] as bool?;
    if (newEventFromMemberGroup == null) {
      throw StateError('missing newEventFromMemberGroup for PushNotificationSetting model');
    }
    final newFileFromMemberGroup = data['newFileFromMemberGroup'] as bool?;
    if (newFileFromMemberGroup == null) {
      throw StateError('missing newFileFromMemberGroup for PushNotificationSetting model');
    }


    final newPostFromFollowingGroup = data['newPostFromFollowingGroup'] as bool?;
    if (newPostFromFollowingGroup == null) {
      throw StateError('missing newPostFromFollowingGroup for PushNotificationSetting model');
    }
    final newEventFromFollowingGroup = data['newEventFromFollowingGroup'] as bool?;
    if (newEventFromFollowingGroup == null) {
      throw StateError('missing newEventFromFollowingGroup for PushNotificationSetting model');
    }
    final newFileFromFollowingGroup = data['newFileFromFollowingGroup'] as bool?;
    if (newFileFromFollowingGroup == null) {
      throw StateError('missing newFileFromFollowingGroup for PushNotificationSetting model');
    }


    final eventAttendingDetailsChanged = data['eventAttendingDetailsChanged'] as bool?;
    if (eventAttendingDetailsChanged == null) {
      throw StateError('missing eventAttendingDetailsChanged for PushNotificationSetting model');
    }
    final eventAttendingCancelled = data['eventAttendingCancelled'] as bool?;
    if (eventAttendingCancelled == null) {
      throw StateError('missing eventAttendingCancelled for PushNotificationSetting model');
    }
    final eventAttendingNewRSVP = data['eventAttendingNewRSVP'] as bool?;
    if (eventAttendingNewRSVP == null) {
      throw StateError('missing eventAttendingNewRSVP for PushNotificationSetting model');
    }


    final gameLiveUpdates = data['gameLiveUpdates'] as bool?;
    if (gameLiveUpdates == null) {
      throw StateError('missing gameLiveUpdates for PushNotificationSetting model');
    }
    final gameDetailsChanged = data['gameDetailsChanged'] as bool?;
    if (gameDetailsChanged == null) {
      throw StateError('missing gameDetailsChanged for PushNotificationSetting model');
    }
    final gameCancelled = data['gameCancelled'] as bool?;
    if (gameCancelled == null) {
      throw StateError('missing gameCancelled for PushNotificationSetting model');
    }

    return PushNotificationSettingModel(
      allowPushNotifications: allowPushNotifications,
      conversationsMuted: conversationsMuted,

      likesOnPosts: likesOnPosts,
      commentsOnPosts: commentsOnPosts,
      newPublicPosts: newPublicPosts,
      newPublicEvents: newPublicEvents,
      newGroupCreated: newGroupCreated,

      newPostFromMemberGroup: newPostFromMemberGroup,
      newEventFromMemberGroup: newEventFromMemberGroup,
      newFileFromMemberGroup: newFileFromMemberGroup,

      newPostFromFollowingGroup: newPostFromFollowingGroup,
      newEventFromFollowingGroup: newEventFromFollowingGroup,
      newFileFromFollowingGroup: newFileFromFollowingGroup,

      eventAttendingDetailsChanged: eventAttendingDetailsChanged,
      eventAttendingCancelled: eventAttendingCancelled,
      eventAttendingNewRSVP: eventAttendingNewRSVP,

      gameLiveUpdates: gameLiveUpdates,
      gameDetailsChanged: gameDetailsChanged,
      gameCancelled: gameCancelled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowPushNotifications': allowPushNotifications,
      'conversationsMuted': conversationsMuted,

      'likesOnPosts': likesOnPosts,
      'commentsOnPosts': commentsOnPosts,
      'newPublicPosts': newPublicPosts,
      'newPublicEvents': newPublicEvents,
      'newGroupCreated': newGroupCreated,

      'newPostFromMemberGroup': newPostFromMemberGroup,
      'newEventFromMemberGroup': newEventFromMemberGroup,
      'newFileFromMemberGroup': newFileFromMemberGroup,

      'newPostFromFollowingGroup': newPostFromFollowingGroup,
      'newEventFromFollowingGroup': newEventFromFollowingGroup,
      'newFileFromFollowingGroup': newFileFromFollowingGroup,

      'eventAttendingDetailsChanged': eventAttendingDetailsChanged,
      'eventAttendingCancelled': eventAttendingCancelled,
      'eventAttendingNewRSVP': eventAttendingNewRSVP,

      'gameLiveUpdates': gameLiveUpdates,
      'gameDetailsChanged': gameDetailsChanged,
      'gameCancelled': gameCancelled,
    };
  }

}