import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircleNetworkImage extends StatelessWidget {
  final String imageURL;
  final Size size;
  final BoxFit? fit;
  const CircleNetworkImage({
    Key? key,
    required this.imageURL,
    this.size = const Size(45, 45),
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: CachedNetworkImage(
        fadeOutDuration: Duration.zero,
        fadeInDuration: Duration.zero,
        // memCacheHeight: 100000,
        // memCacheWidth: 100000,
        // maxHeightDiskCache: 100000,
        // maxWidthDiskCache: 100000,
        cacheKey: imageURL,
        imageUrl: imageURL,
        fit: fit,
        width: size.width,
        height: size.height,
      ),
    );
  }
}
