


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/screens/school_selection/school_selection.dart';

import '../../services/helpers.dart';
import '../../services/routing_helper.dart';
import '../../zap_widgets/zap_button.dart';

class Welcome extends ConsumerStatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  ConsumerState<Welcome> createState() => _SchoolSelectionState();
}

class _SchoolSelectionState extends ConsumerState<Welcome> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: const Text(
          'Student Engage',
          style: TextStyle(
            color: CupertinoColors.activeBlue,
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZAPButton(
                onPressed: () {
                  RoutingUtil.push(context, const SchoolSelection());
                },
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: CupertinoColors.activeBlue,
                width: getViewportWidth(context),
                child: Text(
                  'Find My School',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}