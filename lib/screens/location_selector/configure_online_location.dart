import 'dart:convert';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapbox_search/colors/color.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:sea/constants.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:uuid/uuid.dart';

import '../../models/LocationModel.dart';
import '../../zap_widgets/zap_button.dart';

class ConfigureOnlineLocation extends StatefulWidget {
  final String? groupID;
  final String creatorID;
  final AppConfiguration prefs;
  const ConfigureOnlineLocation({Key? key,required this.prefs, this.groupID, required this.creatorID}) : super(key: key);

  @override
  State<ConfigureOnlineLocation> createState() => _ConfigureOnlineLocationState();
}

class _ConfigureOnlineLocationState extends State<ConfigureOnlineLocation> {

  final _locationNameController = TextEditingController();
  final _locationURLController = TextEditingController();
  final _locationDetailsController = TextEditingController();

  bool _saveLocation = true;

  String? urlErrorText;

  validateLocationDetails() async {
    if(_locationURLController.text.isNotEmpty) {
      try {
        Metadata? metadata = await AnyLinkPreview.getMetadata(
          link: _locationURLController.text,
          cache: const Duration(days: 7),
        );
        if(metadata != null && _locationNameController.text.isNotEmpty) {
          return true;
        }
      } catch(e) {
        setState(() {
          urlErrorText = 'Invalid URL';
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Add Online Location',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      ZAPListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.black,
                          ),
                        ),
                        horizontalTitleGap: 10,
                        title: Text(
                          'Save Location',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        titleSubtitleGap: 2,
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.625,
                          child: Text(
                            'Saving this location will make it easier to create future events.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        trailing: CupertinoSwitch(
                            value: _saveLocation,
                            onChanged: (save) {
                              setState(() {
                                _saveLocation = save;
                              });
                            }
                        ),
                      ),
                      const Divider(height: 35),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          controller: _locationNameController,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                              hintText: '',
                              border: InputBorder.none,
                              labelText: 'Name'
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          controller: _locationURLController,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ),
                          autocorrect: false,
                          decoration: const InputDecoration(
                              hintText: '',
                              border: InputBorder.none,
                              labelText: 'URL'
                          ),
                        ),
                      ),
                      if(urlErrorText != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              urlErrorText!,
                              style: GoogleFonts.inter(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          maxLines: null,
                          controller: _locationDetailsController,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            labelText: 'Notes',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: SafeArea(
              child: ZAPButton(
                onPressed: () async {
                  if(await validateLocationDetails()) {
                    final location = LocationModel(
                      id: const Uuid().v4(),
                      groupID: widget.groupID,
                      creatorID: widget.creatorID,
                      name: _locationNameController.text,
                      formattedAddress: null,
                      description: _locationDetailsController.text.isEmpty ? null : _locationDetailsController.text,
                      url: _locationURLController.text,
                      isOnline: true,
                      latLng: null,
                      mapStaticImageURL: null,
                    );
                    if(_saveLocation) {
                      await FBDatabase.createLocation(location);
                    }
                    Navigator.of(context).pop(location);
                  }
                },
                backgroundColor: (_locationNameController.text.isNotEmpty && _locationURLController.text.isNotEmpty) ? widget.prefs.getPrimaryColor() : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Save',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
