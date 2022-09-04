import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../../models/SEAUser.dart';
import '../../../services/configuration.dart';

class MemberRequests extends ConsumerStatefulWidget {
  final String groupID;
  const MemberRequests({Key? key, required this.groupID}) : super(key: key);

  @override
  ConsumerState<MemberRequests> createState() => _MemberRequestsState();
}

class _MemberRequestsState extends ConsumerState<MemberRequests> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Member Requests',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: groupAsyncValue.when(
        data: (group) {
          return _buildRequestList(group, prefs);
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e,__) => Text(e.toString()),
      ),
    );
  }

  Widget _buildRequestList(GroupModel groupModel, AppConfiguration prefs) {
    List<dynamic> memberRequests = groupModel.memberRequestIDs;
    if(memberRequests.isEmpty) {
      memberRequests.add('null');
    }
    final requestsAsyncValue = ref.watch(getManyUsersStreamProvider(memberRequests));
    return requestsAsyncValue.when(
      data: (users) {
        if(users.isEmpty) {
          return Center(
              child: Text(
                'No requests at this time.',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey
                ),
              )
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _memberRequestListTile(user, prefs);
          },
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e,__) => Text(e.toString()),
    );
  }

  Widget _memberRequestListTile(SEAUser user, AppConfiguration prefs) {
    return ZAPListTile(
      leading: CircleNetworkImage(
        imageURL: user.profileImageURL,
        fit: BoxFit.cover,
      ),
      horizontalTitleGap: 10,
      title: Text(
        '${user.firstName} ${user.lastName}',
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      trailing: Row(
        children: [
          ZAPButton(
            onPressed: () async {
              await FBDatabase.removeRequestToJoinGroup(widget.groupID, user.id);
              final snackBar = SnackBar(
                content: Text("${user.firstName}'s member request has been declined."),
              );
              _scaffoldKey.currentState?.showSnackBar(snackBar);
            },
            child: Text(
              'Decline',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          ZAPButton(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: prefs.getPrimaryColor(),),
            onPressed: () async {
              await FBDatabase.addMemberToGroup(widget.groupID, user.id);
              await FBDatabase.removeRequestToJoinGroup(widget.groupID, user.id);
              final snackBar = SnackBar(
                content: Text("${user.firstName} is now a member of this group."),
              );
              _scaffoldKey.currentState?.showSnackBar(snackBar);
            },
            child: Text(
              'Accept',
              style: GoogleFonts.inter(
                color: prefs.getPrimaryColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
