import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/PollChoiceModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/PrivacyLevel.dart';
import 'package:sea/models/UserSegment.dart';
import 'package:sea/moderator/text_moderation_alert.dart';
import 'package:sea/screens/admin/video_editor.dart';
import 'package:sea/screens/feed/feed_bloc.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/screens/groups/select_group.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../constants.dart';
import '../../models/ChatVideoContainerModel.dart';
import '../../models/PollModel.dart';
import '../../moderator/image_moderation_alert.dart';
import '../../moderator/moderator.dart';
import '../../services/configuration.dart';
import '../../services/fb_database.dart';
import '../../services/fb_storage.dart';
import '../user_segments/select_user_segment.dart';

class CreatePost extends ConsumerStatefulWidget {
  final GroupModel? groupModel;
  final bool addPoll;
  const CreatePost({Key? key, this.groupModel, this.addPoll = false}) : super(key: key);

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {

  PostPrivacy _postPrivacy = PostPrivacy.members;

  final _textController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  GroupModel? groupModel;
  List<UserSegment>? audience;

  File? _image;
  File? _video;
  File? _videoThumbnail;

  String? _giphyGifURL;

  String? _url;

  bool _buildingPoll = false;
  final _pollQuestionController = TextEditingController();

  final List<PollChoiceModel> _pollChoices = [
    PollChoiceModel(id: const Uuid().v4(), choiceText: '', membersWhoSelected: [])
  ];

  bool _posting = false;

  validate() {
    if(_textController.text.isNotEmpty
        || _image != null || (_videoThumbnail != null && _video != null)
        || (_buildingPoll == true && _pollChoices.length >=3 && _pollQuestionController.text.isNotEmpty)) {
      return true;
    }
    return false;
  }

  post() async {
    setState(() {
      _posting = true;
    });
    HapticFeedback.mediumImpact();

    String? imageURL;
    if(_image != null) {
      final result = await FBStorage.uploadPostPhotoToFireStorage(
          _image!, context);
      imageURL = result.url;
    }

    ChatVideoContainer? videoContainer;
    if(_video != null && _videoThumbnail != null) {
      videoContainer = await FBStorage.uploadPostVideoToFireStorage(
          _video!, context);
      imageURL = videoContainer.thumbnailUrl;
    }

    if(_giphyGifURL != null) {
      imageURL = _giphyGifURL!;
    }

    PollModel? poll;
    if(_buildingPoll) {
      poll = PollModel(
        id: const Uuid().v4(),
        question: _pollQuestionController.text,
        choices: _pollChoices,
        userIDsWhoHaveVoted: const [],
        endDate: DateTime.now().add(const Duration(days: 10)).toString()
      );
      await FBDatabase.createPoll(poll);
    }

    final postModel = PostModel(
      id: const Uuid().v4(),
      body: _textController.text,
      title: null,
      postedAt: DateTime.now().toString(),
      pollID: poll?.id,
      eventID: null,
      gameID: null,
      imageURL: imageURL,
      videoURL: videoContainer?.videoUrl.url,
      containsMedia: imageURL != null || videoContainer?.videoUrl.url != null ? true : false,
      url: _url,
      likes: null,
      commentCount: null,
      authorID: FBAuth().getUserID()!,
      isArticle: false,
      isAnnouncement: false,
      userSegmentIDs: audience?.map((e) => e.id).toList(),
      groupID: groupModel?.id,
      privacyLevel: PrivacyLevel(
        isVisibleToFollowers: _postPrivacy == PostPrivacy.public || _postPrivacy == PostPrivacy.followers ? true : false,
        isVisibleToMembers: true,
        isVisibleToPublic: _postPrivacy == PostPrivacy.public ? true : false,
      ),
    );

    if(imageURL != null) {
      final imageResponse = await Moderator.evaluateImageInput(imageURL);
      if(imageResponse != null && (imageResponse.isImageRacyClassified || imageResponse.isImageAdultClassified)) {
        // ignore: use_build_context_synchronously
        await RoutingUtil.pushAsync(context, ImageModerationAlert(
          moderatorResponse: imageResponse,
          proceedAnywayLabel: 'Post Anyway',
          proceedAnywayAction: () async {
            Navigator.of(context).pop();
            setState(() {
              _posting = true;
            });
            await FBDatabase.createPost(postModel);
            await PushNotifications.sendNewPostNotification(postModel, groupModel, audience);
            setState(() {
              _posting = false;
            });
            Navigator.of(context).pop();
            ref.watch(groupFeedProvider).onRefresh(mounted, FeedQuery(isMainFeed: false, uid: FBAuth().getUserID()!));
          },
        ), fullscreenDialog: true);
        setState(() {
          _posting = false;
        });
        return;
      }
    }

    final bodyResponse = await Moderator.evaluateTextInput(postModel.body);

    if(bodyResponse != null && bodyResponse.reviewRecommended) {
      // ignore: use_build_context_synchronously
      await RoutingUtil.pushAsync(context, TextModerationAlert(
        moderatorResponse: bodyResponse,
        proceedAnywayLabel: 'Post Anyway',
        proceedAnywayAction: () async {
          Navigator.of(context).pop();
          setState(() {
            _posting = true;
          });
          await FBDatabase.createPost(postModel);
          await PushNotifications.sendNewPostNotification(postModel, groupModel, audience);
          setState(() {
            _posting = false;
          });
          Navigator.of(context).pop();
          ref.watch(groupFeedProvider).onRefresh(mounted, FeedQuery(isMainFeed: false, uid: FBAuth().getUserID()!));
        },
      ), fullscreenDialog: true);
      setState(() {
        _posting = false;
      });
      return;
    }
    else {
      await FBDatabase.createPost(postModel);
      await PushNotifications.sendNewPostNotification(postModel, groupModel, audience);
      setState(() {
        _posting = false;
      });
      Navigator.of(context).pop();
      ref.watch(groupFeedProvider).onRefresh(mounted, FeedQuery(isMainFeed: false, uid: FBAuth().getUserID()!));
    }
  }

  @override
  void initState() {
    super.initState();
    if(widget.groupModel != null) {
      groupModel = widget.groupModel;
    }
    if(widget.addPoll) {
      _buildingPoll = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          groupModel != null ? 'Post [${groupModel!.name}]' : 'New Post',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async => validate() ? await post() : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: validate() ? prefs.getPrimaryColor() : Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: _posting ? const CupertinoActivityIndicator() : Center(
                child: Text(
                  'Post',
                  style: GoogleFonts.inter(
                    color: validate() ? Colors.white : Colors.grey[300],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: getViewportHeight(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostScopeSelector(ref, prefs),
                  if(!_buildingPoll)
                    TextFormField(
                      onChanged: (value) { setState(() {}); },
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        hintText: _image != null ? 'Say something about this image...' : 'Write something...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 0)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 0)
                        ),
                      ),
                    ),
                  if(_buildingPoll)
                    _pollBuilder(),
                  if(_giphyGifURL != null)
                    _gifPreview(),
                  if(_image != null)
                    _imagePreview(),
                  if(_videoThumbnail != null)
                    _videoPreview(prefs),
                  if(_url != null)
                    _urlPreview(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  height: 50,
                  width: getViewportWidth(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: _photoActionSelected,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: _videoActionSelected,
                        icon: const Icon(
                          Icons.video_camera_back_outlined,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final gif = await GiphyGet.getGif(
                              context: context, //Required
                              apiKey: GIPHY_KEY, //Required.
                              lang: GiphyLanguage.english, //Optional - Language for query.
                              randomID: "abcd", // Optional - An ID/proxy for a specific user.
                              tabColor:Colors.teal, // Optional- default accent color.
                              modal: false
                          );
                          setState(() {
                            _giphyGifURL = 'https://media.giphy.com/media/${gif!.embedUrl!.split('/').last}/giphy.webp';
                            _image = null;
                            _videoThumbnail = null;
                            _video = null;
                          });
                        },
                        icon: const Icon(
                          Icons.gif_box_outlined,
                          color: Colors.purple,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final fromAddLink = await RoutingUtil.pushAsync(context, const AddLink(), fullscreenDialog: true);
                          if(fromAddLink != null) {
                            setState(() {
                              _url = fromAddLink;
                              _image = null;
                              _video = null;
                              _videoThumbnail = null;
                              _giphyGifURL = null;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.link,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _buildingPoll = !_buildingPoll;
                        }),
                        icon: const Icon(
                          Icons.poll_outlined,
                          color: Colors.orange,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPostScopeSelector(WidgetRef ref, AppConfiguration prefs) {
    final userAsyncValue = ref.watch(getUserStreamProvider(FBAuth().getUserID()!));
    return userAsyncValue.when(
      data: (user) {
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          horizontalTitleGap: 10,
          leading: CircleNetworkImage(
            imageURL: user.profileImageURL,
            size: const Size(45, 45),
            fit: BoxFit.cover,
          ),
          title: Text(
            '${user.firstName} ${user.lastName}',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          // titleSubtitleGap: 5,
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              runSpacing: 5,
              children: [
                _audienceSelector(prefs),
                if(groupModel != null)
                  _privacyChipSelector(prefs),
              ],
            )
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }

  Widget _audienceSelector(AppConfiguration prefs) {
    return Wrap(
      runSpacing: 4,
      children: [
        if(audience != null && audience!.isNotEmpty)
          for(var item in audience!)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6)
                ],
              ),
            ),
        GestureDetector(
          onTap: widget.groupModel != null ? (){} : () async {
            final result = await RoutingUtil.pushAsync(context, fullscreenDialog: true, Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey[50],
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Audience',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.white
                      ),
                      child: ListTile(
                        onTap: () async {
                          final result = await RoutingUtil.pushAsync(context, const SelectGroup());
                          if(result != null) {
                            Navigator.of(context).pop(result);
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.group,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          'Group',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Associate or limit access to this post to followers or members of specific group.',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.white
                      ),
                      child: ListTile(
                        onTap: () async {
                          final result = await RoutingUtil.pushAsync(context, SelectUserSegment(prefs: prefs, selectedSegments: audience));
                          if(result != null) {
                            Navigator.of(context).pop(result);
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.groups,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          'User Segment',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Limit visibility of this post to one or more user segments.',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
            if(result != null && result is List<UserSegment>) {
              setState(() {
                audience = result;
                groupModel = null;
              });
            }
            else if(result != null && result is GroupModel) {
              setState(() {
                groupModel = result;
                audience = null;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                Icon(
                  audience != null && audience!.isNotEmpty ? Icons.edit : Icons.groups,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  audience != null && audience!.isNotEmpty ? 'Edit Audience' : groupModel != null ? groupModel!.name : 'Select Audience',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                (audience != null && audience!.isNotEmpty) || widget.groupModel != null ? const SizedBox(width: 6) : Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _privacyChipSelector(AppConfiguration prefs) {
    String? chipText;
    IconData? iconData;
    if(_postPrivacy == PostPrivacy.members) {
      chipText = 'Members only';
      iconData = Icons.lock;
    }
    else if(_postPrivacy == PostPrivacy.followers) {
      chipText = 'Members & Followers';
      iconData = Icons.group;
    }
    else if(_postPrivacy == PostPrivacy.public) {
      chipText = 'Public';
      iconData = Icons.language;
    }
    return GestureDetector(
      onTap: () => groupModel!.isPrivate ? null : RoutingUtil.pushAsync(context, _selectPostPrivacyModal(prefs), fullscreenDialog: true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            Icon(
              iconData!,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              chipText!,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            groupModel!.isPrivate ? const SizedBox(width: 6) : Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectPostPrivacyModal(AppConfiguration prefs) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Edit Audience',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who can see this post?',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'This post will appear on the main feed, group profile, and search results.',
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
            const Divider(height: 30),
            InkWell(
              onTap: () {
                setState(() {
                  _postPrivacy = PostPrivacy.public;
                });
                Navigator.of(context).pop();
              },
              child: ZAPListTile(
                leading: const Icon(
                  Icons.language,
                  size: 30,
                  color: Colors.black,
                ),
                title: Text(
                  'Public',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                titleSubtitleGap: 1,
                crossAxisAlignment: CrossAxisAlignment.start,
                horizontalTitleGap: 10,
                subtitle: SizedBox(
                  width: getViewportWidth(context) * 0.65,
                  child: Text(
                    "Anyone can view this post",
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                trailing: _postPrivacy == PostPrivacy.public ?
                Icon(Icons.radio_button_checked, color: prefs.getPrimaryColor()) :
                const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
              ),
            ),
            const Divider(height: 25),
            InkWell(
              onTap: () {
                setState(() {
                  _postPrivacy = PostPrivacy.followers;
                });
                Navigator.of(context).pop();
              },
              child: ZAPListTile(
                leading: const Icon(
                  Icons.group,
                  size: 30,
                  color: Colors.black,
                ),
                title: Text(
                  'Followers & Members',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                titleSubtitleGap: 1,
                crossAxisAlignment: CrossAxisAlignment.start,
                horizontalTitleGap: 10,
                subtitle: SizedBox(
                  width: getViewportWidth(context) * 0.65,
                  child: Text(
                    "Both followers and members of this group can view this post",
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                trailing: _postPrivacy == PostPrivacy.followers ?
                Icon(Icons.radio_button_checked, color: prefs.getPrimaryColor()) :
                const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
              ),
            ),
            const Divider(height: 25),
            InkWell(
              onTap: () {
                setState(() {
                  _postPrivacy = PostPrivacy.members;
                });
                Navigator.of(context).pop();
              },
              child: ZAPListTile(
                leading: const Icon(
                  Icons.lock,
                  size: 30,
                  color: Colors.black,
                ),
                title: Text(
                  'Members Only',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                titleSubtitleGap: 1,
                crossAxisAlignment: CrossAxisAlignment.start,
                horizontalTitleGap: 10,
                subtitle: SizedBox(
                  width: getViewportWidth(context) * 0.65,
                  child: Text(
                    "Only members of this group can view this post",
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                trailing: _postPrivacy == PostPrivacy.members ?
                Icon(Icons.radio_button_checked, color: prefs.getPrimaryColor()) :
                const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 85),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Image.file(_image!),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              setState(() {
                _image = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6)
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _videoPreview(AppConfiguration prefs) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            final fromEditor = await RoutingUtil.pushAsync(context, VideoEditor(file: _video!));
            if(fromEditor != null) {
              setState(() {
                _video = fromEditor;
              });
              final uint8list = await VideoThumbnail.thumbnailFile(
                  video: _video!.path,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.PNG);
              setState(() {
                _videoThumbnail = File(uint8list!);
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 85),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.black.withOpacity(0.5),
            ),
            child: Image.file(_videoThumbnail!),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () async {
              final fromEditor = await RoutingUtil.pushAsync(context, VideoEditor(file: _video!));
              if(fromEditor != null) {
                setState(() {
                  _video = fromEditor;
                });
                final uint8list = await VideoThumbnail.thumbnailFile(
                    video: _video!.path,
                    thumbnailPath: (await getTemporaryDirectory()).path,
                    imageFormat: ImageFormat.PNG);
                setState(() {
                  _videoThumbnail = File(uint8list!);
                });
              }
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: prefs.getPrimaryColor(),
                    borderRadius: BorderRadius.circular(10000)
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              setState(() {
                _videoThumbnail = null;
                _video = null;
              });
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(30, 10, 10, 30),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6)
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gifPreview() {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 85),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.black.withOpacity(0.5),
          ),
          child: SizedBox(
            width: getViewportWidth(context),
            child: CachedNetworkImage(
              imageUrl: _giphyGifURL!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              setState(() {
                _giphyGifURL = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6)
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _photoActionSelected() {
    final action = CupertinoActionSheet(
      message: const Text(
        'Select Media',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
            await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setState(() {
                _image = File(image.path);
                _video = null;
                _videoThumbnail = null;
              });
            }
          },
          child: const Text('Image from Gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
            await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              setState(() {
                _image = File(image.path);
                _video = null;
                _videoThumbnail = null;
              });
              // URL url = await FBStorage.uploadChatImageToFireStorage(
              //     File(image.path), context);
            }
          },
          child: const Text('Take a Photo'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _videoActionSelected() {
    final action = CupertinoActionSheet(
      message: const Text(
        'Select Media',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              final uint8list = await VideoThumbnail.thumbnailFile(
                  video: galleryVideo.path,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.PNG);
              setState(() {
                _video = File(galleryVideo.path);
                _videoThumbnail = File(uint8list!);
                _image = null;
              });
            }
          },
          child: const Text('Video from Gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo = await _imagePicker.pickVideo(source: ImageSource.camera);
            if (galleryVideo != null) {
              final uint8list = await VideoThumbnail.thumbnailFile(
                  video: galleryVideo.path,
                  thumbnailPath: (await getTemporaryDirectory()).path,
                  imageFormat: ImageFormat.PNG);
              setState(() {
                _video = File(galleryVideo.path);
                _videoThumbnail = File(uint8list!);
                _image = null;
              });
            }
          },
          child: const Text('Take a Video'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Widget _urlPreview() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: LinkPreviewGenerator(
            bodyMaxLines: 3,
            cacheDuration: const Duration(milliseconds: 1),
            link: _url!,
            linkPreviewStyle: LinkPreviewStyle.large,
            showGraphic: true,
            borderRadius: 0,
            boxShadow: const [
              BoxShadow(color: Colors.white)
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: InkWell(
            onTap: () {
              setState(() {
                _url = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6)
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pollBuilder() {
    return SizedBox(
      width: getViewportWidth(context),
      child: Column(
        children: [
          TextFormField(
            onChanged: (value) { setState(() {}); },
            maxLines: null,
            controller: _pollQuestionController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              hintText: 'Ask a question...',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white, width: 0)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white, width: 0)
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: _pollChoices.length,
            itemBuilder: (context, index) {
              final controller = TextEditingController();
              controller.text = _pollChoices[index].choiceText;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if(!hasFocus) {
                      setState(() {
                        _pollChoices[index].choiceText = controller.text;
                        _pollChoices.add(PollChoiceModel(id: const Uuid().v4(), choiceText: '', membersWhoSelected: const []));
                      });
                    }
                  },
                  child: TextFormField(
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    controller: controller,
                    style: GoogleFonts.inter(
                      fontWeight: _pollChoices[index].choiceText.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        _pollChoices[index].choiceText.isNotEmpty ? Icons.check_box_outline_blank : Icons.add,
                      ),
                      suffixIcon: _pollChoices[index].choiceText.isNotEmpty ? IconButton(
                        onPressed: () {
                          setState(() {
                            _pollChoices.removeAt(index);
                          });
                        },
                        splashRadius: 20,
                        icon: const Icon(
                          Icons.close,
                        ),
                      ) : const SizedBox(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      hintText: 'Add a poll option....',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 0)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white, width: 0)
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

enum PostPrivacy {
  public,
  members,
  followers,
}

class AddLink extends StatefulWidget {
  const AddLink({Key? key}) : super(key: key);

  @override
  State<AddLink> createState() => _AddLinkState();
}

class _AddLinkState extends State<AddLink> {

  String? url;

  final _urlTextController = TextEditingController();

  String? hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter url';
    }
    else if (!regExp.hasMatch(value)) {
      return 'Please enter valid url';
    }
    return null;
  }

  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Add a link',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 17
          ),
        ),
        actions: [
          if(url != null)
            PlatformTextButton(
              onPressed: () async {
                // We will use this to build our own custom UI
                Metadata? _metadata = await AnyLinkPreview.getMetadata(
                  link: url!,
                  cache: const Duration(days: 7),
                );
                if(_metadata != null) {
                  Navigator.of(context).pop(url!);
                }
                else {
                  setState(() {
                    _errorText = 'Not a valid url';
                  });
                }
              },
              child: Text(
                'Add',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16
                ),
              ),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _urlTextController,
              onChanged: (value) {
                if(hasValidUrl(value) == null) {
                  setState(() {
                    url = value;
                  });
                }
                else {
                  setState(() {
                    url = null;
                  });
                }
              },
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Enter valid url...',
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
              ),
            ),
            if(_errorText != null)
              Text(_errorText!, style: GoogleFonts.inter(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

