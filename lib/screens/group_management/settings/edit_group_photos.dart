import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sea/models/GroupModel.dart';

import '../../../models/URLModel.dart';
import '../../../services/configuration.dart';
import '../../../services/fb_database.dart';
import '../../../services/fb_storage.dart';
import '../../../services/helpers.dart';
import '../../../widgets/circle_network_image.dart';

class EditGroupPhotos extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const EditGroupPhotos({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<EditGroupPhotos> createState() => _EditGroupPhotosState();
}

class _EditGroupPhotosState extends ConsumerState<EditGroupPhotos> {

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
          'Edit Group',
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
                  URL url = await FBStorage.uploadGroupProfilePhotoToFireStorage(newProfilePhoto!, context);
                  await FBDatabase.setGroupProfilePhoto(widget.groupModel.id, url.url);
                }
                if(newBackgroundPhoto != null) {
                  URL url = await FBStorage.uploadGroupBackgroundPhotoToFireStorage(newBackgroundPhoto!, context);
                  await FBDatabase.setGroupBackgroundPhoto(widget.groupModel.id, url.url);
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
                    imageURL: widget.groupModel.profileImageURL,
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
            GestureDetector(
              onTap: () async {
                XFile? image =
                await _imagePicker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    newBackgroundPhoto = File(image.path);
                  });
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
                    child: newBackgroundPhoto != null ?
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          newBackgroundPhoto!,
                          fit: BoxFit.cover, width: getViewportWidth(context),
                          height: getViewportHeight(context) * 0.225,
                        )
                    )
                        : Stack(
                      children: [
                        if(widget.groupModel.backgroundImageURL != null)
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: widget.groupModel.backgroundImageURL!,
                                fit: BoxFit.cover, width: getViewportWidth(context),
                                height: getViewportHeight(context) * 0.225,
                              )
                          ),
                        Center(
                          child: Container(
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
                                  'Upload Background Photo',
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
