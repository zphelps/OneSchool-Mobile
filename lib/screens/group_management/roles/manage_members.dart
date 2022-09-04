import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/SEAUser_search/SEAUser_search.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../../widgets/app_bar_circular_action_button.dart';

class ManageMembers extends ConsumerStatefulWidget {
  final AppConfiguration prefs;
  final String groupID;
  const ManageMembers({Key? key, required this.prefs, required this.groupID}) : super(key: key);

  @override
  ConsumerState<ManageMembers> createState() => _ManageMembersState();
}

class _ManageMembersState extends ConsumerState<ManageMembers> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? uidOfUserBeingRemoved;

  @override
  Widget build(BuildContext context) {
    final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Manage Members',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
        actions: [
          groupAsyncValue.when(
            data: (group) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AppBarCircularActionButton(
                  onTap: () async {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => _addMember(group));
                  },
                  backgroundColor: Colors.grey[200],
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  radius: 18,
                ),
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (_,__) => const Text('Error'),
          ),
        ],
      ),
      body: groupAsyncValue.when(
        data: (group) {
          return SEAUserSearch(
            searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            listPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            separator: const Divider(height: 20),
            filter: (user) {
              return group.memberIDs.contains(user.id);
            },
            listTile: (user, notifier) => ZAPListTile(
              leading: CircleNetworkImage(
                imageURL: user.profileImageURL,
                fit: BoxFit.cover,
              ),
              horizontalTitleGap: 10,
              title: Text(
                '${user.firstName} ${user.lastName}',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
              ),
              trailing: uidOfUserBeingRemoved != null && uidOfUserBeingRemoved == user.id ? const CupertinoActivityIndicator(radius: 7.5) : ZAPButton(
                borderRadius: BorderRadius.circular(6),
                onPressed: () async {
                  if(group.creatorID != user.id) {
                    setState(() {
                      uidOfUserBeingRemoved = user.id;
                    });
                    await PermissionsManager.removeMemberFromGroup(group, user.id);
                    setState(() {
                      uidOfUserBeingRemoved = null;
                    });
                    notifier.data.remove(user);
                    final snackBar = SnackBar(
                      content: Text("${user.firstName} is no longer a member."),
                    );
                    _scaffoldKey.currentState?.showSnackBar(snackBar);
                  }

                },
                child: Text(
                  group.creatorID == user.id ? 'Creator' : 'Remove',
                  style: GoogleFonts.inter(
                    color: group.creatorID == user.id ? Colors.grey.shade400 : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (_,__) => const Text('Error'),
      ),
    );
  }

  Widget _addMember(GroupModel groupModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      height: getViewportHeight(context) * 0.85,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 4,
              width: 50,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Add Member',
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 20
              ),
            ),
          ),
          SEAUserSearch(
            searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            listPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            separator: const Divider(height: 20),
            filter: (user) => !groupModel.memberIDs.contains(user.id),
            listTile: (user, notifier) => ZAPListTile(
              leading: CircleNetworkImage(
                imageURL: user.profileImageURL,
                fit: BoxFit.cover,
              ),
              horizontalTitleGap: 10,
              title: Text(
                '${user.firstName} ${user.lastName}',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
              ),
              trailing: ZAPButton(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: widget.prefs.getPrimaryColor(),),
                onPressed: () async {
                  await PermissionsManager.addMemberToGroup(groupModel, user.id);
                  Navigator.of(context).pop();
                  notifier.setLoading(true);
                  await Future.delayed(const Duration(milliseconds: 500));
                  RoutingUtil.pushReplacementNoAnimation(context, ManageMembers(prefs: widget.prefs, groupID: groupModel.id));
                },
                child: Text(
                  'Add Member',
                  style: GoogleFonts.inter(
                    color: widget.prefs.getPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
