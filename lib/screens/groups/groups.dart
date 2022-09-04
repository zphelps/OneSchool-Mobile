import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/group_profile/group_profile.dart';
import 'package:sea/screens/admin/create_group.dart';
import 'package:sea/services/fb_storage.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/app_bar_circular_action_button.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/widgets/group_association_buttons.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';

import '../../models/GroupModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_auth.dart';
import '../../services/permissions_manager.dart';
import '../../widgets/logo_app_bar.dart';
import '../notifications/notifications.dart';

enum GroupQuery {
  following,
  memberOf,
  all,
}

class Groups extends ConsumerStatefulWidget {
  final SEAUser user;
  const Groups({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<Groups> createState() => _GroupsState();
}

class _GroupsState extends ConsumerState<Groups> {
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, value) {
                return [
                  Theme(
                    data: ThemeData(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: LogoAppBar(
                      sliverAppBar: true,
                      logoURL: prefs.getSchoolLogoURL(),
                      floating: true,
                      pinned: true,
                      snap: true,
                      title: 'Groups',
                      actions: [
                        if(widget.user.userPermissions.canCreateGroups || widget.user.userPermissions.fullAdmin)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: AppBarCircularActionButton(
                              onTap: () => RoutingUtil.pushAsync(context, CreateGroup(user: widget.user), fullscreenDialog: true),
                              backgroundColor: Colors.grey[200],
                              icon: const Icon(
                                Icons.add_circle_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                              radius: 18,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: AppBarCircularActionButton(
                            onTap: () => RoutingUtil.pushAsync(context, const Notifications()),
                            backgroundColor: Colors.grey[200],
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.black,
                              size: 22,
                            ),
                            radius: 18,
                          ),
                        ),
                      ],
                      bottom: TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        labelColor: prefs.getPrimaryColor(),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: prefs.getPrimaryColor(),
                        tabs: const [
                          Tab(text: 'My Groups'),
                          Tab(text: 'Following'),
                          Tab(text: 'All Groups'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  _buildGroupList(ref, prefs, GroupQuery.memberOf),
                  _buildGroupList(ref, prefs, GroupQuery.following),
                  _buildGroupList(ref, prefs, GroupQuery.all),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildGroupList(WidgetRef ref, AppConfiguration prefs, GroupQuery query) {
    final groupsAsyncValue = ref.watch(groupsStreamProvider(query));
    return groupsAsyncValue.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Text(
                'No groups found.',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey
                ),
              )
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            shrinkWrap: true,
            itemCount: groups.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
            itemBuilder: (context, index) {
              return _buildGroupListCard(groups[index], prefs);
            },
          );
        },
        loading: () => PlatformCircularProgressIndicator(),
        error: (_,__) => const SliverList(delegate: SliverChildListDelegate.fixed([Text('Error')]))
    );
  }

  Widget _buildGroupListCard(GroupModel group, AppConfiguration prefs) {
    return GestureDetector(
      onTap: () async {
        RoutingUtil.pushAsync(context, GroupProfile(user: widget.user, groupID: group.id));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100, //0.35
                spreadRadius: 0,
                blurRadius: 24,
                offset: const Offset(0, 0),
              )
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZAPListTile(
              horizontalTitleGap: 8,
              titleSubtitleGap: 1,
              contentPadding: const EdgeInsets.only(bottom: 8),
              leading: CircleNetworkImage(
                imageURL: FBStorage.get100x100Image(group.profileImageURL),
                fit: BoxFit.cover,
                size: const Size(40, 40),
              ),
              title: Text(
                group.name,
                style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Row(
                children: [
                  Text(
                    group.isTeam ? 'Team ' : 'Club ',
                    style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text('• ', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 10),),
                  Text(
                    '${group.memberIDs.length} ${group.memberIDs.length > 1 ? 'members' : 'member'}',
                    style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ],
              ),
              trailing: getGroupAssociation(group, FBAuth().getUserID()!) == GroupAssociation.none ? Icon(
                group.isPrivate ? Icons.lock_outline : Icons.lock_open_outlined,
                color: Colors.grey,
                size: 18,
              ) : _groupAssociationChip(group),
            ),
            Text(
              group.description!,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if(getGroupAssociation(group, FBAuth().getUserID()!) == GroupAssociation.none || getGroupAssociation(group, FBAuth().getUserID()!) == GroupAssociation.follower)
              Column(
                children: [
                  const SizedBox(height: 10),
                  GroupAssociationButtons(groupModel: group, prefs: prefs),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _groupAssociationChip(GroupModel groupModel) {
    String? chipText;
    GroupAssociation groupAssociation = getGroupAssociation(groupModel, FBAuth().getUserID()!);
    if(groupAssociation == GroupAssociation.creator) {
      chipText = 'Creator';
    }
    else if(groupAssociation == GroupAssociation.owner) {
      chipText = 'Owner';
    }
    else if(groupAssociation == GroupAssociation.member) {
      chipText = 'Member';
    }
    else if(groupAssociation == GroupAssociation.follower) {
      chipText = 'Follower';
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        chipText!,
        style: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 11
        ),
      ),
    );
  }
}

enum GroupAssociation {creator, owner, member, follower, none}
