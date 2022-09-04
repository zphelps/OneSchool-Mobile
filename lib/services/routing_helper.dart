
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutingUtil {
  static Future<dynamic> pushAsync(BuildContext context, Widget toPush, {bool fullscreenDialog = false}) async {
    var page = await Future.microtask(() {
      return toPush;
    });
    var route = CupertinoPageRoute(builder: (_) => page, fullscreenDialog: fullscreenDialog);
    return await Navigator.of(context, rootNavigator: true).push(route);
  }

  static void push(context, Widget toPush, {bool fullscreenDialog = false}) {
    Navigator.of(context).push(CupertinoPageRoute(fullscreenDialog: fullscreenDialog, builder: (_) {
      return toPush;
    }));
  }

  static void pushReplacement(context, Widget toPush, {bool fullscreenDialog = false}) {
    Navigator.of(context).pushReplacement(CupertinoPageRoute(fullscreenDialog: fullscreenDialog, builder: (_) {
      return toPush;
    }));
  }

  static void pushReplacementNoAnimation(context, Widget toPush, {bool fullscreenDialog = false}) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => toPush,
        transitionDuration: Duration.zero,
      ),
    );
  }
}