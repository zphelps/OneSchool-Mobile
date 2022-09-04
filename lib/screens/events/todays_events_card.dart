import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import '../../models/EventModel.dart';
import '../../services/routing_helper.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../games/game_details.dart';
import 'event_details.dart';

class TodaysEventsCard extends ConsumerWidget {
  final SEAUser user;
  const TodaysEventsCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysEventsAsyncValue = ref.watch(getTodaysEventsStreamProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMEd').format(DateTime.now()),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Today's Events",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 10),
          todaysEventsAsyncValue.when(
            data: (events) {
              if(events.isEmpty) {
                return SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(
                        'No events found.',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey
                        ),
                      )
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final event = events[index];
                  if(event.gameID != null) {
                    return _buildGameListTile(ref, context, event);
                  }
                  return _buildEventListTile(ref, context, event);
                },
              );
            },
            loading: () => Center(child: PlatformCircularProgressIndicator()),
            error: (_,__) => const Text('Error')
          ),
        ],
      ),
    );
  }

  Widget _buildGameListTile(WidgetRef ref, BuildContext context, EventModel eventModel) {
    final gameAsyncValue = ref.watch(getGameStreamProvider(eventModel.gameID!));
    final groupAsyncValue = ref.watch(getGroupStreamProvider(eventModel.groupID!));
    return gameAsyncValue.when(
        data: (game) {
          final opponentAsyncValue = ref.watch(getOpponentStreamProvider(game.opponentID));
          return InkWell(
            onTap: () => RoutingUtil.pushAsync(context, GameDetails(eventID: eventModel.id, gameID: game.id)),
            child: ZAPListTile(
              contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
              titleSubtitleGap: 3,
              horizontalTitleGap: 8,
              leading: groupAsyncValue.when(
                  data: (group) {
                    return CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(group.profileImageURL),
                      backgroundColor: Colors.transparent,
                    );
                  },
                  loading: () => CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[50],
                  ),
                  error: (_,__) => const Text('Error')
              ),
              title: opponentAsyncValue.when(
                  data: (opponent) {
                    return groupAsyncValue.when(
                        data: (group) {
                          return Text(
                            '${group.name} vs. ${opponent.name}',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                            ),
                          );
                        },
                        loading: () => CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[50],
                        ),
                        error: (_,__) => const Text('Error')
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (e,__) => Text(e.toString())
              ),
              subtitle: Text(
                '${game.isHome ? '@ Home' : 'Away'} • ${DateFormat.jm().format(DateTime.parse(eventModel.dateTimeString))}',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          );
        },
        loading: () => const SizedBox(),
        error: (e,__) => Text(e.toString())
    );
  }

  Widget _buildEventListTile(WidgetRef ref, BuildContext context, EventModel eventModel) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(eventModel.groupID ?? ''));
    final creatorAsyncValue = ref.watch(getUserStreamProvider(eventModel.creatorID));
    return InkWell(
      onTap: () => RoutingUtil.push(context, EventDetails(user: user, eventID: eventModel.id, comingFromGroupProfile: false)),
      child: ZAPListTile(
        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
        // titleSubtitleGap: 1,
        leading: eventModel.groupID != null ? groupAsyncValue.when(
          data: (group) {
            return CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(group.profileImageURL),
              backgroundColor: Colors.transparent,
            );
          },
          loading: () => CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[50],
          ),
          error: (_,__) => const Text('Error')
        ) : creatorAsyncValue.when(
            data: (creator) {
              return CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(creator.profileImageURL),
                backgroundColor: Colors.transparent,
              );
            },
            loading: () => CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[50],
            ),
            error: (_,__) => const Text('Error')
        ),
        horizontalTitleGap: 10,
        title: SizedBox(
          width: getViewportWidth(context) * 0.525,
          child: Text(
            eventModel.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Colors.black
            ),
          ),
        ),
        subtitle: SizedBox(
          width: getViewportWidth(context) * 0.525,
          child: Text(
            eventModel.location.name!,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey
            ),
          ),
        ),
        trailing: SizedBox(
          width: getViewportWidth(context) * 0.225,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateFormat.jm().format(DateTime.parse(eventModel.dateTimeString)),
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

}
