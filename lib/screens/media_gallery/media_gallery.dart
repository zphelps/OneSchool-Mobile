import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/screens/messaging/fullscreen_image_viewer.dart';
import 'package:sea/screens/messaging/fullscreen_video_viewer.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:tuple/tuple.dart';

import '../../services/fb_database.dart';
import '../feed/feed_bloc.dart';

class MediaGallery extends ConsumerStatefulWidget {
  final Tuple5<String?, String?, bool?, bool, SEAUser?> feedQuery;
  final AppConfiguration prefs;
  final bool showAppBar;
  const MediaGallery({Key? key, required this.feedQuery, required this.prefs, this.showAppBar = false}) : super(key: key);

  @override
  ConsumerState<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends ConsumerState<MediaGallery> {

  @override
  void initState() {
    super.initState();
    final fp = ref.read(mediaFeedProvider);

    if(mounted){
      fp.data.isNotEmpty ? print('data already loaded') :
      fp.getData(mounted, widget.feedQuery);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Media Gallery', style: GoogleFonts.inter(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w700),),
      ) : null,
      body: _photoMediaList(),
    );
  }

  Widget _photoMediaList() {
    final cb = ref.watch(mediaFeedProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(mediaFeedProvider).onRefresh(mounted, widget.feedQuery);
      },
      child: cb.hasData == false
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
              child: Text(
                'No media to display.',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey
                ),
              )
      ),
            ],
          )
          : GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        key: PageStorageKey(widget.feedQuery),
        itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 5,
        itemBuilder: (_, int index) {
          if (index < cb.data.length) {
            return InkWell(
              onTap: () {
                if(cb.data[index].videoURL != null) {
                  context.pushTransparentRoute(FullScreenVideoViewer(prefs: widget.prefs, videoUrl: cb.data[index].videoURL!));
                }
                else {
                  context.pushTransparentRoute(FullScreenImageViewer(imageUrl: cb.data[index].imageURL!));
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: cb.data[index].imageURL!,
                      child: CachedNetworkImage(imageUrl: cb.data[index].imageURL!, fit: BoxFit.cover),
                    ),
                  ),
                  if(cb.data[index].videoURL != null)
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                    )
                ],
              )
            );
          }
          return Opacity(
            opacity: cb.isLoading ? 1.0 : 0.0,
            child: cb.lastVisible == null
                ? const SizedBox() //LoadingCard(height: 250)
                : const Center(
              child: SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: CupertinoActivityIndicator()),
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
      ),
    );
  }
}
