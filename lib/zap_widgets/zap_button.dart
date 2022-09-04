import 'package:flutter/material.dart';

class ZAPButton extends StatefulWidget {

  final Widget child;
  final void Function() onPressed;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final Alignment alignment;
  final BoxBorder? border;

  const ZAPButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(10),
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.border,
  }) : super(key: key);

  @override
  State<ZAPButton> createState() => _ZAPButtonState();
}

class _ZAPButtonState extends State<ZAPButton> {
  double opacity = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        opacity = 0.5;
        setState(() {});
      },
      onTapUp: (TapUpDetails details) {
        opacity = 1.0;
        setState(() {});
      },
      onTapCancel: () {
        opacity = 1.0;
        setState(() {});
      },
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: opacity,
        child: Container(
          alignment: widget.alignment,
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
              border: widget.border,
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
