import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/PushNotificationSettingsModel.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';

import '../../../services/fb_database.dart';

class EditPushNotifications extends StatefulWidget {
  final AppConfiguration prefs;
  final PushNotificationSettingModel pushNotificationSettingModel;
  const EditPushNotifications({Key? key, required this.prefs, required this.pushNotificationSettingModel}) : super(key: key);

  @override
  State<EditPushNotifications> createState() => _EditPushNotificationsState();
}

class _EditPushNotificationsState extends State<EditPushNotifications> {

  late bool allowPushNotifications;

  //GENERAL
  late bool likesOnPosts;
  late bool commentsOnPosts;
  late bool newPublicPosts;
  late bool newPublicEvents;
  late bool newGroupCreated;

  //GROUPS MEMBER OF
  late bool newPostFromMemberGroup;
  late bool newEventFromMemberGroup;
  late bool newFileFromMemberGroup;

  //GROUPS FOLLOWING
  late bool newPostFromFollowingGroup;
  late bool newEventFromFollowingGroup;
  late bool newFileFromFollowingGroup;

  //EVENTS ATTENDING
  late bool eventAttendingDetailsChanged;
  late bool eventAttendingCancelled;
  late bool eventAttendingNewRSVP;

  //GAMES
  late bool gameLiveUpdates;
  late bool gameDetailsChanged;
  late bool gameCancelled;

  @override
  void initState() {
    super.initState();
    allowPushNotifications = widget.pushNotificationSettingModel.allowPushNotifications;
    likesOnPosts = widget.pushNotificationSettingModel.likesOnPosts;
    commentsOnPosts = widget.pushNotificationSettingModel.commentsOnPosts;
    newPublicPosts = widget.pushNotificationSettingModel.newPublicPosts;
    newPublicEvents = widget.pushNotificationSettingModel.newPublicEvents;
    newGroupCreated = widget.pushNotificationSettingModel.newGroupCreated;

    newPostFromMemberGroup = widget.pushNotificationSettingModel.newPostFromMemberGroup;
    newEventFromMemberGroup = widget.pushNotificationSettingModel.newEventFromMemberGroup;
    newFileFromMemberGroup = widget.pushNotificationSettingModel.newFileFromMemberGroup;

    newPostFromFollowingGroup = widget.pushNotificationSettingModel.newPostFromFollowingGroup;
    newEventFromFollowingGroup = widget.pushNotificationSettingModel.newEventFromFollowingGroup;
    newFileFromFollowingGroup = widget.pushNotificationSettingModel.newFileFromFollowingGroup;

    eventAttendingDetailsChanged = widget.pushNotificationSettingModel.eventAttendingDetailsChanged;
    eventAttendingCancelled = widget.pushNotificationSettingModel.eventAttendingCancelled;
    eventAttendingNewRSVP = widget.pushNotificationSettingModel.eventAttendingNewRSVP;

    gameLiveUpdates = widget.pushNotificationSettingModel.gameLiveUpdates;
    gameDetailsChanged = widget.pushNotificationSettingModel.gameDetailsChanged;
    gameCancelled = widget.pushNotificationSettingModel.gameCancelled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Push Notifications',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  _tile('Allow Push Notifications', allowPushNotifications, (value) async {
                    setState(() {
                      allowPushNotifications = value;
                    });
                    await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'allowPushNotifications', value);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Please note that your notification preferences might be overridden to communicate urgent information.',
                      style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            !allowPushNotifications ? const SizedBox(height: 10) : SizedBox(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'General',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _tile('Likes on your posts', likesOnPosts, (value) async {
                          setState(() {
                            likesOnPosts = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'likesOnPosts', value);
                        }),
                        _tile('Comments on your posts', commentsOnPosts, (value) async {
                          setState(() {
                            commentsOnPosts = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'commentsOnPosts', value);
                        }),
                        _tile('New public posts', newPublicPosts, (value) async {
                          setState(() {
                            newPublicPosts = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newPublicPosts', value);
                        }),
                        _tile('New public events', newPublicEvents, (value) async {
                          setState(() {
                            newPublicEvents = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newPublicEvents', value);
                        }),
                        _tile('New group created', newGroupCreated, (value) async {
                          setState(() {
                            newGroupCreated = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newGroupCreated', value);
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Groups Member Of',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _tile('New post', newPostFromMemberGroup, (value) async {
                          setState(() {
                            newPostFromMemberGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newPostFromMemberGroup', value);
                        }),
                        _tile('New event', newEventFromMemberGroup, (value) async {
                          setState(() {
                            newEventFromMemberGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newEventFromMemberGroup', value);
                        }),
                        _tile('New file', newFileFromMemberGroup, (value) async {
                          setState(() {
                            newFileFromMemberGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newFileFromMemberGroup', value);
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Groups Following',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _tile('New post', newPostFromFollowingGroup, (value) async {
                          setState(() {
                            newPostFromFollowingGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newPostFromFollowingGroup', value);
                        }),
                        _tile('New event', newEventFromFollowingGroup, (value) async {
                          setState(() {
                            newEventFromFollowingGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newEventFromFollowingGroup', value);
                        }),
                        _tile('New file', newFileFromFollowingGroup, (value) async {
                          setState(() {
                            newFileFromFollowingGroup = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'newFileFromFollowingGroup', value);
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Events Attending',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _tile('Details changed', eventAttendingDetailsChanged, (value) async {
                          setState(() {
                            eventAttendingDetailsChanged = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'eventAttendingDetailsChanged', value);
                        }),
                        _tile('Cancelled', eventAttendingCancelled, (value) async {
                          setState(() {
                            eventAttendingCancelled = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'eventAttendingCancelled', value);
                        }),
                        _tile('New RSVP', eventAttendingNewRSVP, (value) async {
                          setState(() {
                            eventAttendingNewRSVP = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'eventAttendingNewRSVP', value);
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Games',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _tile('Live update', gameLiveUpdates, (value) async {
                          setState(() {
                            gameLiveUpdates = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'gameLiveUpdates', value);
                        }),
                        _tile('Details changed', gameDetailsChanged, (value) async {
                          setState(() {
                            gameDetailsChanged = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'gameDetailsChanged', value);
                        }),
                        _tile('Cancelled', gameCancelled, (value) async {
                          setState(() {
                            gameCancelled = value;
                          });
                          await FBDatabase.updatePushNotificationSetting(FBAuth().getUserID()!, 'gameCancelled', value);
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, bool selection, void Function(bool) onChanged) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 16
        ),
      ),
      trailing: CupertinoSwitch(
        activeColor: widget.prefs.getPrimaryColor(),
        value: selection,
        onChanged: onChanged,
      ),
    );
  }
}
