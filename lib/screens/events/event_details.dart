
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/models/LocationModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/create_event.dart';
import 'package:sea/screens/events/event_details_list_tiles.dart';
import 'package:sea/screens/events/events_bloc.dart';
import 'package:sea/screens/events/events_query.dart';
import 'package:sea/screens/group_profile/group_profile.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/SEAUser_search/SEAUser_search.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/widgets/event_attendance_segmented_control.dart';
import 'package:sea/widgets/user_avatar_overlay.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../services/configuration.dart';
import '../../services/fb_database.dart';

class EventDetails extends ConsumerStatefulWidget {
  final String eventID;
  final SEAUser user;
  final bool comingFromGroupProfile;
  const EventDetails({Key? key, required this.eventID, required this.comingFromGroupProfile, required this.user}) : super(key: key);

  @override
  ConsumerState<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends ConsumerState<EventDetails> {

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final eventAsyncValue = ref.watch(getEventStreamProvider(widget.eventID));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Event Details',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          FutureBuilder(
            future: PermissionsManager.canManageEvent(eventID: widget.eventID),
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              if(snap.hasData && snap.data!) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true, context: context, builder: (context) {
                        return Container(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                              color: Colors.white
                          ),
                          child: SizedBox(
                            height: 175,
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  width: 50,
                                  height: 5,
                                ),
                                const SizedBox(height: 8),
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    RoutingUtil.pushAsync(context, CreateEvent(user: widget.user, eventModelIDToEdit: widget.eventID, prefs: prefs));
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.edit_calendar,
                                      color: Colors.black,
                                    ),
                                  ),
                                  title: Text(
                                    'Edit',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    showPlatformDialog(
                                      context: context,
                                      builder: (_) => PlatformAlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text('All event data will be deleted and cannot be recovered.'),
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
                                            child: PlatformText('Delete'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              final event = await FBDatabase.getEvent(widget.eventID);
                                              await PushNotifications.sendCancelledEventNotification(event);
                                              await FBDatabase.deleteEvent(widget.eventID);
                                              ref.watch(eventsProvider).onRefresh(mounted, EventsQuery(user: widget.user));
                                            },
                                            cupertino: (_,__) => CupertinoDialogActionData(
                                              isDestructiveAction: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                  ),
                                  title: Text(
                                    'Delete',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),

        ],
      ),
      body: eventAsyncValue.when(
        data: (event) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 5),
                Text(
                  event.title!,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                if(event.imageURL != null && event.imageURL!.isNotEmpty)
                  _buildEventImage(event.imageURL!),
                const Divider(height: 25),
                EventDetailsListTiles(eventModel: event, prefs: prefs),
                const Divider(height: 35),
                if(userCanRSVP(event, widget.user))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAttendanceSection(event, prefs),
                      const Divider(height: 35),
                    ],
                  ),
                if(event.description != null && event.description!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventAboutSection(event.description!),
                      const Divider(height: 35),
                    ],
                  ),
                _buildEventLocationSection(event.location),
                const Divider(height: 35),
                if(!widget.comingFromGroupProfile && event.groupID != null)
                  _buildHostingGroupSection(event.groupID!, prefs),
              ],
            ),
          );
        },
        loading: () => Center(child: PlatformCircularProgressIndicator()),
        error: (_,__) => const Text('Error'),
      ),
    );
  }

  Widget _buildEventImage(String imageURL) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageURL,
            height: 200,
            fit: BoxFit.fitWidth,
            width: getViewportWidth(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(EventModel eventModel, AppConfiguration prefs) {
    String? text;

    if(eventModel.rsvpPermissions.publicCanRSVP!) {
      text = 'Anyone can RSVP for this event.';
    }
    else if(eventModel.rsvpPermissions.followersCanRSVP!) {
      text = 'Both followers and members of this group can RSVP for this event.';
    }
    else {
      text = 'Only members of this group can RSVP for this event.';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance',
          style: GoogleFonts.inter(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        if(eventModel.isGoingIDs != null && eventModel.isGoingIDs!.isNotEmpty)
          ListTile(
            onTap: () {
              RoutingUtil.pushAsync(context, DefaultTabController(
                length: 2,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.black),
                    title: Text(
                      'Event Attendance',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    bottom: TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      labelColor: prefs.getPrimaryColor(),
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: prefs.getPrimaryColor(),
                      tabs: const [
                        Tab(text: 'Going'),
                        Tab(text: 'Not Going')
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      SEAUserSearch(
                        searchBarPadding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        filter: (user) {
                          return eventModel.isGoingIDs!.contains(user.id);
                        },
                        separator: const Divider(),
                        listTile: (user, notifier) => ListTile(
                          dense: true,
                          leading: CircleNetworkImage(
                            imageURL: user.profileImageURL,
                            fit: BoxFit.cover,
                            size: const Size(50,50),
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      SEAUserSearch(
                        searchBarPadding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        filter: (user) {
                          return eventModel.isNotGoingIDs!.contains(user.id);
                        },
                        separator: const Divider(),
                        listTile: (user, notifier) => ListTile(
                          leading: CircleNetworkImage(
                            imageURL: user.profileImageURL,
                            fit: BoxFit.cover,
                            size: const Size(50,50),
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            },
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            title: UserAvatarOverlay(userIDs: eventModel.isGoingIDs!),
            trailing: SizedBox(
              width: getViewportWidth(context) * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'view all',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        if(eventModel.isGoingIDs == null || eventModel.isGoingIDs!.isEmpty)
          const SizedBox(height: 6),
        EventAttendanceSegmentedControl(eventID: eventModel.id, selectedColor: prefs.getPrimaryColor()),
      ],
    );
  }

  Widget _buildEventAboutSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: GoogleFonts.inter(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEventLocationSection(LocationModel locationModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location${locationModel.isOnline ? ' (Online)' : ''}',
          style: GoogleFonts.inter(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        if(!locationModel.isOnline)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: locationModel.mapStaticImageURL!,
                  height: 200,
                  fit: BoxFit.cover,
                  width: getViewportWidth(context),
                ),
              ),
              ListTile(
                onTap: () {
                  RoutingUtil.pushAsync(context, Scaffold(
                    backgroundColor: Colors.grey.shade100,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      iconTheme: const IconThemeData(color: Colors.black),
                      title: Text(
                        'Location Details',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    body: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              'Name',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                locationModel.name!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          color: Colors.white,
                          child: ListTile(
                            onTap: () {
                              MapsLauncher.launchQuery(locationModel.formattedAddress!);
                            },
                            title: Text(
                              'Address',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                locationModel.formattedAddress ?? locationModel.url!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.map_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              'Notes',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                locationModel.description ?? 'No notes have been added.',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if(locationModel.mapStaticImageURL != null)
                          InkWell(onTap: () {
                            MapsLauncher.launchQuery(locationModel.formattedAddress!);
                          },child: CachedNetworkImage(imageUrl: locationModel.mapStaticImageURL!)),
                      ],
                    ),
                  ));
                },
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                title: Text(
                  locationModel.name!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    locationModel.formattedAddress!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
              ),
            ],
          ),
        if(locationModel.isOnline)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                'This is a virtual event. The link below has been provided to you to access the event.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200,)
                ),
                child: LinkPreviewGenerator(
                  linkPreviewStyle: LinkPreviewStyle.small,
                  link: locationModel.url!,
                  boxShadow: const [],
                  backgroundColor: Colors.white,
                  borderRadius: 10,
                ),
              ),
            ],
          ),

      ],
    );
  }

  Widget _buildHostingGroupSection(String groupID, AppConfiguration prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hosting Group',
          style: GoogleFonts.inter(
            fontSize: 20,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        _hostingGroupInfoCard(groupID, prefs),
      ],
    );
  }

  Widget _hostingGroupInfoCard(String groupID, AppConfiguration prefs) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(groupID));
    return groupAsyncValue.when(
      data: (group) {
        return GestureDetector(
          onTap: () => RoutingUtil.push(context, GroupProfile(user: widget.user, groupID: groupID)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: group.backgroundImageURL ?? group.profileImageURL,
                    width: getViewportWidth(context),
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  group.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.isTeam ? 'Team ' : 'Club ',
                      style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    Text('• ', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 10),),
                    Text(
                      '${group.memberIDs.length} members',
                      style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    group.description!,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                  child: ZAPButton(
                    borderRadius: BorderRadius.circular(6),
                    onPressed: () => RoutingUtil.push(context, GroupProfile(user: widget.user, groupID: groupID)),
                    backgroundColor: prefs.getPrimaryColor().withOpacity(0.1),
                    border: Border.all(color: prefs.getPrimaryColor()),
                    child: Text(
                      'View Group',
                      style: GoogleFonts.inter(color: prefs.getPrimaryColor(), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }
}
