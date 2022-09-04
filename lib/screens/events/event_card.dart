import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/events/events_bloc.dart';
import 'package:sea/screens/games/game_details.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/widgets/event_attendance_segmented_control.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../models/EventModel.dart';
import '../../services/fb_auth.dart';
import '../../services/fb_storage.dart';
import '../../services/providers.dart';
import '../../services/routing_helper.dart';
import '../../widgets/circle_network_image.dart';
import '../../widgets/like_comment_buttons.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../group_profile/group_profile.dart';
import 'event_details.dart';

class EventCard extends ConsumerWidget {
  final EventModel eventModel;
  final bool isMainFeed;
  final String? postID;
  final SEAUser user;
  final AppConfiguration prefs;
  const EventCard({Key? key, required this.eventModel, required this.isMainFeed, this.postID, required this.user, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(eventModel.groupID ?? ''));
    final eventCreatorAsyncValue = ref.watch(getUserStreamProvider(eventModel.creatorID));
    AsyncValue? gameAsyncValue;
    if(eventModel.gameID != null) {
      gameAsyncValue = ref.watch(getGameStreamProvider(eventModel.gameID!));
    }
    String? eventPrivacy;

    if(eventModel.privacyLevel.isVisibleToPublic!) {
      eventPrivacy = 'Public';
    }
    else if(eventModel.privacyLevel.isVisibleToFollowers!) {
      eventPrivacy = 'Restricted';
    }
    else if(eventModel.privacyLevel.isVisibleToMembers!) {
      eventPrivacy = 'Private';
    }

    return GestureDetector(
      onTap: () {
        if(eventModel.gameID != null) {
          RoutingUtil.pushAsync(context, GameDetails(gameID: eventModel.gameID!, eventID: eventModel.id));
        }
        else {
          RoutingUtil.pushAsync(context, EventDetails(user: user, eventID: eventModel.id, comingFromGroupProfile: !isMainFeed));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 0.75),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, //0.35
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, 0),
            )
          ]
        ),
        child: Column(
          children: [
            if(isMainFeed && eventModel.groupID != null)
              groupAsyncValue.when(
                data: (group) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          color: Colors.grey[50],
                        ),
                        child: ZAPListTile(
                          onTap: () {
                            if(isMainFeed && eventModel.groupID != null) {
                              RoutingUtil.push(context, GroupProfile(user: user, groupID: group.id));
                            }
                          },
                          horizontalTitleGap: 8,
                          titleSubtitleGap: 1,
                          contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 6),
                          leading: CircleNetworkImage(fit: BoxFit.cover, size: const Size(20, 20), imageURL: FBStorage.get100x100Image(group.profileImageURL)),
                          title: Text(
                            group.name,
                            style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      const Divider(height: 0)
                    ],
                  );
                },
                loading: () => const SizedBox(height: 25),
                error: (_,__) => const Text('Error'),
              ),
            if(isMainFeed && eventModel.groupID == null)
              eventCreatorAsyncValue.when(
                data: (creator) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          color: Colors.grey[50],
                        ),
                        child: ZAPListTile(
                          onTap: () {},
                          horizontalTitleGap: 8,
                          titleSubtitleGap: 1,
                          contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 6),
                          leading: CircleNetworkImage(fit: BoxFit.cover, size: const Size(20, 20), imageURL: FBStorage.get100x100Image(creator.profileImageURL)),
                          title: Text(
                            '${creator.firstName} ${creator.lastName}',
                            style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
                      const Divider(height: 0)
                    ],
                  );
                },
                loading: () => const SizedBox(height: 25),
                error: (_,__) => const Text('Error'),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, isMainFeed ? 10 : 15, 15, isMainFeed ? 0 : 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildDateTimeChip(eventModel),
                  if(eventModel.gameID == null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: SizedBox(
                              width: getViewportWidth(context) * 0.55,
                              child: Text(
                                eventModel.title!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // titleSubtitleGap: 4,
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        color: Colors.grey[600],
                                        size: 12
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${eventPrivacy!} ',
                                        style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 13),
                                      ),
                                      Text('|', style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 10),),
                                      const SizedBox(width: 3),
                                      Icon(
                                        eventModel.location.isOnline ? Icons.language : Icons.location_on_outlined,
                                        color: Colors.grey[600],
                                        size: 13,
                                      ),
                                      Text(
                                        ' ${eventModel.location.isOnline ? 'Online' : 'In-Person'}',
                                        style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if(!userCanRSVP(eventModel, user))
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Divider(height: 10),
                                        Text(
                                          '${eventModel.location.isOnline ? eventModel.location.url : eventModel.location.formattedAddress}',
                                          maxLines: 2,
                                          style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if(userCanRSVP(eventModel, user))
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 0),
                              child: EventAttendanceSegmentedControl(eventID: eventModel.id, selectedColor: prefs.getPrimaryColor()),
                            ),
                        ],
                      ),
                    ),
                  if(eventModel.gameID != null)
                    gameAsyncValue!.when(
                      data: (game) {
                        final opponentAsyncValue = ref.watch(getOpponentStreamProvider(game.opponentID));
                        return Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(left: 10),
                            title: opponentAsyncValue.when(
                                data: (opponent) {
                                  return ZAPListTile(
                                    contentPadding: const EdgeInsets.only(top: 8),
                                    leading: CircleNetworkImage(
                                      imageURL: opponent.logoURL,
                                      size: const Size(35, 35),
                                      fit: BoxFit.cover,
                                    ),
                                    horizontalTitleGap: 10,
                                    title: Text(
                                      opponent.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    titleSubtitleGap: 1,
                                    subtitle: Text(
                                      game.isHome ? '@ Home' : '@ Away',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  );
                                },
                                loading: () => CircleAvatar(backgroundColor: Colors.grey.shade200),
                                error: (_,__) => const Text('Error')
                            ),
                            subtitle: Column(
                              children: [
                                const SizedBox(height: 3),
                                const Divider(height: 10),
                                Text(
                                  '${eventModel.location.isOnline ? eventModel.location.url : eventModel.location.formattedAddress}',
                                  maxLines: 2,
                                  style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 13),
                                ),
                              ],
                            ),
                            // subtitle: Padding(
                            //   padding: const EdgeInsets.only(top: 10),
                            //   child: ZAPButton(
                            //     onPressed: () {},
                            //     padding: const EdgeInsets.symmetric(vertical: 6),
                            //     borderRadius: BorderRadius.circular(8),
                            //     backgroundColor: prefs.getPrimaryColor(),
                            //     child: Text(
                            //       'Buy Tickets',
                            //       style: GoogleFonts.inter(
                            //         fontWeight: FontWeight.w600,
                            //         color: Colors.white,
                            //         fontSize: 13,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(),
                      error: (_,__) => const Text('Error'),
                    ),
                ],
              ),
            ),
            if(isMainFeed && postID != null)
              Column(
                children: [
                  const Divider(height: 18),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                    child: LikeCommentButtons(postID: postID!),
                  ),
                ],
              ),
            if(isMainFeed && postID == null)
              const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeChip(EventModel eventModel) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      width: 80,
      height: 90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEE').format(DateTime.parse(eventModel.dateTimeString)).toUpperCase(),
            style: GoogleFonts.inter(
              color: prefs.getPrimaryColor(),
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.3
            ),
          ),
          Text(
            DateFormat('d').format(DateTime.parse(eventModel.dateTimeString)),
            style: GoogleFonts.inter(
              color: Colors.black,
              height: 1.25,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          Text(
            DateFormat('MMM').format(DateTime.parse(eventModel.dateTimeString)).toUpperCase(),
            style: GoogleFonts.inter(
              height: 0.8,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          Container(margin: const EdgeInsets.symmetric(vertical: 3), color: Colors.grey[300], height: 0.5, width: 40,),
          Text(
            DateFormat('jm').format(DateTime.parse(eventModel.dateTimeString)).toUpperCase(),
            style: GoogleFonts.inter(
              height: 1.2,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildEventAttendanceSegmentedControl(WidgetRef ref, String eventID) {
  //   final uid = FBAuth().getUserID()!;
  //
  //   final eventAsyncValue = ref.watch(getEventStreamProvider(eventID));
  //
  //   return eventAsyncValue.when(
  //     data: (event) {
  //       bool? isGoing;
  //
  //       if(event.isGoingIDs!.contains(uid)) {
  //         isGoing = true;
  //       }
  //       else if(event.isNotGoingIDs!.contains(uid)) {
  //         isGoing = false;
  //       }
  //       return Row(
  //         children: [
  //           Expanded(
  //             child: ZAPButton(
  //               padding: const EdgeInsets.symmetric(vertical: 6),
  //               borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
  //               border: Border.all(color: isGoing == null || !isGoing ? Colors.grey.shade300 : Colors.blue),
  //               backgroundColor: isGoing == null || !isGoing ? Colors.white : Colors.blue,
  //               onPressed: () async {
  //                 HapticFeedback.mediumImpact();
  //                 if(isGoing != null && isGoing) {
  //                   await FBDatabase.removeUserFromEventAttendees(event.id, uid);
  //                 }
  //                 else {
  //                   await FBDatabase.addUserToEventAttendees(event.id, uid);
  //                   await FBDatabase.removeUserFromEventNonAttendees(event.id, uid);
  //                 }
  //               },
  //               child: Text(
  //                 'Going',
  //                 style: GoogleFonts.inter(
  //                     color: isGoing == null || !isGoing ? Colors.grey[500] : Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 11
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: ZAPButton(
  //               padding: const EdgeInsets.symmetric(vertical: 6),
  //               borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
  //               border: Border.all(color: isGoing == null || isGoing ? Colors.grey.shade300 : Colors.blue),
  //               backgroundColor: isGoing == null || isGoing ? Colors.white : Colors.blue,
  //               onPressed: () async {
  //                 HapticFeedback.mediumImpact();
  //                 if(isGoing != null && !isGoing) {
  //                   await FBDatabase.removeUserFromEventNonAttendees(event.id, uid);
  //                 }
  //                 else {
  //                   await FBDatabase.addUserToEventNonAttendees(event.id, uid);
  //                   await FBDatabase.removeUserFromEventAttendees(event.id, uid);
  //                 }
  //               },
  //               child: Text(
  //                 'Not Going',
  //                 style: GoogleFonts.inter(
  //                     color: isGoing == null || isGoing ? Colors.grey[500] : Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 11
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //     loading: () => const SizedBox(),
  //     error: (_,__) => const Text('Error'),
  //   );
  // }
}
