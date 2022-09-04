import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/services/configuration.dart';

class GroupConversations extends ConsumerStatefulWidget {
  final String groupID;
  final AppConfiguration prefs;
  const GroupConversations({Key? key, required this.groupID, required this.prefs}) : super(key: key);

  @override
  ConsumerState<GroupConversations> createState() => _GroupConversationsState();
}

class _GroupConversationsState extends ConsumerState<GroupConversations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Group Conversations',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
