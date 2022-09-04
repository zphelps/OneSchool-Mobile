import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/screens/games/game_details.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';
import 'package:tuple/tuple.dart';

import '../../enums.dart';

class GroupGames extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const GroupGames({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<GroupGames> createState() => _GameListState();
}

class _GameListState extends ConsumerState<GroupGames> {

  late String season;
  late String currentSeason;

  @override
  void initState() {
    super.initState();
    season = getCurrentSeason();
    currentSeason = getCurrentSeason();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                season == currentSeason ? 'Upcoming' : '$season Season',
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft),
                onPressed: () {
                  showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true, context: context, builder: (context) {
                    return Wrap(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Season',
                                style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView(
                                shrinkWrap: true,
                                reverse: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: SeasonExtension.names.values.map((e) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        season = e;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: season == e ? Colors.grey.shade300 : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(
                                        '$e ${e == currentSeason ? '(Current)' : ''}',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  });
                },
                child: Row(
                  children: [
                    Text(
                      season,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0),
        const SizedBox(height: 10),
        GameList(past: season == currentSeason ? false : true, groupModel: widget.groupModel, season: season, scrollable: false),
        const SizedBox(height: 10),
        if(season == currentSeason)
          ZAPButton(
            onPressed: () {
              RoutingUtil.pushAsync(context, Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: Text(
                    'Past Games',
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black
                    ),
                  ),
                ),
                body: GameList(past: true, groupModel: widget.groupModel, season: season, scrollable: true),
              ));
            },
            width: getViewportWidth(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            backgroundColor: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Past Games',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: 18,
                )
              ],
            ),
          ),
      ],
    );
  }
  
  // Widget _buildGamesList(bool past) {
  //   final upcomingGamesAsyncValue = ref.watch(gamesStreamProvider(Tuple3(widget.groupModel.id, past, season)));
  //   return upcomingGamesAsyncValue.when(
  //     data: (games) {
  //       return ListView.separated(
  //         padding: EdgeInsets.zero,
  //         shrinkWrap: true,
  //         primary: false,
  //         physics: const NeverScrollableScrollPhysics(),
  //         separatorBuilder: (context, index) => const Divider(),
  //         itemCount: games.length,
  //         itemBuilder: (context, index) => _gameListTile(games[index]),
  //       );
  //     },
  //     loading: () => const Center(child: CupertinoActivityIndicator()),
  //     error: (e,__) => Text(e.toString()),
  //   );
  // }
  //
  // Widget _gameListTile(GameModel gameModel) {
  //   final opponentAsyncValue = ref.watch(getOpponentStreamProvider(gameModel.opponentID));
  //   return ListTile(
  //     onTap: () => RoutingUtil.pushAsync(context, GameDetails(gameID: gameModel.id, eventID: gameModel.eventID)),
  //     title: opponentAsyncValue.when(
  //       data: (opponent) {
  //         return ZAPListTile(
  //           leading: CircleNetworkImage(
  //             imageURL: opponent.logoURL,
  //             size: const Size(40, 40),
  //             fit: BoxFit.cover,
  //           ),
  //           horizontalTitleGap: 10,
  //           title: Text(
  //             opponent.name,
  //             style: GoogleFonts.inter(
  //               fontWeight: FontWeight.w600,
  //               fontSize: 14,
  //               color: Colors.black,
  //             ),
  //           ),
  //           titleSubtitleGap: 4,
  //           subtitle: Text(
  //             gameModel.isHome ? '@ Home' : 'Away',
  //             style: GoogleFonts.inter(
  //               fontWeight: FontWeight.w500,
  //               fontSize: 13,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         );
  //       },
  //       loading: () => CircleAvatar(backgroundColor: Colors.grey.shade200),
  //       error: (_,__) => const Text('Error')
  //     ),
  //     trailing: SizedBox(
  //       width: getViewportWidth(context) * 0.35,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           const VerticalDivider(width: 35),
  //           Column(
  //             mainAxisSize: MainAxisSize.max,
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             children: [
  //               const Spacer(),
  //               Text(
  //                 DateFormat('MMMEd').format(DateTime.parse(gameModel.dateTimeString)),
  //                 style: GoogleFonts.inter(
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 12,
  //                   color: Colors.grey[600],
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 DateFormat('jm').format(DateTime.parse(gameModel.dateTimeString)),
  //                 style: GoogleFonts.inter(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 12,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               const Spacer(),
  //             ],
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class GameList extends ConsumerWidget {
  final GroupModel groupModel;
  final String season;
  final bool past;
  final bool scrollable;
  const GameList({Key? key, required this.past, required this.season, required this.groupModel, required this.scrollable}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingGamesAsyncValue = ref.watch(gamesStreamProvider(Tuple3(groupModel.id, past, season)));
    return upcomingGamesAsyncValue.when(
      data: (games) {
        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: !scrollable,
          primary: scrollable,
          physics: scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: games.length,
          itemBuilder: (context, index) => _gameListTile(context, ref, games[index]),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e,__) => Text(e.toString()),
    );
  }

  Widget _gameListTile(BuildContext context, WidgetRef ref, GameModel gameModel) {
    final opponentAsyncValue = ref.watch(getOpponentStreamProvider(gameModel.opponentID));
    return ListTile(
      onTap: () => RoutingUtil.pushAsync(context, GameDetails(gameID: gameModel.id, eventID: gameModel.eventID)),
      title: opponentAsyncValue.when(
          data: (opponent) {
            return ZAPListTile(
              leading: CircleNetworkImage(
                imageURL: opponent.logoURL,
                size: const Size(40, 40),
                fit: BoxFit.cover,
              ),
              horizontalTitleGap: 10,
              title: Text(
                opponent.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              titleSubtitleGap: 4,
              subtitle: Text(
                gameModel.isHome ? '@ Home' : 'Away',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loading: () => CircleAvatar(backgroundColor: Colors.grey.shade200),
          error: (_,__) => const Text('Error')
      ),
      trailing: SizedBox(
        width: getViewportWidth(context) * 0.35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const VerticalDivider(width: 35),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  DateFormat('MMMEd').format(DateTime.parse(gameModel.dateTimeString)),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('jm').format(DateTime.parse(gameModel.dateTimeString)),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

