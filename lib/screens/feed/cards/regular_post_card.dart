import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:sea/constants.dart';
import 'package:sea/models/PollChoiceModel.dart';
import 'package:sea/models/PollModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/moderator/moderator.dart';
import 'package:sea/screens/feed/report_post_modal.dart';
import 'package:sea/screens/group_profile/group_profile.dart';
import 'package:sea/screens/messaging/fullscreen_image_viewer.dart';
import 'package:sea/screens/messaging/fullscreen_video_viewer.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/fb_storage.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/widgets/like_comment_buttons.dart';
import 'package:simple_polls/models/poll_models.dart';
import 'package:simple_polls/widgets/polls_widget.dart';

import '../../../models/GroupModel.dart';
import '../../../services/configuration.dart';
import '../../../zap_widgets/ZAP_list_tile.dart';

class RegularPostCard extends ConsumerStatefulWidget {
  final PostModel postModel;
  final bool isMainFeed;
  final SEAUser user;
  final AppConfiguration prefs;
  const RegularPostCard({Key? key, required this.user, required this.postModel, required this.isMainFeed, required this.prefs}) : super(key: key);

  @override
  ConsumerState<RegularPostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<RegularPostCard> {

  GroupModel? groupModel;
  SEAUser? postAuthor;

  getGroup() async {
    final result = await FBDatabase.getGroup(widget.postModel.groupID!);
    if(mounted) {
      setState(() {
        groupModel = result;
      });
    }
  }

  getPostAuthor() async {
    final result = await FBDatabase.getUserData(widget.postModel.authorID);
    if(mounted) {
      setState(() {
        postAuthor = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if(mounted) {
      if(widget.postModel.groupID != null) {
        getGroup();
      }
      if(widget.postModel.groupID == null || !widget.isMainFeed) {
        getPostAuthor();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, //0.35
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZAPListTile(
            onTap: () {
              if(widget.isMainFeed && widget.postModel.groupID != null) {
                RoutingUtil.push(context, GroupProfile(user: widget.user, groupID: widget.postModel.groupID!));
              }
            },
            horizontalTitleGap: 10,
            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            leading: widget.isMainFeed && widget.postModel.groupID != null ?
              CircleNetworkImage(fit: BoxFit.cover, size: const Size(34, 34), imageURL: FBStorage.get200x200Image(groupModel?.profileImageURL ?? USER_PLACEHOLDER_URL))
                : CircleNetworkImage(fit: BoxFit.cover, size: const Size(34, 34), imageURL: FBStorage.get200x200Image(postAuthor?.profileImageURL ?? USER_PLACEHOLDER_URL)),
            title: widget.isMainFeed && widget.postModel.groupID != null ?
            Text(
              groupModel?.name ?? 'Loading...',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ) : Text(
              '${postAuthor?.firstName ?? 'Johnny'} ${postAuthor?.lastName ?? 'Appleseed'}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: [
                    () {
                  if(widget.isMainFeed && widget.postModel.groupID != null) {
                    return Row(
                      children: [
                        Text(
                          'Posted by ',
                          style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        Text(
                          '${widget.user.firstName} ${widget.user.lastName} ',
                          style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        Text('• ', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 10),),
                      ],
                    );
                  }
                  return const SizedBox();
                }(),
                Text(
                  timeAgo(widget.postModel.postedAt),
                  style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () async {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => Wrap(
                      children: const [
                        ReportPostModal(),
                      ],
                    ));
              },
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ),
          if(widget.postModel.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Text(
                widget.postModel.body,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: widget.postModel.imageURL == null ? 18 : 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if(widget.postModel.url != null)
            _urlPreview(widget.postModel.url!),
          if(widget.postModel.pollID != null)
            _buildPoll(widget.postModel.pollID!),
          if(widget.postModel.imageURL != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: Stack(
                  children: [
                    Hero(
                      tag: widget.postModel.imageURL!,
                      child: Material(
                        child: InkWell(
                          onTap: () {
                            if(widget.postModel.videoURL != null) {
                              RoutingUtil.push(context, FullScreenVideoViewer(videoUrl: widget.postModel.videoURL!, prefs: widget.prefs));
                            }
                            else {
                              RoutingUtil.push(context, FullScreenImageViewer(imageUrl: widget.postModel.imageURL!));
                            }
                          },
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: getViewportHeight(context) * 0.5,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    width: getViewportWidth(context),
                                    placeholder: (context, _) => const SizedBox(),
                                    imageUrl: widget.postModel.imageURL!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if(widget.postModel.body.isNotEmpty)
                //   PlatformText(
                //     widget.postModel.body,
                //     style: const TextStyle(
                //       color: Colors.black,
                //       fontSize: 14,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // const Divider(height: 20),
                LikeCommentButtons(postID: widget.postModel.id),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _urlPreview(String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: LinkPreviewGenerator(
        bodyMaxLines: 3,
        cacheDuration: const Duration(days: 7),
        link: url,
        linkPreviewStyle: LinkPreviewStyle.small,
        showGraphic: true,
        borderRadius: 0,
        boxShadow: const [
          BoxShadow(color: Colors.white)
        ],
      ),
    );
  }
  
  Widget _buildPoll(String pollID) {
    final pollAsyncValue = ref.watch(getPollStreamProvider(pollID));
    return pollAsyncValue.when(
      data: (poll) {
        poll.choices.removeWhere((element) => element.choiceText.isEmpty);
        return Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
          child: SimplePollsWidget(
            onSelection: (PollFrameModel model, PollOptions selectedOptionModel) async {
              for(PollChoiceModel choiceModel in poll.choices) {
                if(choiceModel.id == selectedOptionModel.id) {
                  choiceModel.membersWhoSelected.add(FBAuth().getUserID()!);
                  poll.userIDsWhoHaveVoted.add(FBAuth().getUserID()!);
                  break;
                }
              }
              await FBDatabase.updatePoll(poll);
            },
            onReset: (PollFrameModel model) {
              print('Poll has been reset, this happens only in case of editable polls');
            },
            optionsBorderShape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), //Its Default so its not necessary to write this line
            model: PollFrameModel(
              title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  poll.question,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              totalPolls: poll.userIDsWhoHaveVoted.length,
              endTime: DateTime.parse(poll.endDate),
              hasVoted: poll.userIDsWhoHaveVoted.contains(FBAuth().getUserID()!),
              editablePoll: false,
              options: poll.choices.map((e) {
                return PollOptions(label: e.choiceText, pollsCount: e.membersWhoSelected.length, id: e.id);
              }).toList()
            ),
          )
        );
      },
      loading: () => const SizedBox(),
      error: (e,__) => Text(e.toString()),
    );
  }
}
