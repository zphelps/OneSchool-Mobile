import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sea/main.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/models/MessageModel.dart';
import 'package:sea/screens/messaging/conversation_details.dart';
import 'package:sea/services/fb_messaging.dart';
import 'package:sea/services/fb_storage.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../models/ChatVideoContainerModel.dart';
import '../../models/SEAUser.dart';
import '../../models/URLModel.dart';
import '../../services/configuration.dart';
import '../../services/fb_auth.dart';
import '../../services/fb_database.dart';
import '../../services/helpers.dart';
import '../../zap_widgets/zap_button.dart';
import 'fullscreen_image_viewer.dart';
import 'fullscreen_video_viewer.dart';

class ConversationView extends ConsumerStatefulWidget {
  final ConversationModel conversationModel;
  final bool newConversation;
  const ConversationView({Key? key, required this.conversationModel, this.newConversation = false}) : super(key: key);

  @override
  ConsumerState<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends ConsumerState<ConversationView> {

  String newMessageText = '';

  final _messageTextController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? imagePreviewURL;

  List<SEAUser>? recipients;

  getRecipients() async {
    final result = await FBDatabase.getManyUsers(widget.conversationModel.recipients);
    result.removeWhere((element) => element.id == FBAuth().getUserID()!);
    setState(() {
      recipients = result;
    });
  }

  @override
  void initState() {
    super.initState();
    getRecipients();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size(getViewportWidth(context), 55),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              iconTheme: const IconThemeData(color: Colors.black),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leadingWidth: 20,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: IconButton(
                    onPressed: () => RoutingUtil.push(context, ConversationDetails(conversationID: widget.conversationModel.id)),
                    icon: Icon(
                      CupertinoIcons.info,
                      size: 26,
                      color: prefs.getPrimaryColor(),
                    ),
                  ),
                )
              ],
              title: ZAPListTile(
                horizontalTitleGap: 10,
                leading: recipients == null ? const CupertinoActivityIndicator() : CircleNetworkImage(
                  fit: BoxFit.cover,
                  imageURL: widget.conversationModel.isGroupConversation ? widget.conversationModel.imageURL! : recipients!.first.profileImageURL,
                ),
                title: recipients == null ? const CupertinoActivityIndicator() : Text(
                  widget.conversationModel.isGroupConversation ? widget.conversationModel.name! : '${recipients!.first.firstName} ${recipients!.first.lastName}',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black
                  ),
                ),
              )
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList(prefs, widget.conversationModel.isGroupConversation)),
          _messageBuilder(widget.conversationModel, recipients ?? [], prefs)
        ],
      ),
    );
  }

  Widget _buildMessagesList(AppConfiguration prefs, bool isGroupChat) {
    return PaginateFirestore(
      reverse: true,
      itemsPerPage: 5,
      onEmpty: Text('Beginning of your legendary conversation...',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: Colors.grey,
          height: 1.5,
          fontSize: 16,
          fontWeight: FontWeight.w600
      )),
      padding: const EdgeInsets.only(bottom: 15),
      //item builder type is compulsory.
      itemBuilder: (context, documentSnapshots, index) {
        final message = MessageModel.fromMap(documentSnapshots[index].data() as Map<String, dynamic>?, documentSnapshots[index].id);
        if(message.senderID == FBAuth().getUserID()!) {
          bool didSendMessageBefore = index+1 >= documentSnapshots.length ? false
              : MessageModel.fromMap(documentSnapshots[index+1].data() as Map<String, dynamic>?, documentSnapshots[index].id).senderID
              == message.senderID;
          bool didSendMessageAfter = index == 0 ? false
              : MessageModel.fromMap(documentSnapshots[index-1].data() as Map<String, dynamic>?, documentSnapshots[index].id).senderID
              == message.senderID;
          return _myMessage(message, didSendMessageBefore, didSendMessageAfter, prefs);
        }
        else {
          bool didSendMessageBefore = index+1 >= documentSnapshots.length ? false
              : MessageModel.fromMap(documentSnapshots[index+1].data() as Map<String, dynamic>?, documentSnapshots[index].id).senderID
              == message.senderID;
          bool didSendMessageAfter = index == 0 ? false
              : MessageModel.fromMap(documentSnapshots[index-1].data() as Map<String, dynamic>?, documentSnapshots[index].id).senderID
              == message.senderID;
          return _recipientMessage(prefs, message, didSendMessageBefore, didSendMessageAfter, isGroupChat);
        }
      },
      // orderBy is compulsory to enable pagination
      query: FirebaseFirestore.instance.collection('tenants')
          .doc(FBDatabase.tenantID).collection('conversations')
          .doc(widget.conversationModel.id).collection('messages')
          .orderBy('createdAt', descending: true),
      //Change types accordingly
      itemBuilderType: PaginateBuilderType.listView,
      // to fetch real-time data
      isLive: true,
    );
  }

  Widget _myMessage(MessageModel messageModel, bool didSendMessageBefore, bool didSendMessageAfter, AppConfiguration prefs) {
    if(messageModel.imageURL != null || messageModel.videoURL != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if(messageModel.videoURL == null) {
                      RoutingUtil.push(context, FullScreenImageViewer(imageUrl: messageModel.imageURL!));
                    }
                  },
                  child: Hero(
                    tag: messageModel.imageURL!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        memCacheWidth: 3000,
                        memCacheHeight: 3000,
                        width: getViewportWidth(context) * 0.8,
                        imageUrl: messageModel.imageURL!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Image.asset('assets/img_placeholder'
                                '.png'),
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/error_image'
                                '.png'),
                      ),
                    ),
                  ),
                ),
                if(messageModel.videoURL != null)
                  Positioned.fill(
                    child: Center(
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: 'hola',
                        backgroundColor: prefs.getPrimaryColor(),
                        onPressed: () => RoutingUtil.push(context, FullScreenVideoViewer(prefs: prefs, videoUrl: messageModel.videoURL!)),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      );
    }
    else {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, didSendMessageBefore ? 2 : 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: getViewportWidth(context) * 0.85,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: prefs.getPrimaryColor(),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: didSendMessageBefore ? const Radius.circular(5) : const Radius.circular(18),
                          bottomLeft: const Radius.circular(18),
                          bottomRight: didSendMessageAfter ? const Radius.circular(5) : const Radius.circular(18),
                        )
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Text(
                      messageModel.body,
                      textWidthBasis: TextWidthBasis.longestLine,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if(!didSendMessageAfter)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  DateFormat('jm').format(DateTime.parse(messageModel.createdAt)),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
          ],
        ),
      );
    }
  }

  Widget _recipientMessage(AppConfiguration prefs, MessageModel messageModel, bool didSendMessageBefore, bool didSendMessageAfter, bool isGroupChat) {
    final recipientAsyncValue = ref.watch(getUserStreamProvider(messageModel.senderID));
    if(messageModel.imageURL != null || messageModel.videoURL != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: !didSendMessageAfter ? 10 : 34),
            if(!didSendMessageAfter)
              recipientAsyncValue.when(
                data: (recipient) {
                  return CircleNetworkImage(fit: BoxFit.cover, imageURL: recipient.profileImageURL, size: const Size(24, 24));
                },
                loading: () => CircleAvatar(radius: 12, backgroundColor: Colors.grey[100]),
                error: (_,__) => const Text('Error')
              ),
            const SizedBox(width: 6),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if(messageModel.videoURL == null) {
                      RoutingUtil.push(context, FullScreenImageViewer(imageUrl: messageModel.imageURL!));
                    }
                  },
                  child: Hero(
                    tag: messageModel.imageURL!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        memCacheWidth: 3000,
                        memCacheHeight: 3000,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        width: getViewportWidth(context) * 0.8,
                        imageUrl: messageModel.imageURL!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Image.asset('assets/img_placeholder'
                                '.png'),
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/error_image'
                                '.png'),
                      ),
                    ),
                  ),
                ),
                if(messageModel.videoURL != null)
                  Positioned.fill(
                    child: Center(
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: 'hola',
                        backgroundColor: prefs.getPrimaryColor(),
                        onPressed: () => RoutingUtil.push(context, FullScreenVideoViewer(prefs: prefs, videoUrl: messageModel.videoURL!)),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      );
    }
    else {
      return Padding(
        padding: EdgeInsets.fromLTRB(didSendMessageAfter ? 34 : 10, didSendMessageBefore ? 2 : 20, 0, 0),
        child: recipientAsyncValue.when(
            data: (recipient) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(isGroupChat && !didSendMessageBefore)
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: didSendMessageAfter ? 10 : 34, bottom: 2),
                      child: Text(
                        '${recipient.firstName} ${recipient.lastName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(!didSendMessageAfter)
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 12,
                          backgroundImage: NetworkImage(recipient.profileImageURL),
                        ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: getViewportWidth(context) * 0.8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(18),
                              topLeft: didSendMessageBefore ? const Radius.circular(5) : const Radius.circular(18),
                              bottomRight: const Radius.circular(18),
                              bottomLeft: didSendMessageAfter ? const Radius.circular(5) : const Radius.circular(18),
                            )
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          child: Text(
                            messageModel.body,
                            textWidthBasis: TextWidthBasis.longestLine,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if(!didSendMessageAfter)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 32),
                      child: Text(
                        DateFormat('jm').format(DateTime.parse(messageModel.createdAt)),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                ],
              );
            },
            loading: () {
              return CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 14,
              );
            },
            error: (_,__) => const Text('Error')
        ),
      );
    }
  }

  Widget _messageBuilder(ConversationModel conversationModel, List<SEAUser> recipients, AppConfiguration prefs) {
    final uid = FBAuth().getUserID()!;
    final userAsyncValue = ref.watch(getUserStreamProvider(uid));
    return userAsyncValue.when(
      data: (user) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.95),
            border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300))
          ),
          width: getViewportWidth(context),
          padding: const EdgeInsets.all(10),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _onCameraClick(user, prefs, recipients),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {
                        newMessageText = value;
                      });
                    },
                    textCapitalization: TextCapitalization.sentences,
                    controller: _messageTextController,
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                    decoration: AppConfiguration.inputDecoration1.copyWith(
                      isDense: true,
                      hintStyle: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                      fillColor: Colors.white,
                      hintText: 'Message...'
                    ),
                  ),
                ),
                if(newMessageText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                        onTap: () async {
                          final message = MessageModel(
                            id: const Uuid().v4(),
                            createdAt: DateTime.now().toString(),
                            senderFirstName: user.firstName,
                            senderLastName: user.lastName,
                            senderID: user.id,
                            body: newMessageText,
                            videoURL: null,
                            imageURL: null,
                            url: null,
                          );
                          _messageTextController.text = '';
                          setState(() {
                            newMessageText = '';
                          });
                          if(widget.newConversation) {
                            await FBDatabase.createNewConversation(widget.conversationModel);
                          }
                          await sendMessage(message, conversationModel, recipients);
                        },
                        child: Icon(CupertinoIcons.arrow_up_circle_fill, size: 35, color: prefs.getPrimaryColor(),)
                    ),
                  )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error')
    );
  }

  Widget _showMediaPreview(
      { required SEAUser user, URL? url, ChatVideoContainer? videoContainer,
        required AppConfiguration prefs, required List<SEAUser> recipients}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    memCacheWidth: 3000,
                    memCacheHeight: 3000,
                    imageUrl: url == null ? videoContainer!.thumbnailUrl : url.url,
                    width: getViewportWidth(context) * 0.8,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              if(videoContainer != null)
                Positioned.fill(
                  child: Center(
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: videoContainer.thumbnailUrl,
                      backgroundColor: prefs.getPrimaryColor(),
                      onPressed: () {
                        RoutingUtil.push(context, FullScreenVideoViewer(prefs: prefs, videoUrl: videoContainer.videoUrl.url));
                      },
                      child: const Icon(
                        Icons.play_arrow,
                        color:
                         Colors.white,
                      ),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 20),
          ZAPButton(
            onPressed: () async {
              final message = MessageModel(
                id: const Uuid().v4(),
                body: '',
                imageURL: videoContainer != null ? videoContainer.thumbnailUrl : url?.url,
                videoURL: videoContainer?.videoUrl.url,
                senderID: FBAuth().getUserID()!,
                senderFirstName: user.firstName,
                senderLastName: user.lastName,
                createdAt: DateTime.now().toString(),
                url: null,
              );
              if(widget.newConversation) {
                await FBDatabase.createNewConversation(widget.conversationModel);
              }
              await sendMessage(message, widget.conversationModel, recipients);
              // await FBDatabase.sendMessage(message, widget.conversationModel.id, widget.conversationModel.creatorID);
              Navigator.of(context).pop();
            },
            backgroundColor: prefs.getPrimaryColor(),
            borderRadius: BorderRadius.circular(6),
            child: Text(
              'Send',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ZAPButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onCameraClick(SEAUser user, AppConfiguration prefs, List<SEAUser> recipients) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Send Media',
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
              URL url = await FBStorage.uploadChatImageToFireStorage(
                  File(image.path), context);
              showPlatformDialog(context: context, builder: (context) =>
                  _showMediaPreview(
                      user: user,
                      url: url,
                      prefs: prefs,
                    recipients: recipients,
                  ));
            }
          },
          child: const Text('Image from Gallery'),
        ),
        CupertinoActionSheetAction(
          child: Text('Video from Gallery'),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? galleryVideo =
            await _imagePicker.pickVideo(source: ImageSource.gallery);
            if (galleryVideo != null) {
              ChatVideoContainer videoContainer =
              await FBStorage.uploadChatVideoToFireStorage(
                  File(galleryVideo.path), context);
              showPlatformDialog(context: context, builder: (context) =>
                _showMediaPreview(
                    user: user,
                    videoContainer: videoContainer,
                    prefs: prefs,
                    recipients: recipients,
                ));
              // _sendMessage(
              //     '', videoContainer.videoUrl, videoContainer.thumbnailUrl);
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Take a Photo'),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? image =
            await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              URL url = await FBStorage.uploadChatImageToFireStorage(
                  File(image.path), context);
              // _sendMessage('', url, '');
              final message = MessageModel(
                id: const Uuid().v4(),
                body: '',
                imageURL: url.url,
                videoURL: null,
                senderID: FBAuth().getUserID()!,
                senderFirstName: user.firstName,
                senderLastName: user.lastName,
                createdAt: DateTime.now().toString(),
                url: null,
              );
              await sendMessage(message, widget.conversationModel, recipients);
              // await FBDatabase.sendMessage(message, widget.conversationModel.id, widget.conversationModel.creatorID);
            }
          },
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            XFile? recordedVideo =
            await _imagePicker.pickVideo(source: ImageSource.camera);
            if (recordedVideo != null) {
              ChatVideoContainer videoContainer =
              await FBStorage.uploadChatVideoToFireStorage(
                  File(recordedVideo.path), context);
              final message = MessageModel(
                id: const Uuid().v4(),
                body: '',
                imageURL: videoContainer.thumbnailUrl,
                videoURL: videoContainer.videoUrl.url,
                senderID: FBAuth().getUserID()!,
                senderFirstName: user.firstName,
                senderLastName: user.lastName,
                createdAt: DateTime.now().toString(),
                url: null,
              );
              await sendMessage(message, widget.conversationModel, recipients);
              // await FBDatabase.sendMessage(message, widget.conversationModel.id, widget.conversationModel.creatorID);
            }
          },
          child: const Text('Record Video'),
        )
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


}
