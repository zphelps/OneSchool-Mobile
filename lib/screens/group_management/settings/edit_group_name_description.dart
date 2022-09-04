import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/services/fb_database.dart';

import '../../../services/configuration.dart';

class EditGroupNameDescription extends ConsumerStatefulWidget {
  final GroupModel groupModel;
  const EditGroupNameDescription({Key? key, required this.groupModel}) : super(key: key);

  @override
  ConsumerState<EditGroupNameDescription> createState() => _EditGroupNameDescriptionState();
}

class _EditGroupNameDescriptionState extends ConsumerState<EditGroupNameDescription> {

  final _nameTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  bool loading = false;

  validate() {
    if((_nameTextController.text.isNotEmpty && _nameTextController.text != widget.groupModel.name)
        || (_descriptionTextController.text.isNotEmpty && _descriptionTextController.text != widget.groupModel.description)) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _nameTextController.text = widget.groupModel.name;
    _descriptionTextController.text = widget.groupModel.description!;
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
                await FBDatabase.updateGroupInfo(widget.groupModel.id, _nameTextController.text, _descriptionTextController.text);
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _nameTextController,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Group name...',
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
            const SizedBox(height: 20),
            Text(
              'Description',
              style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 18
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _descriptionTextController,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) => setState(() {}),
              maxLength: 40,
              decoration: InputDecoration(
                hintText: 'Group description...',
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
          ],
        ),
      ),
    );
  }
}
