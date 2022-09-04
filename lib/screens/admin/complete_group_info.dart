import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/group_profile/group_profile.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';

import '../../models/URLModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_storage.dart';
import '../../zap_widgets/zap_button.dart';

class CompleteGroupInfo extends ConsumerStatefulWidget {
  final String groupID;
  final SEAUser user;
  const CompleteGroupInfo({Key? key, required this.groupID, required this.user}) : super(key: key);

  @override
  ConsumerState<CompleteGroupInfo> createState() => _CompleteGroupInfoState();
}

class _CompleteGroupInfoState extends ConsumerState<CompleteGroupInfo> {

  final PageController _controller = PageController(initialPage: 0, keepPage: false);

  String? backgroundImageURL;
  String? description;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            if(_controller.page == 0) {
              Navigator.of(context).pop();
            }
            _controller.animateToPage(_controller.page!.toInt()-1, duration: const Duration(milliseconds: 200), curve: Curves.linear);
          },
          icon: const Icon(Icons.chevron_left, size: 36),
        ),
        actions: [
          PlatformTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue Later',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 16
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          groupAsyncValue.when(
            data: (group) {
              return PageView(controller: _controller, physics: const NeverScrollableScrollPhysics(), children: [
                _groupBackgroundImagePage(),
                _groupDescriptionPage(),
              ]);
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (_,__) => const Text('Error'),
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
                        if(_controller.page != 1) {
                          _controller.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.linear);
                        }
                        else {
                          await FBDatabase.setGroupDescription(widget.groupID, description ?? '');
                          RoutingUtil.pushReplacement(context, GroupProfile(user: widget.user, groupID: widget.groupID));
                        }
                      },
                      backgroundColor: prefs.getPrimaryColor(),
                      borderRadius: BorderRadius.circular(8),
                      height: 45,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _controller.hasClients && _controller.page == 1 ? 'Finish' : 'Next',
                        style: GoogleFonts.inter(
                            color: Colors.white,
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
      )
    );
  }

  Widget _groupBackgroundImagePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a background photo',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Help people understand your group better with an engaging background photo.',
            style: GoogleFonts.inter(
              color: Colors.grey,
              height: 1.3,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              XFile? image =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                URL url = await FBStorage.uploadGroupBackgroundPhotoToFireStorage(
                    File(image.path), context);
                setState(() {
                  backgroundImageURL = url.url;
                });
                await FBDatabase.setGroupBackgroundPhoto(widget.groupID, backgroundImageURL!);
              }
            },
            child: Container(
              height: getViewportHeight(context) * 0.225,
              width: getViewportWidth(context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey[100],
              ),
              child: Center(
                child: backgroundImageURL != null ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: backgroundImageURL!,
                        fit: BoxFit.cover, width: getViewportWidth(context),
                        height: getViewportHeight(context) * 0.225,
                      )
                    )
                : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[300],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Upload Photo',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a description',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Add some information about your group to get people interested.',
            style: GoogleFonts.inter(
              color: Colors.grey,
              height: 1.3,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            maxLines: 5,
            maxLength: 40,
            onChanged: (value) {
              setState(() {
                description = value;
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              hintText: 'Describe your group',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300)
              ),
            ),
          )
        ],
      ),
    );
  }
}
