import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/screens/group_conversations/group_conversations.dart';
import 'package:sea/screens/group_management/group_management.dart';
import 'package:sea/screens/messaging/conversation_view.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_messaging.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:uuid/uuid.dart';

import '../services/fb_auth.dart';
import '../services/fb_database.dart';
import '../services/helpers.dart';
import '../zap_widgets/zap_button.dart';

class GroupAssociationButtons extends StatefulWidget {
  final GroupModel groupModel;
  final AppConfiguration prefs;
  const GroupAssociationButtons({Key? key, required this.groupModel, required this.prefs}) : super(key: key);

  @override
  State<GroupAssociationButtons> createState() => _GroupAssociationButtonsState();
}

class _GroupAssociationButtonsState extends State<GroupAssociationButtons> {

  bool _messageIsLoading = false;

  @override
  Widget build(BuildContext context) {
    final uid = FBAuth().getUserID() ?? '';
    if(isOwnerOfGroup(widget.groupModel, uid) || isCreatorOfGroup(widget.groupModel, uid)) {
      return Row(
        children: [
          _groupConversationsButton(),
          const SizedBox(width: 8),
          _manageGroupButton(),
        ],
      );
    }
    else if(isMemberOfGroup(widget.groupModel, uid)) {
      return Row(
        children: [
          _groupConversationsButton(),
        ],
      );
    }
    else if(!widget.groupModel.isPrivate && isFollowerOfGroup(widget.groupModel, uid)) {
      return Row(
        children: [
          _followButton(),
          const SizedBox(width: 8),
          _requestToJoinButton(),
        ],
      );
    }
    else if(widget.groupModel.isPrivate) {
      return Row(
        children: [
          _requestToJoinButton(),
        ],
      );
    }
    else {
      return Row(
        children: [
          _followButton(),
          const SizedBox(width: 8),
          _requestToJoinButton(),
        ],
      );
    }
  }

  Widget _manageGroupButton() {
    return Expanded(
      child: ZAPButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xffBBBBBB)),
        backgroundColor: Colors.white,
        onPressed: () async {
          if(widget.groupModel.groupPermissionsID == null) {
            final groupPermissionsModel = GroupPermissionsModel(
              id: const Uuid().v4(),
              canEditGroupInformation: [widget.groupModel.creatorID],
              canCreatePosts: [widget.groupModel.creatorID],
              canCreateEvents: [widget.groupModel.creatorID],
              canAddFiles: [widget.groupModel.creatorID],
              canScoreGames: [widget.groupModel.creatorID],
              canPostGameUpdates: [widget.groupModel.creatorID],
            );
            await FBDatabase.createGroupPermissions(groupPermissionsModel);
            await FBDatabase.setGroupPermissions(widget.groupModel.id, groupPermissionsModel.id);
          }
          RoutingUtil.pushAsync(context, GroupManagement(groupModel: widget.groupModel));
        },
        child: Text(
          'Manage',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13
          ),
        ),
      ),
    );
  }

  Widget _groupConversationsButton() {
    return Expanded(
      child: ZAPButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: widget.prefs.getPrimaryColor()),
        backgroundColor: widget.prefs.getPrimaryColor().withOpacity(0.1),
        onPressed: () async {
          setState(() {
            _messageIsLoading = true;
          });
          RoutingUtil.pushAsync(context, GroupConversations(groupID: widget.groupModel.id, prefs: widget.prefs));
          setState(() {
            _messageIsLoading = false;
          });
        },
        child: _messageIsLoading ? const CupertinoActivityIndicator(radius: 7.5) : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 14,
              color: widget.prefs.getPrimaryColor(),
            ),
            const SizedBox(width: 5),
            Text(
              'Conversations',
              style: GoogleFonts.inter(
                  color: widget.prefs.getPrimaryColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 13
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestToJoinButton() {
    return Expanded(
      child: ZAPButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xffBBBBBB)),
        backgroundColor: isRequestedMemberOfGroup(widget.groupModel, FBAuth().getUserID()!) ? Colors.grey[50] : Colors.white,
        onPressed: () async {
          if(isRequestedMemberOfGroup(widget.groupModel, FBAuth().getUserID()!)) {
            await withdrawRequestToJoinGroup(FBAuth().getUserID()!, widget.groupModel);
          }
          else {
            await requestToJoinGroup(FBAuth().getUserID()!, widget.groupModel);
          }
        },
        child: Text(
          isRequestedMemberOfGroup(widget.groupModel, FBAuth().getUserID()!) ? 'Withdraw Join Request' : 'Request To Join',
          style: GoogleFonts.inter(
              color: isRequestedMemberOfGroup(widget.groupModel, FBAuth().getUserID()!) ? Colors.grey[600] : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13
          ),
        ),
      ),
    );
  }


  Widget _followButton() {
    return Expanded(
      child: ZAPButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!) ? Colors.grey : widget.prefs.getPrimaryColor()),
        backgroundColor: isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!) ? Colors.grey[50] : widget.prefs.getPrimaryColor().withOpacity(0.1),
        onPressed: () async {
          if(isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!)) {
            await unfollowGroup(FBAuth().getUserID()!, widget.groupModel.id);
          }
          else {
            await followGroup(FBAuth().getUserID()!, widget.groupModel.id);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!) ? 'Following' : 'Follow',
              style: GoogleFonts.inter(
                  color: isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!) ? Colors.grey : widget.prefs.getPrimaryColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 13
              ),
            ),
            if(isFollowerOfGroup(widget.groupModel, FBAuth().getUserID()!))
              Icon(
                Icons.arrow_drop_down,
                size: 12,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}
