import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sea/models/SEAUser.dart';

import '../../../models/URLModel.dart';
import '../../../services/configuration.dart';
import '../../../services/fb_database.dart';
import '../../../services/fb_storage.dart';
import '../../../widgets/circle_network_image.dart';

class EditUserProfilePhoto extends ConsumerStatefulWidget {
  final SEAUser user;
  const EditUserProfilePhoto({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<EditUserProfilePhoto> createState() => _EditUserProfilePhotoState();
}

class _EditUserProfilePhotoState extends ConsumerState<EditUserProfilePhoto> {
  File? newProfilePhoto;
  File? newBackgroundPhoto;

  bool loading = false;

  final ImagePicker _imagePicker = ImagePicker();

  validate() {
    if(newProfilePhoto != null || newBackgroundPhoto != null) {
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
          'Edit Profile Photo',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
        actions: [
          loading ? const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CupertinoActivityIndicator(),
          ) : PlatformTextButton(
            onPressed: () async {
              if(validate()) {
                setState(() {
                  loading = true;
                });
                if(newProfilePhoto != null) {
                  URL url = await FBStorage.uploadUserProfilePhotoToFireStorage(newProfilePhoto!, context);
                  await FBDatabase.updateUserProfilePhoto(widget.user.id, url.url);
                }
                setState(() {
                  loading = false;
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                  color: validate() ? prefs.getPrimaryColor() : Colors.grey[300],
                  fontSize: 17,
                  fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  newProfilePhoto != null ? ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: Image.file(newProfilePhoto!, height: 125, width: 125, fit: BoxFit.cover),
                  ) : CircleNetworkImage(
                    imageURL: widget.user.profileImageURL,
                    size: const Size(125, 125),
                    fit: BoxFit.cover,
                  ),
                  TextButton(
                    onPressed: () async {
                      XFile? image =
                      await _imagePicker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          newProfilePhoto = File(image.path);
                        });
                      }
                    },
                    child: const Text(
                        'Choose Profile Photo'
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
