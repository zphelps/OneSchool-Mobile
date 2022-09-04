import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/screens/comments/comments.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:uuid/uuid.dart';

import '../models/CommentModel.dart';
import '../models/PostModel.dart';
import '../zap_widgets/zap_button.dart';

class LikeCommentButtons extends ConsumerStatefulWidget {
  final String postID;
  const LikeCommentButtons({Key? key, required this.postID}) : super(key: key);

  @override
  ConsumerState<LikeCommentButtons> createState() => _LikeCommentButtonsState();
}

class _LikeCommentButtonsState extends ConsumerState<LikeCommentButtons> {

  @override
  Widget build(BuildContext context) {
    final uid = FBAuth().getUserID()!;
    final postAsyncValue = ref.watch(getPostStreamProvider(widget.postID));
    return Row(
      children: [
        postAsyncValue.when(
          data: (post) {
            bool hasLikedPost = userHasLikedPost(post, uid);
            return Expanded(
              child: ZAPButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: BorderRadius.circular(5),
                backgroundColor: Colors.red.withOpacity(0.075),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  if(hasLikedPost) {
                    await FBDatabase.unlikePost(post.id, uid);
                  }
                  else {
                    await FBDatabase.likePost(post.id, uid);
                    await PushNotifications.sendLikedPostNotification(post);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasLikedPost ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likes == null || post.likes!.isEmpty ? 'Like' : post.likes!.length}',
                      style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_,__) => const Text('Error'),
        ),
        const SizedBox(width: 8),
        postAsyncValue.when(
          data: (post) {
            return Expanded(
              child: ZAPButton(
                padding: const EdgeInsets.symmetric(vertical: 10),
                borderRadius: BorderRadius.circular(5),
                backgroundColor: Colors.blue.withOpacity(0.075),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent, context: context,
                    builder: (context) => Wrap(
                      children: [
                        Comments(postID: widget.postID),
                      ],
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 14,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentCount == null || post.commentCount == 0 ? 'Comment' : post.commentCount}',
                      style: GoogleFonts.inter(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_,__) => const Text('Error'),
        ),
      ],
    );
  }
}
