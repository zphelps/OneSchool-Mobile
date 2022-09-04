import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/widgets/circle_network_image.dart';

import '../../services/configuration.dart';
import '../../services/fb_database.dart';
import '../../services/helpers.dart';

class SelectGroup extends StatefulWidget {
  const SelectGroup({Key? key}) : super(key: key);

  @override
  State<SelectGroup> createState() => _SelectGroupState();
}

class _SelectGroupState extends State<SelectGroup> {

  final searchController = TextEditingController();

  List<GroupModel>? groups;

  getGroups() async {
    final result = await FBDatabase.getAllGroupsUserCanPostFrom();
    setState(() {
      groups = result;
    });
  }

  @override
  void initState() {
    super.initState();
    print('init');
    getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Select Group',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: groups == null ? const Center(child: CupertinoActivityIndicator()) : Column(
        children: <Widget>[
          TextFormField(
            decoration: AppConfiguration.inputDecoration1.copyWith(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Search groups...'
            ),
            controller: searchController,
            onChanged: (_) => setState(() {}),
          ),
          Expanded(
            child: ListView(
              children: groups!.where((element) => element.name.toLowerCase().contains(searchController.text.toLowerCase())).map((e) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop(e);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      horizontalTitleGap: 10,
                      title: Text(
                        e.name,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      subtitle: Text(
                        '${e.memberIDs.length} Members | ${e.followerIDs.length} Followers',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                      leading: CircleNetworkImage(
                        imageURL: e.profileImageURL,
                        fit: BoxFit.cover,
                      ),
                      trailing: const Icon(
                        CupertinoIcons.circle,
                        color: Colors.grey,
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
}
