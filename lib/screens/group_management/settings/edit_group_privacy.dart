import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/zap_widgets/zap_button.dart';

import '../../../services/configuration.dart';
import '../../../services/fb_database.dart';
import '../../../services/helpers.dart';
import '../../../zap_widgets/ZAP_list_tile.dart';
import '../../admin/create_group.dart';

class EditGroupPrivacy extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const EditGroupPrivacy({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<EditGroupPrivacy> createState() => _EditGroupPrivacyState();
}

class _EditGroupPrivacyState extends ConsumerState<EditGroupPrivacy> {

  late GroupPrivacy _privacy;

  @override
  void initState() {
    super.initState();
    if(widget.groupModel.isPrivate) {
      _privacy = GroupPrivacy.private;
    }
    else {
      _privacy = GroupPrivacy.public;
    }
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
          'Edit Privacy',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.groupModel.isPrivate ? 'Privacy' : 'Change Privacy?',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 20
                ),
              ),
              const SizedBox(height: 16),
              if(!widget.groupModel.isPrivate)
                ZAPListTile(
                    onTap: () {
                      setState(() {
                        _privacy = GroupPrivacy.public;
                      });
                      // Navigator.of(context).pop();
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
              if(!widget.groupModel.isPrivate)
                const SizedBox(height: 25),
              ZAPListTile(
                  onTap: () {
                    setState(() {
                      _privacy = GroupPrivacy.private;
                    });
                    // Navigator.of(context).pop();
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
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'IMPORTANT:  Private groups can not be changed to public.',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4
                  ),
                ),
              ),
              const Spacer(),
              if(!widget.groupModel.isPrivate)
                ZAPButton(
                  onPressed: () async {
                    if(_privacy == GroupPrivacy.private) {
                      showPlatformDialog(
                        context: context,
                        builder: (_) => PlatformAlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text('Once a group is made private, it cannot be made public in order to protect the privacy of its members.'),
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
                              child: PlatformText('Continue'),
                              onPressed: () async {
                                await FBDatabase.makeGroupPrivate(widget.groupModel.id);
                                Navigator.of(context).popUntil((route) => !route.hasActiveRouteBelow);
                              },
                              cupertino: (_,__) => CupertinoDialogActionData(
                                isDestructiveAction: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  backgroundColor: _privacy == GroupPrivacy.private ? prefs.getPrimaryColor() : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  borderRadius: BorderRadius.circular(10),
                  child: Text(
                    'Change',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
