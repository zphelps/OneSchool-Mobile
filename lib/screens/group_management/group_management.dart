import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/screens/group_management/settings/edit_group_name_description.dart';
import 'package:sea/screens/group_management/settings/edit_group_photos.dart';
import 'package:sea/screens/group_management/settings/edit_group_privacy.dart';
import 'package:sea/screens/group_management/roles/manage_members.dart';
import 'package:sea/screens/group_management/roles/manage_owners.dart';
import 'package:sea/screens/group_management/to_review/member_requests.dart';
import 'package:sea/screens/group_management/who_can_screens/who_can_add_files.dart';
import 'package:sea/screens/group_management/who_can_screens/who_can_create_events.dart';
import 'package:sea/screens/group_management/who_can_screens/who_can_post.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';

import '../../models/GroupModel.dart';
import '../../services/configuration.dart';

class GroupManagement extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const GroupManagement({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<GroupManagement> createState() => _GroupManagementState();
}

class _GroupManagementState extends ConsumerState<GroupManagement> {

  @override
  Widget build(BuildContext context) {
    final groupPermissionsAsyncValue = ref.watch(getGroupPermissionsStreamProvider(widget.groupModel.groupPermissionsID!));
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        leadingWidth: 29,
        title: ZAPListTile(
          leading: CircleNetworkImage(imageURL: widget.groupModel.profileImageURL, size: const Size(40,40), fit: BoxFit.cover),
          horizontalTitleGap: 8,
          title: Text(
            widget.groupModel.name,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
            ),
          ),
        ),
      ),
      body: groupPermissionsAsyncValue.when(
        data: (permissions) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    if(widget.groupModel.ownerIDs.contains(FBAuth().getUserID()!)
                        || widget.groupModel.creatorID == FBAuth().getUserID()!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _toReviewSection(),
                      ),
                    if(widget.groupModel.ownerIDs.contains(FBAuth().getUserID()!)
                        || widget.groupModel.creatorID == FBAuth().getUserID()!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _manageRolesSection(),
                      ),
                    if(permissions.canEditGroupInformation.contains(FBAuth().getUserID()!)
                        || widget.groupModel.ownerIDs.contains(FBAuth().getUserID()!)
                        || widget.groupModel.creatorID == FBAuth().getUserID()!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _groupSettings(),
                      ),
                    if(widget.groupModel.ownerIDs.contains(FBAuth().getUserID()!) || widget.groupModel.creatorID == FBAuth().getUserID()!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _groupPermissionsSection(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e,__) => Text(e.toString()),
      ),
    );
  }

  Widget _toReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To Review',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, MemberRequests(groupID: widget.groupModel.id)),
                child: ZAPListTile(
                  title: Text(
                    'Member Requests',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'View requests to join this group.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.person_add,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 25),
              InkWell(
                onTap: () {},
                child: ZAPListTile(
                  title: Text(
                    'Reported Content',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Manage content that has been reported by the community.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.report,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _manageRolesSection() {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roles',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, ManageOwners(prefs: prefs, groupID: widget.groupModel.id)),
                child: ZAPListTile(
                  title: Text(
                    'Owners',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Add or remove owners of this group.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.admin_panel_settings_sharp,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 25),
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, ManageMembers(prefs: prefs, groupID: widget.groupModel.id)),
                child: ZAPListTile(
                  title: Text(
                    'Members',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Add or remove members of this group.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.person_search,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, EditGroupNameDescription(groupModel: widget.groupModel)),
                child: ZAPListTile(
                  title: Text(
                    'Name and description',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.drive_file_rename_outline_rounded,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 25),
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, EditGroupPhotos(groupModel: widget.groupModel)),
                child: ZAPListTile(
                  title: Text(
                    'Profile and Background Photos',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.photo_library,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              if(!widget.groupModel.isTeam)
                Column(
                  children: [
                    const Divider(height: 25),
                    InkWell(
                      onTap: () => RoutingUtil.pushAsync(context, EditGroupPrivacy(groupModel: widget.groupModel)),
                      child: ZAPListTile(
                        title: Text(
                          'Privacy',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        titleSubtitleGap: 2,
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.65,
                          child: Text(
                            widget.groupModel.isPrivate ? 'Private' : 'Public',
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        horizontalTitleGap: 15,
                        leading: const Icon(
                          Icons.privacy_tip,
                          size: 28,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _groupPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Permissions',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, WhoCanPost(groupModel: widget.groupModel)),
                child: ZAPListTile(
                  title: Text(
                    'Who Can Post',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Manage members in group that can create posts.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.post_add,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 25),
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, WhoCanCreateEvents(groupModel: widget.groupModel)),
                child: ZAPListTile(
                  title: Text(
                    'Who Can Create Events',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Manage members in group that can create events.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.edit_calendar,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Divider(height: 25),
              InkWell(
                onTap: () => RoutingUtil.pushAsync(context, WhoCanAddFiles(groupModel: widget.groupModel)),
                child: ZAPListTile(
                  title: Text(
                    'Who Can Add Files',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  titleSubtitleGap: 1,
                  subtitle: SizedBox(
                    width: getViewportWidth(context) * 0.65,
                    child: Text(
                      'Manage members in group that can add files.',
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  horizontalTitleGap: 15,
                  leading: const Icon(
                    Icons.file_copy_outlined,
                    size: 28,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ),
              if(widget.groupModel.isTeam)
                Column(
                  children: [
                    const Divider(height: 25),
                    InkWell(
                      onTap: () {},
                      child: ZAPListTile(
                        title: Text(
                          'Who Can Report Scores',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        titleSubtitleGap: 1,
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.65,
                          child: Text(
                            'Manage who can edit group information such as name, photos, privacy, etc.',
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        horizontalTitleGap: 15,
                        leading: const Icon(
                          Icons.sports,
                          size: 28,
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }
}
