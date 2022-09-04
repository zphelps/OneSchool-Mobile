import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/widgets/SEAUser_search/SEAUser_bloc.dart';
import 'package:tuple/tuple.dart';

import '../../../services/fb_database.dart';
import '../../../services/helpers.dart';
import '../../../services/providers.dart';
import '../../../services/routing_helper.dart';
import '../../../widgets/SEAUser_search/SEAUser_search.dart';
import '../../../widgets/app_bar_circular_action_button.dart';
import '../../../widgets/circle_network_image.dart';
import '../../../zap_widgets/ZAP_list_tile.dart';
import '../../../zap_widgets/zap_button.dart';

class WhoCanAddFiles extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const WhoCanAddFiles({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<WhoCanAddFiles> createState() => _WhoCanAddFilesState();
}

class _WhoCanAddFilesState extends ConsumerState<WhoCanAddFiles> {

  String? uidOfUserBeingRemoved;

  @override
  Widget build(BuildContext context) {
    final groupPermissionsAsyncValue = ref.watch(getGroupPermissionsStreamProvider(widget.groupModel.groupPermissionsID!));
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Can Add Files',
            style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AppBarCircularActionButton(
                onTap: () async {
                  final permissions = await PermissionsManager.groupPermissions(groupID: widget.groupModel.id);
                  RoutingUtil.pushAsync(context, fullscreenDialog: true, AddUserWhoCanAddFiles(groupModel: widget.groupModel, groupPermissionsModel: permissions));
                },
                backgroundColor: Colors.grey[200],
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Colors.black,
                  size: 22,
                ),
                radius: 18,
              ),
            )
          ],
        ),
        body: groupPermissionsAsyncValue.when(
          data: (permissions) {
            return SEAUserSearch(
                searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                listPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                separator: const Divider(height: 20),
                emptyState: Center(
                  child: Text(
                    'No Members Added.',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey
                    ),
                  ),
                ),
                filter: (user) {
                  if(permissions.canAddFiles.contains(user.id)
                      && !widget.groupModel.ownerIDs.contains(user.id)
                      && widget.groupModel.creatorID != user.id) {
                    return true;
                  }
                  return false;
                },
                listTile: (user, notifier) {
                  return ZAPListTile(
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
                        setState(() {
                          uidOfUserBeingRemoved = user.id;
                        });
                        await FBDatabase.removeUserWhoCanAddFiles(permissions, user.id);
                        setState(() {
                          uidOfUserBeingRemoved = null;
                        });
                        notifier.data.remove(user);
                      },
                      child: Text(
                        'Remove',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_,__) => const Text('Error'),
        )
    );
  }

}

class AddUserWhoCanAddFiles extends StatelessWidget {
  final GroupModel groupModel;
  final GroupPermissionsModel groupPermissionsModel;
  const AddUserWhoCanAddFiles({Key? key, required this.groupModel, required this.groupPermissionsModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Add Member Who Can Add Files',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SEAUserSearch(
            searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            listPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            separator: const Divider(height: 0),
            filter: (user) {
              if(!groupPermissionsModel.canAddFiles.contains(user.id) && groupModel.memberIDs.contains(user.id)) {
                return true;
              }
              return false;
            },
            listTile: (user, notifier) => InkWell(
              splashFactory: InkSparkle.splashFactory,
              onTap: () async {
                await FBDatabase.addUserWhoCanAddFiles(groupPermissionsModel, user.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                RoutingUtil.pushAsync(context, WhoCanAddFiles(groupModel: groupModel));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ZAPListTile(
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
                    trailing: const Icon(
                      CupertinoIcons.circle,
                      color: Colors.grey,
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

