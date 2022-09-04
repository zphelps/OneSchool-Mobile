import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/main.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/create_event.dart';
import 'package:sea/screens/admin/create_game.dart';
import 'package:sea/screens/events/event_details.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../services/routing_helper.dart';
import '../admin/create_post.dart';

class GroupActionButtons extends StatefulWidget {
  final AppConfiguration prefs;
  final SEAUser user;
  final GroupModel groupModel;
  final GroupPermissionsModel groupPermissionsModel;
  const GroupActionButtons({Key? key, required this.prefs, required this.user, required this.groupModel, required this.groupPermissionsModel}) : super(key: key);

  @override
  State<GroupActionButtons> createState() => _GroupActionButtonsState();
}

class _GroupActionButtonsState extends State<GroupActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            _groupAction(Icons.edit_outlined, 'Post', () =>
                RoutingUtil.pushAsync(context, CreatePost(groupModel: widget.groupModel), fullscreenDialog: true),),
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            const SizedBox(width: 10),
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            _groupAction(Icons.sports_basketball_outlined, 'Game', () =>
                RoutingUtil.pushAsync(context, CreateGame(defaultGroup: widget.groupModel, user: widget.user, prefs: widget.prefs), fullscreenDialog: true),),
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            const SizedBox(width: 10),
          if(widget.groupPermissionsModel.canCreateEvents.contains(FBAuth().getUserID()!))
            _groupAction(Icons.calendar_month_outlined, 'Event', () async {
              final result = await RoutingUtil.pushAsync(context, CreateEvent(user: widget.user, prefs: widget.prefs, defaultGroup: widget.groupModel), fullscreenDialog: true);
              if(result != null) {
                RoutingUtil.pushAsync(context, EventDetails(eventID: result.id, comingFromGroupProfile: true, user: widget.user));
              }
            }),
          if(widget.groupPermissionsModel.canCreateEvents.contains(FBAuth().getUserID()!))
            const SizedBox(width: 10),
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            _groupAction(Icons.poll_outlined, 'Poll', () =>
                RoutingUtil.pushAsync(context, CreatePost(groupModel: widget.groupModel, addPoll: true), fullscreenDialog: true)),
          if(widget.groupPermissionsModel.canCreatePosts.contains(FBAuth().getUserID()!))
            const SizedBox(width: 10),
          if(widget.groupPermissionsModel.canAddFiles.contains(FBAuth().getUserID()!))
            _groupAction(Icons.file_copy_outlined, 'File', () { }),
        ],
      ),
    );
  }

  Widget _groupAction(IconData iconData, String label, void Function() onTap) {
    return Expanded(
      child: ZAPButton(
        onPressed: onTap,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400),
        child: Column(
          children: [
            Icon(
              iconData,
              color: widget.prefs.getPrimaryColor(),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
