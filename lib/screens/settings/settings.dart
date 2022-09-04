import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/PushNotificationSettingsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/screens/settings/app_configuration/event_preferences.dart';
import 'package:sea/screens/settings/app_configuration/messaging_preferences.dart';
import 'package:sea/screens/settings/app_configuration/moderation.dart';
import 'package:sea/screens/settings/app_configuration/post_preferences.dart';
import 'package:sea/screens/settings/notifications/edit_push_notifications.dart';
import 'package:sea/screens/settings/personal_information/edit_user_phone_number.dart';
import 'package:sea/screens/settings/personal_information/edit_user_profile_photo.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../enums.dart';
import '../../services/fb_auth.dart';
import '../../services/fb_storage.dart';
import '../../services/helpers.dart';
import '../../services/routing_helper.dart';
import '../../widgets/app_bar_circular_action_button.dart';
import '../../widgets/logo_app_bar.dart';
import '../notifications/notifications.dart';
import 'app_configuration/alert_preferences.dart';

class Settings extends StatefulWidget {
  final AppConfiguration prefs;
  final SEAUser user;
  final TenantModel tenantModel;
  const Settings({Key? key, required this.prefs, required this.user, required this.tenantModel}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(getViewportWidth(context), 60),
        child: LogoAppBar(logoURL: widget.prefs.getSchoolLogoURL(), title: 'Settings',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AppBarCircularActionButton(
                onTap: () => RoutingUtil.pushAsync(context, const Notifications()),
                backgroundColor: Colors.grey[200],
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 22,
                ),
                radius: 18,
              ),
            ),
          ], sliverAppBar: false,
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _basicAccountInfoTile(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Text(
                'Personal Information',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            _personalInfoSection(),
            if(widget.user.userRole == UserRole.administrator)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Text(
                      'App Configuration',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _appConfigurationSection(),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Text(
                'Notifications',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            _notificationsSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Text(
                'Additional Resources',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            _additionalResourcesSection(),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Text(
                  'Copyright © 2022 Zach Phelps',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicAccountInfoTile() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          ListTile(
            leading: CircleNetworkImage(
              imageURL: FBStorage.get100x100Image(widget.user.profileImageURL),
              size: const Size(55, 55),
              fit: BoxFit.cover,
            ),
            title: Text(
              '${widget.user.firstName} ${widget.user.lastName}',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              widget.user.email,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[100],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text(
                widget.user.userRole!.name!,
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 11
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData iconData, String label, void Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: 10,
        leading: Icon(
          iconData,
          color: Colors.black,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  Widget _personalInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          _tile(Icons.photo_library_outlined, 'Profile Photo', () => RoutingUtil.pushAsync(context, EditUserProfilePhoto(user: widget.user))),
          _tile(Icons.local_phone_outlined, 'Phone Number', () => RoutingUtil.pushAsync(context, EditUserPhoneNumber(user: widget.user, prefs: widget.prefs))),
          // _tile(Icons.lock_outline, 'Password', () { }),
        ],
      ),
    );
  }

  Widget _appConfigurationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          _tile(Icons.no_adult_content, 'Moderation', () => RoutingUtil.pushAsync(context, Moderation(prefs: widget.prefs, tenantModel: widget.tenantModel))),
          _tile(Icons.post_add_rounded, 'Post Preferences', () => RoutingUtil.pushAsync(context, PostPreferences(tenantModel: widget.tenantModel, prefs: widget.prefs))),
          _tile(Icons.event_outlined, 'Event Preferences', () => RoutingUtil.pushAsync(context, EventPreferences(tenantModel: widget.tenantModel, prefs: widget.prefs))),
          _tile(Icons.notification_important_outlined, 'Alert Preferences', () => RoutingUtil.pushAsync(context, AlertPreferences(tenantModel: widget.tenantModel, prefs: widget.prefs))),
          _tile(Icons.chat_outlined, 'Messaging Preferences', () => RoutingUtil.pushAsync(context, MessagingPreferences(tenantModel: widget.tenantModel, prefs: widget.prefs))),
          // _tile(Icons.lock_outline, 'Password', () { }),
        ],
      ),
    );
  }

  Widget _notificationsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          _tile(Icons.sms_outlined, 'SMS', () { }),
          _tile(Icons.email_outlined, 'Email', () { }),
          _tile(Icons.notifications_none_outlined, 'Push', () => RoutingUtil.pushAsync(context, EditPushNotifications(prefs: widget.prefs, pushNotificationSettingModel: widget.user.pushNotificationSettings))),
        ],
      ),
    );
  }

  Widget _additionalResourcesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          _tile(Icons.help_outline, 'Help Center', () async {
            // final settings = PushNotificationSettingModel(
            //   allowPushNotifications: true,
            //   conversationsMuted: [],
            //   commentsOnPosts: true,
            //   eventAttendingCancelled: true,
            //   eventAttendingDetailsChanged: true,
            //   eventAttendingNewRSVP: true,
            //   gameCancelled: true,
            //   gameDetailsChanged: true,
            //   gameLiveUpdates: true,
            //   likesOnPosts: true,
            //   newEventFromFollowingGroup: true,
            //   newEventFromMemberGroup: true,
            //   newFileFromFollowingGroup: true,
            //   newFileFromMemberGroup: true,
            //   newGroupCreated: true,
            //   newPostFromFollowingGroup: true,
            //   newPostFromMemberGroup: true,
            //   newPublicEvents: true,
            //   newPublicPosts: true,
            // );
            // await FirebaseFirestore.instance.collection('tenants').doc(FBDatabase.tenantID).collection('users')
            //     .doc('hVp9q6M6e7ZTYVgI7nXXoJ428Yg1').update({
            //   'pushNotificationSettings': settings.toMap(),
            // });
          }),
          _tile(Icons.privacy_tip_outlined, 'Privacy Policy', () { }),
          _tile(Icons.verified_outlined, 'Community Standards', () { }),
          _tile(Icons.logout_outlined, 'Log Out', () {
            showPlatformDialog(
              context: context,
              builder: (_) => PlatformAlertDialog(
                title: const Text('Log Out'),
                content: const Text('Are you sure you would like to log out of this account?'),
                actions: <Widget>[
                  PlatformDialogAction(
                    child: PlatformText('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    cupertino: (_,__) => CupertinoDialogActionData(
                      isDefaultAction: true,
                    ),
                  ),
                  PlatformDialogAction(
                    child: PlatformText('Log Out'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await FBAuth().signOut();
                    },
                    cupertino: (_,__) => CupertinoDialogActionData(
                      isDestructiveAction: true,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
