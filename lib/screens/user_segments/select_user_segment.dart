import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/UserSegment.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';

class SelectUserSegment extends StatefulWidget {
  final AppConfiguration prefs;
  final List<UserSegment>? selectedSegments;
  const SelectUserSegment({Key? key, required this.prefs, this.selectedSegments}) : super(key: key);

  @override
  State<SelectUserSegment> createState() => _SelectUserSegmentState();
}

class _SelectUserSegmentState extends State<SelectUserSegment> {

  validate() {
    return _selectSegments.isNotEmpty;
  }

  List<UserSegment>? _segments;
  List<UserSegment> _selectSegments = [];

  final searchController = TextEditingController();

  getUserSegments() async {
    final result = await FBDatabase.getUserSegments();
    if(widget.selectedSegments != null) {
      _selectSegments = widget.selectedSegments!;
    }
    for(var segment in _selectSegments) {
      result.remove(segment);
    }
    setState(() {
      _segments = result;
    });
  }

  @override
  void initState() {
    super.initState();
    print('init');
    getUserSegments();
  }

  @override
  Widget build(BuildContext context) {
    if(_segments != null) {
      _segments!.sort((a,b) => a.name.compareTo(b.name));
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Select User Segment(s)',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            PlatformTextButton(
              onPressed: () async {
                if(validate()) {
                  Navigator.of(context).pop(_selectSegments);
                }
              },
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                    color: validate() ? widget.prefs.getPrimaryColor() : Colors.grey[300],
                    fontSize: 17,
                    fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              // height: _selectSegments.isEmpty ? 0 : 35,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: getViewportWidth(context),
              child: Wrap(
                // padding: const EdgeInsets.only(left: 10),
                // scrollDirection: Axis.horizontal,
                runSpacing: 8,
                children: _selectSegments.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      elevation: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: Colors.grey.shade200,
                      onDeleted: () {
                        setState(() {
                          _selectSegments.remove(e);
                          _segments!.add(e);
                        });
                      },
                      label: Text(
                        e.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            TextFormField(
              decoration: AppConfiguration.inputDecoration1.copyWith(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Search user segments...'
              ),
              controller: searchController,
              onChanged: (_) => setState(() {}),
            ),
            Expanded(
              child: ListView(
                children: _segments!.where((element) => element.name.toLowerCase().contains(searchController.text.toLowerCase())).map((e) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          setState(() {
                            searchController.text = '';
                            _selectSegments.insert(0, e);
                            _segments?.remove(e);
                          });
                        },
                        horizontalTitleGap: 2,
                        title: Text(
                          e.name,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                      ),
                      const Divider(height: 0),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Scaffold(appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Select User Segment(s)',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PlatformTextButton(
            onPressed: () async {
              if(validate()) {
                Navigator.of(context).pop(_selectSegments);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                  color: validate() ? widget.prefs.getPrimaryColor() : Colors.grey[300],
                  fontSize: 17,
                  fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),body: const Center(child: CupertinoActivityIndicator()));
    }
  }
}
