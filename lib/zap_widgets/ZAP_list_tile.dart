import 'package:flutter/material.dart';

class ZAPListTile extends StatefulWidget {

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final double horizontalTitleGap;
  final double titleSubtitleGap;
  final EdgeInsets contentPadding;
  final CrossAxisAlignment crossAxisAlignment;
  final void Function()? onTap;
  const ZAPListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.horizontalTitleGap = 0,
    this.titleSubtitleGap = 0,
    this.contentPadding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.onTap,
  }) : super(key: key);

  @override
  State<ZAPListTile> createState() => _ZAPListTileState();
}

class _ZAPListTileState extends State<ZAPListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: widget.contentPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            widget.leading ?? const SizedBox(),
            SizedBox(width: widget.horizontalTitleGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.title ?? const SizedBox(),
                SizedBox(height: widget.titleSubtitleGap),
                widget.subtitle ?? const SizedBox(),
              ],
            ),
            const Spacer(),
            widget.trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
