import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:uuid/uuid.dart';

import '../../models/GameUpdateModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_auth.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../../zap_widgets/zap_button.dart';

class ReportScore extends ConsumerStatefulWidget {
  final GameModel gameModel;
  final OpponentModel opponentModel;
  final AppConfiguration prefs;
  const ReportScore({Key? key, required this.gameModel, required this.opponentModel, required this.prefs}) : super(key: key);

  @override
  ConsumerState<ReportScore> createState() => _ReportScoreState();
}

class _ReportScoreState extends ConsumerState<ReportScore> {

  final homeScoreTextController = TextEditingController();
  final opponentScoreTextController = TextEditingController();

  late bool _gameDone;

  bool _loading = false;

  bool _sendPush = true;

  validate() {
    if(homeScoreTextController.text.isNotEmpty && homeScoreTextController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    homeScoreTextController.text = '${widget.gameModel.homeTeamScore ?? '0'}';
    opponentScoreTextController.text = '${widget.gameModel.opposingTeamScore ?? '0'}';
    _gameDone = widget.gameModel.isMarkedDone;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Report Score',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: getViewportHeight(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: ZAPListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 25,
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.black,
                        ),
                      ),
                      horizontalTitleGap: 10,
                      title: Text(
                        'Send Alert to Fans?',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      titleSubtitleGap: 2,
                      subtitle: SizedBox(
                        width: getViewportWidth(context) * 0.625,
                        child: Text(
                          'Followers and members of this team will be notified.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: CupertinoSwitch(
                          value: _sendPush,
                          onChanged: (sendPush) {
                            setState(() {
                              _sendPush = sendPush;
                            });
                          }
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: const BoxDecoration(
                        color: Colors.white
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      controller: homeScoreTextController,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          labelText: '${widget.prefs.getSchoolName()} Score'
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: const BoxDecoration(
                        color: Colors.white
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      maxLines: null,
                      controller: opponentScoreTextController,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        labelText: '${widget.opponentModel.name} Score',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if(!widget.gameModel.isMarkedDone)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: const BoxDecoration(
                          color: Colors.white
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _gameDone = !_gameDone;
                          });
                          HapticFeedback.mediumImpact();
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: Text(
                          'Final score?',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          _gameDone ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                          color: _gameDone ? widget.prefs.getPrimaryColor() : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: ZAPButton(
                      onPressed: () async {
                        if(validate()) {
                          setState(() {
                            _loading = true;
                          });
                          await FBDatabase.updateScore(widget.gameModel.id, int.parse(homeScoreTextController.text), int.parse(opponentScoreTextController.text));
                          await FBDatabase.setGameIsDone(widget.gameModel.id, _gameDone);
                          final gameUpdate = GameUpdateModel(
                            id: const Uuid().v4(),
                            gameID: widget.gameModel.id,
                            authorID: FBAuth().getUserID()!,
                            postedAt: DateTime.now().toString(),
                            body: getGameUpdateText(int.parse(homeScoreTextController.text), int.parse(opponentScoreTextController.text), widget.prefs.getSchoolName(), widget.opponentModel.name),
                          );
                          await FBDatabase.postGameUpdate(gameUpdate);
                          setState(() {
                            _loading = false;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: validate() ? widget.prefs.getPrimaryColor() : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _loading ? const CupertinoActivityIndicator(radius: 7.5) : Text(
                        'Update Score',
                        style: GoogleFonts.inter(
                            color: validate() ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
