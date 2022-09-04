import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/services/configuration.dart';
import 'package:uuid/uuid.dart';

import '../../models/URLModel.dart';
import '../../services/fb_database.dart';
import '../../services/fb_storage.dart';
import '../../widgets/circle_network_image.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../../zap_widgets/zap_button.dart';

class CreateOpponent extends StatefulWidget {
  final AppConfiguration prefs;
  const CreateOpponent({Key? key, required this.prefs}) : super(key: key);

  @override
  State<CreateOpponent> createState() => _CreateOpponentState();
}

class _CreateOpponentState extends State<CreateOpponent> {
  final _opponentNameController = TextEditingController();

  File? opponentLogo;

  final ImagePicker _imagePicker = ImagePicker();

  validateOpponentDetails() {
    if(_opponentNameController.text.isNotEmpty && opponentLogo != null) {
      return true;
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
            'Add Opponent',
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
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              opponentLogo != null ? ClipRRect(
                                borderRadius: BorderRadius.circular(10000),
                                child: Image.file(opponentLogo!, fit: BoxFit.cover, width: 115, height: 115,),
                              ) : const CircleNetworkImage(size: const Size(115, 115), imageURL: 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__480.png', fit: BoxFit.cover,),
                              TextButton(
                                onPressed: () async {
                                  XFile? image =
                                  await _imagePicker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      opponentLogo = File(image.path);
                                    });
                                  }
                                },
                                child: const Text(
                                  'Choose opponent logo'
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            controller: _opponentNameController,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                labelText: 'Opponent Name'
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
                    if(await validateOpponentDetails()) {
                      URL url = await FBStorage.uploadOpponentLogoToFireStorage(
                          opponentLogo!, context);
                      final opponent = OpponentModel(
                        id: const Uuid().v4(),
                        name: _opponentNameController.text,
                        logoURL: url.url,
                      );
                      await FBDatabase.createOpponent(opponent);
                      Navigator.of(context).pop(opponent);
                    }
                  },
                  backgroundColor: (_opponentNameController.text.isNotEmpty) ? widget.prefs.getPrimaryColor() : Colors.grey.shade300,
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
