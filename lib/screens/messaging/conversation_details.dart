import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';

import '../../services/fb_auth.dart';
import '../../services/fb_database.dart';

class ConversationDetails extends ConsumerStatefulWidget {
  final String conversationID;
  const ConversationDetails({Key? key, required this.conversationID}) : super(key: key);

  @override
  ConsumerState<ConversationDetails> createState() => _ConversationDetailsState();
}

class _ConversationDetailsState extends ConsumerState<ConversationDetails> {

  bool? muteNotifications;

  @override
  Widget build(BuildContext context) {
    final conversationAsyncValue = ref.watch(getConversationStreamProvider(widget.conversationID));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Conversation Details',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: conversationAsyncValue.when(
        data: (conversation) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                if(conversation.isGroupConversation)
                  _buildGroupProfilePictureSection(conversation),
                _buildNotificationsSettingsSection(conversation),
                const SizedBox(height: 15),
                _buildMembersSection(conversation),
              ],
            ),
          );
        },
        loading: () => const CupertinoActivityIndicator(),
        error: (_,__) => const Text('Error'),
      )
    );
  }

  Widget _buildGroupProfilePictureSection(ConversationModel conversationModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleNetworkImage(
            fit: BoxFit.cover,
            imageURL: conversationModel.imageURL!,
            size: const Size(125, 125),
          ),
          TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(55, 25),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft),
            onPressed: () {},
            child: Text(
              'Change Group Photo',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 30,),
        ],
      ),
    );
  }

  Widget _buildNotificationsSettingsSection(ConversationModel conversationModel) {
    final userAsyncValue = ref.watch(getUserStreamProvider(FBAuth().getUserID()!));
    return userAsyncValue.when(
      data: (user) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ZAPListTile(
              title: Text(
                'Mute messages',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              trailing: CupertinoSwitch(
                value: user.pushNotificationSettings.conversationsMuted.contains(conversationModel.id),
                onChanged: (mute) async {
                  if(mute) {
                    await FBDatabase.muteConversation(user.id, conversationModel.id);
                  }
                  else {
                    await FBDatabase.unmuteConversation(user.id, conversationModel.id);
                  }
                },
              ),
            )
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }

  Widget _buildMembersSection(ConversationModel conversationModel) {
    final groupMembersAsyncValue = ref.watch(getManyUsersStreamProvider(conversationModel.recipients));
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  minimumSize: const Size(55, 25),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              onPressed: () {},
              child: Text(
                'Add Members',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        groupMembersAsyncValue.when(
          data: (members) {
            members.removeWhere((element) => element.id == FBAuth().getUserID());
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: members.map((member) {
                return ZAPListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: CircleNetworkImage(
                    fit: BoxFit.cover,
                    imageURL: member.profileImageURL,
                  ),
                  title: Text(
                    '${member.firstName} ${member.lastName}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  horizontalTitleGap: 8,
                  titleSubtitleGap: 2,
                  subtitle: Text(
                    '${member.phoneNumber ?? 'No phone number'}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[300],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(),
          error: (_,__) => const Text('Error'),
        )
      ],
    );
  }
}
