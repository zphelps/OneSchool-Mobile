import 'package:flutter/material.dart';

class AppBarCircularActionButton extends StatelessWidget {
  final void Function() onTap;
  final Color? backgroundColor;
  final Icon icon;
  final double? radius;
  const AppBarCircularActionButton({Key? key,
  required this.onTap, required this.backgroundColor, required this.icon, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: radius,
        child: icon,
      ),
    );
  }
}
