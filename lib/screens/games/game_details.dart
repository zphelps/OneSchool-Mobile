import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GameUpdateModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/screens/games/report_score.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:uuid/uuid.dart';

import '../../models/EventModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_database.dart';
import '../../services/routing_helper.dart';
import '../../widgets/event_attendance_segmented_control.dart';
import '../../widgets/user_avatar_overlay.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../../zap_widgets/zap_button.dart';

class GameDetails extends ConsumerStatefulWidget {
  final String gameID;
  final String eventID;
  const GameDetails({Key? key,required this.gameID, required this.eventID}) : super(key: key);

  @override
  ConsumerState<GameDetails> createState() => _GameDetailsState();
}

class _GameDetailsState extends ConsumerState<GameDetails> {

  final _gameUpdateController = TextEditingController();
  String? gameUpdateText;

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final eventAsyncValue = ref.watch(getEventStreamProvider(widget.eventID));
    final gameAsyncValue = ref.watch(getGameStreamProvider(widget.gameID));
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return eventAsyncValue.when(
      data: (event) {
        return gameAsyncValue.when(
            data: (game) {
              final opponentAsyncValue = ref.watch(getOpponentStreamProvider(game.opponentID));
              return opponentAsyncValue.when(
                  data: (opponent) {
                    final groupAsyncValue = ref.watch(getGroupStreamProvider(event.groupID!));
                    return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        toolbarHeight: 40,
                        elevation: 0,
                        backgroundColor: Colors.white,
                        iconTheme: const IconThemeData(color: Colors.black),
                        title: groupAsyncValue.when(
                            data: (group) => Text(
                              '${group.name} vs. ${opponent.name}',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            loading: () => const SizedBox(),
                            error: (_,__) => const Text('Error')
                        ),
                      ),
                      body: Stack(
                        children: [
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                            child: SizedBox(
                              height: getViewportHeight(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  groupAsyncValue.when(
                                      data: (group) => Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: _buildScoreBoard(group, game, opponent),
                                      ),
                                      loading: () => const SizedBox(),
                                      error: (_,__) => const Text('Error')
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 150),
                                    alignment: Alignment.bottomLeft,
                                    child: FutureBuilder(
                                      future: PermissionsManager.showGameScoreOption(groupID: game.groupID),
                                      builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                                        if(snap.hasData && snap.data!) {
                                          return _gameScorer(game, opponent, prefs);
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 3),
                                  _gameLocationTile(event, prefs),
                                  const Divider(height: 25),
                                  if(event.description != null && event.description!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildGameAboutSection(event.description!),
                                        const Divider(height: 25),
                                      ],
                                    ),
                                  Expanded(child: _buildGameUpdatesSection(game.id)),
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: FutureBuilder(
                              future: PermissionsManager.showGameUpdateBuilder(groupID: event.groupID!),
                              builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                                if(snap.hasData && snap.data!) {
                                  return _gameUpdateBuilder(game, prefs);
                                }
                                else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    );
                  },
                  loading: () {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                        toolbarHeight: 40,
                        elevation: 0,
                        backgroundColor: Colors.white,
                        iconTheme: const IconThemeData(color: Colors.black),
                        title: Text(
                          'Loading',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                  error: (_,__) => const Text('Error')
              );
            },
            loading: () {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  toolbarHeight: 40,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: Text(
                    'Loading',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
            error: (_,__) => const Text('Error')
        );
      },
      loading: () {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 40,
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              'Loading',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
      error: (_,__) => const Text('Error')
    );
  }

  Widget _buildScoreBoard(GroupModel groupModel, GameModel gameModel, OpponentModel opponentModel) {
    return Row(
      children: [
        _teamCircleAvatar(groupModel.profileImageURL, const Size(50, 50)),
        const Spacer(),
        Text(
          '${gameModel.homeTeamScore ?? '-'}',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        _buildGameDateTimeInfo(gameModel),
        const Spacer(),
        Text(
          '${gameModel.opposingTeamScore ?? '-'}',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        _teamCircleAvatar(opponentModel.logoURL, const Size(50, 50)),
      ],
    );
  }

  Widget _buildGameDateTimeInfo(GameModel gameModel) {
    String gameStatus = gameStatusString(gameModel);
    return Column(
      children: [
        Text(
          gameStatus,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: gameStatus == 'FINAL' ? FontWeight.w400 : FontWeight.w700,
            color: gameStatus == 'Live' ? Colors.green : Colors.black,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          '${DateFormat('E').format(DateTime.parse(gameModel.dateTimeString))} ${DateFormat('Md').format(DateTime.parse(gameModel.dateTimeString))}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color:Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@ ${DateFormat('jm').format(DateTime.parse(gameModel.dateTimeString))}',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color:Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _teamCircleAvatar(String imageURL, Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: CachedNetworkImage(
        imageUrl: imageURL,
        fit: BoxFit.fitWidth,
        width: size.width,
        height: size.height,
      ),
    );
  }

  Widget _gameLocationTile(EventModel eventModel, AppConfiguration prefs) {
    String? title;
    String? subtitle;
    if(eventModel.location.formattedAddress != null) {
      final addressArr = eventModel.location.formattedAddress!.split(', ');
      title = addressArr[0];
      subtitle = addressArr.getRange(1, addressArr.length).join(', ');
    }
    return ZAPListTile(
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
                      eventModel.location.name!,
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
                    MapsLauncher.launchQuery(eventModel.location.formattedAddress!);
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
                      eventModel.location.formattedAddress ?? eventModel.location.url!,
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
                      eventModel.location.description ?? 'No notes have been added.',
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
              if(eventModel.location.mapStaticImageURL != null)
                InkWell(onTap: () {
                  MapsLauncher.launchQuery(eventModel.location.formattedAddress!);
                },child: CachedNetworkImage(imageUrl: eventModel.location.mapStaticImageURL!)),
            ],
          ),
        ));
      },
      leading: _gameDetailIcon(Icons.location_on_outlined, prefs),
      title: SizedBox(
        width: getViewportWidth(context) * 0.7,
        child: Text(
          title!,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      horizontalTitleGap: 10,
      titleSubtitleGap: 3,
      subtitle: SizedBox(
        width: getViewportWidth(context) * 0.7,
        child: Text(
          subtitle!,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
    );
  }

  Widget _gameDetailIcon(IconData icon, AppConfiguration prefs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      height: 45,
      width: 45,
      child: Icon(
        icon,
        color: prefs.getPrimaryColor(),
      ),
    );
  }

  Widget _buildGameAboutSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Event',
          style: GoogleFonts.inter(
            fontSize: 18,
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
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _gameScorer(GameModel gameModel, OpponentModel opponentModel, AppConfiguration prefs) {
    return Column(
      children: [
        const Divider(),
        ZAPButton(
          padding: const EdgeInsets.symmetric(vertical: 5),
          onPressed: () {
            if(gameModel.isMarkedDone) {
              showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                  title: const Text('Game is over!'),
                  content: const Text('Are you sure you want to change the score?'),
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
                      child: PlatformText('Change'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        RoutingUtil.pushAsync(context, ReportScore(gameModel: gameModel, opponentModel: opponentModel, prefs: prefs), fullscreenDialog: true);
                      },
                      cupertino: (_,__) => CupertinoDialogActionData(
                        isDestructiveAction: true
                      ),
                    ),
                  ],
                ),
              );
            }
            else {
              RoutingUtil.pushAsync(context, ReportScore(gameModel: gameModel, opponentModel: opponentModel, prefs: prefs));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports,
              ),
              const SizedBox(width: 6),
              Text(
                gameModel.isMarkedDone ? 'Change Final Score' : 'Report Score',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameUpdatesSection(String gameID) {
    final gameUpdatesAsyncValue = ref.watch(getGameUpdatesStreamProvider(gameID));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Updates',
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        gameUpdatesAsyncValue.when(
          data: (gameUpdates) {
            return Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: gameUpdates.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 15, child: VerticalDivider(color: Colors.grey.shade400, thickness: 0.5,));
                },
                itemBuilder: (context, index) {
                  final update = gameUpdates[index];
                  return _gameUpdateCard(update);
                },
              ),
            );
          },
          loading: () => Center(child: PlatformCircularProgressIndicator()),
          error: (_,__) => const Text('Error'),
        ),
      ],
    );
  }

  Widget _gameUpdateCard(GameUpdateModel gameUpdateModel) {
    final userAsyncValue = ref.watch(getUserStreamProvider(gameUpdateModel.authorID));
    return userAsyncValue.when(
        data: (user) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 0.25)
            ),
            child: ZAPListTile(
              crossAxisAlignment: CrossAxisAlignment.start,
              horizontalTitleGap: 10,
              titleSubtitleGap: 3,
              leading: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(user.profileImageURL),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName} ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text('• ', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 10),),
                  Text(
                    timeAgo(gameUpdateModel.postedAt),
                    style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
              subtitle: SizedBox(
                width: getViewportWidth(context) * 0.725,
                child: Text(
                  gameUpdateModel.body,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox(),
        error: (_,__) => const Text('Error')
    );
  }

  Widget _gameUpdateBuilder(GameModel gameModel, AppConfiguration prefs) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(gameModel.groupID));
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100.withOpacity(0.95),
          border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300))
      ),
      // margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      width: getViewportWidth(context),
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        child: Row(
          children: [
            groupAsyncValue.when(
                data: (group) => CircleNetworkImage(imageURL: group.profileImageURL, size: const Size(40, 40), fit: BoxFit.cover),
                loading: () => const SizedBox(),
                error: (_,__) => const Text('Error')
            ),

            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                focusNode: _focusNode,
                maxLines: null,
                controller: _gameUpdateController,
                onChanged: (value) {
                  setState(() {
                    gameUpdateText = value;
                  });
                },
                style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                decoration: AppConfiguration.inputDecoration1.copyWith(
                    isDense: true,
                    hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    fillColor: Colors.white,
                    hintText: 'Add game update...'
                ),
              ),
            ),
            if((gameUpdateText ?? '').length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                    onTap: () async {
                      final gameUpdate = GameUpdateModel(
                        id: const Uuid().v4(),
                        gameID: gameModel.id,
                        authorID: FBAuth().getUserID()!,
                        postedAt: DateTime.now().toString(),
                        body: gameUpdateText!,
                      );
                      _gameUpdateController.text = '';
                      setState(() {
                        gameUpdateText = '';
                      });
                      await FBDatabase.postGameUpdate(gameUpdate);
                      _focusNode.unfocus();
                    },
                    child: Icon(CupertinoIcons.arrow_up_circle_fill, size: 35, color: prefs.getPrimaryColor(),)
                ),
              )
          ],
        ),
      ),
    );
  }

}
