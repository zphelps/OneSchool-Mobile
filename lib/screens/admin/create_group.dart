import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/complete_group_info.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/app_bar_circular_action_button.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';
import 'package:uuid/uuid.dart';

import '../../models/URLModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_database.dart';
import '../../services/fb_storage.dart';

class CreateGroup extends ConsumerStatefulWidget {
  final SEAUser user;
  const CreateGroup({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {

  final _formKey = GlobalKey<FormState>();

  GroupPrivacy? _privacy;

  bool _loading = false;

  String? groupImageURL;

  final ImagePicker _imagePicker = ImagePicker();

  final _privacyTextController = TextEditingController();
  final _nameTextController = TextEditingController();

  validate() {
    if(_nameTextController.text.isNotEmpty && _privacy != null && groupImageURL != null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Create Group',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SizedBox(
        width: getViewportWidth(context),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            CircleNetworkImage(
                              imageURL: groupImageURL ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__480.png',
                              size: const Size(125, 125),
                              fit: BoxFit.cover,
                            ),
                            TextButton(
                              onPressed: () async {
                                XFile? image =
                                    await _imagePicker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  URL url = await FBStorage.uploadGroupProfilePhotoToFireStorage(
                                      File(image.path), context);
                                  setState(() {
                                    groupImageURL = url.url;
                                  });
                                }

                              },
                              child: const Text(
                                'Choose group photo'
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Name',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameTextController,
                        decoration: InputDecoration(
                          hintText: 'Name your group',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: prefs.getPrimaryColor())
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Privacy',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        readOnly: true,
                        controller: _privacyTextController,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: () => showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            context: context, builder: (context) => Wrap(children: [_buildPrivacySelectorModal(prefs)])),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.grey,
                            size: 32,
                          ),
                          hintText: _privacy != null ? null : 'Choose privacy',
                          prefixIcon: _privacy != null ? Padding(
                            padding: const EdgeInsets.only(left: 10, right: 8),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              radius: 20,
                              child: Icon(
                                _privacy == GroupPrivacy.public ? Icons.language : Icons.lock,
                                size: 25,
                                color: Colors.black,
                              ),
                            ),
                          ) : null,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300)
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if(_privacy == GroupPrivacy.private)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'IMPORTANT:  Private groups can not be made public after they are created',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.4
                            ),

                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 0,
              child: SafeArea(
                child: Column(
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
                            final groupPermissionsModel = GroupPermissionsModel(
                              id: const Uuid().v4(),
                              canAddFiles: [FBAuth().getUserID()!],
                              canCreateEvents: [FBAuth().getUserID()!],
                              canCreatePosts: [FBAuth().getUserID()!],
                              canEditGroupInformation: [FBAuth().getUserID()!],
                              canScoreGames: [FBAuth().getUserID()!],
                              canPostGameUpdates: [FBAuth().getUserID()!]
                            );
                            final groupModel = GroupModel(
                              id: const Uuid().v4(),
                              name: _nameTextController.text,
                              profileImageURL: groupImageURL!,
                              ownerIDs: [FBAuth().getUserID()!],
                              creatorID: FBAuth().getUserID()!,
                              followerIDs: [FBAuth().getUserID()!],
                              memberIDs: [FBAuth().getUserID()!],
                              memberRequestIDs: const [],
                              backgroundImageURL: null,
                              description: null,
                              groupPermissionsID: groupPermissionsModel.id,
                              sponsorID: null,
                              isPrivate: _privacy == GroupPrivacy.private ? true : false,
                              isTeam: false,
                            );
                            await FBDatabase.createGroupPermissions(groupPermissionsModel);
                            await FBDatabase.createGroup(groupModel);
                            await FBDatabase.addGroupUserIsFollowing(FBAuth().getUserID()!, groupModel.id);
                            await FBDatabase.addGroupUserIsMemberOf(FBAuth().getUserID()!, groupModel.id);
                            await FBDatabase.addGroupUserIsOwnerOf(FBAuth().getUserID()!, groupModel.id);
                            setState(() {
                              _loading = false;
                            });
                            RoutingUtil.pushReplacement(context, CompleteGroupInfo(user: widget.user, groupID: groupModel.id), fullscreenDialog: true);
                          }
                        },
                        backgroundColor: validate() ? prefs.getPrimaryColor() : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        height: 45,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Create Group',
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
            _loading ? Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      )
    );
  }

  Widget _buildPrivacySelectorModal(AppConfiguration prefs) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10))
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                  ),
                ),
                title: Text(
                  'Choose privacy',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              ZAPListTile(
                onTap: () {
                  setState(() {
                    _privacy = GroupPrivacy.public;
                  });
                  _privacyTextController.text = 'Public';
                  Navigator.of(context).pop();
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 25,
                  child: const Icon(
                    Icons.language,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  'Public',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                titleSubtitleGap: 2,
                crossAxisAlignment: CrossAxisAlignment.center,
                horizontalTitleGap: 10,
                subtitle: SizedBox(
                  width: getViewportWidth(context) * 0.65,
                  child: Text(
                    "Anyone can follow, view group's members, and view public posts.",
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: _privacy == GroupPrivacy.public ?
                  Icon(Icons.radio_button_checked, color: prefs.getPrimaryColor()) :
                  const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
              ),
              const SizedBox(height: 25),
              ZAPListTile(
                onTap: () {
                  setState(() {
                    _privacy = GroupPrivacy.private;
                  });
                  _privacyTextController.text = 'Private';
                  Navigator.of(context).pop();
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 25,
                  child: const Icon(
                    Icons.lock,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  'Private',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                titleSubtitleGap: 2,
                crossAxisAlignment: CrossAxisAlignment.center,
                horizontalTitleGap: 10,
                subtitle: SizedBox(
                  width: getViewportWidth(context) * 0.65,
                  child: Text(
                    "All group information is restricted to those in the group.",
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                trailing: _privacy == GroupPrivacy.private ?
                    Icon(Icons.radio_button_checked, color: prefs.getPrimaryColor()) :
                    const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}

enum GroupPrivacy { public, private }