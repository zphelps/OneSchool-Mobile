import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/CommentModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/screens/feed/cards/regular_post_card.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:uuid/uuid.dart';

import '../../zap_widgets/ZAP_list_tile.dart';

class Comments extends ConsumerStatefulWidget {
  final String postID;
  const Comments({Key? key, required this.postID}) : super(key: key);

  @override
  ConsumerState<Comments> createState() => _CommentsState();
}

class _CommentsState extends ConsumerState<Comments> {

  String? newCommentText;

  final _commentTextController = TextEditingController();

  double viewportHeight = 0.75;

  @override
  Widget build(BuildContext context) {
    final postAsyncValue = ref.watch(getPostStreamProvider(widget.postID));
    return postAsyncValue.when(
      data: (post) {
        return AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: getViewportHeight(context) * viewportHeight,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        post.commentCount == null || post.commentCount == 0 ? 'Comments' : '${post.commentCount} ${post.commentCount == 1 ? 'Comment' : 'Comments'}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Divider(height: 0),
                    Expanded(child: _buildCommentList(post.id)),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: _buildCommentBuilder(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }

  Widget _buildCommentList(String postID) {
    final commentsAsyncValue = ref.watch(getPostCommentsStreamProvider(postID));
    return commentsAsyncValue.when(
      data: (comments) {
        if (comments.isEmpty) {
          return Center(
            child: Text(
              'Be the first to comment!',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey
              ),
            )
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 100), //.symmetric(horizontal: 10, vertical: 8),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildCommentCard(comments[index]);
          },
        );
      },
      loading: () => PlatformCircularProgressIndicator(),
      error: (_,__) => const Text('Error', style: TextStyle(color: Colors.black),),
    );
  }

  Widget _buildCommentCard(CommentModel commentModel) {
    final userAsyncValue = ref.watch(getUserStreamProvider(commentModel.authorID));
    return userAsyncValue.when(
      data: (user) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[100],
          ),
          child: ZAPListTile(
            crossAxisAlignment: CrossAxisAlignment.start,
            horizontalTitleGap: 8,
            titleSubtitleGap: 2,
            leading: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(user.profileImageURL),
            ),
            title: Row(
              children: [
                Text(
                  '${user.firstName} ${user.lastName} ',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text('•', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 8),),
                Text(
                  ' ${timeAgo(commentModel.postedAt)}',
                  style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
            subtitle: SizedBox(
              width: getViewportHeight(context) * 0.35,
              child: Text(
                commentModel.body,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error')
    );
  }

  Widget _buildCommentBuilder() {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final uid = FBAuth().getUserID()!;
    final userAsyncValue = ref.watch(getUserStreamProvider(uid));
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.95),
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300))
      ),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      width: getViewportWidth(context),
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        child: Row(
          children: [
            userAsyncValue.when(
              data: (user) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(user.profileImageURL),
                );
              },
              loading: () {
                return const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                );
              },
              error: (_,__) => const Text('Error'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if(hasFocus) {
                    setState(() {
                      viewportHeight = 0.9;
                    });
                  }
                },
                child: TextFormField(
                  maxLines: null,
                  controller: _commentTextController,
                  onChanged: (value) {
                    setState(() {
                      viewportHeight = 0.9;
                      newCommentText = value;
                    });
                  },
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                  decoration: AppConfiguration.inputDecoration1.copyWith(
                    isDense: true,
                    hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    fillColor: Colors.white,
                    hintText: 'Add Comment...'
                  ),
                ),
              ),
            ),
            if((newCommentText ?? '').length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () async {
                    final comment = CommentModel(
                      id: const Uuid().v4(),
                      authorID: uid,
                      postedAt: DateTime.now().toString(),
                      postID: widget.postID,
                      body: newCommentText!,
                    );
                    _commentTextController.text = '';
                    setState(() {
                      newCommentText = '';
                    });
                    await FBDatabase.postComment(comment);
                    await PushNotifications.sendCommentOnPostNotification(widget.postID, comment);
                  },
                  child: Icon(CupertinoIcons.arrow_up_circle_fill, size: 35, color: prefs.getPrimaryColor(),)
                ),
              )
          ],
        ),
      ),
    );
  }
}
