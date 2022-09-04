import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/services/configuration.dart';

class LogoAppBar extends StatelessWidget {

  final String logoURL;
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool sliverAppBar;

  const LogoAppBar({Key? key,
    required this.logoURL,
    required this.title,
    required this.actions,
    this.bottom,
    this.floating = false,
    this.pinned = false,
    this.snap = false,
    required this.sliverAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(sliverAppBar) {
      return SliverAppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(title, style: AppConfiguration.appBarTitleStyle.copyWith(fontSize: 20)),
        toolbarHeight: 55,
        leadingWidth: 55,
        pinned: pinned,
        snap: snap,
        floating: floating,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CachedNetworkImage(
            imageUrl: logoURL,
            width: 45,
            height: 45,
          ),
        ),
        bottom: bottom,
        actions: actions,
      );
    }
    else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(title, style: AppConfiguration.appBarTitleStyle.copyWith(fontSize: 20)),
        toolbarHeight: 55,
        leadingWidth: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CachedNetworkImage(
            imageUrl: logoURL,
            width: 45,
            height: 45,
          ),
        ),
        bottom: bottom,
        actions: actions,
      );
    }

  }
}
