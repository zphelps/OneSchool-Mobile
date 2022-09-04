import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class LoadingCard extends StatelessWidget {
  final double height;
  const LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SkeletonAnimation(
        shimmerDuration: 750,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10)),
          height: height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }
}