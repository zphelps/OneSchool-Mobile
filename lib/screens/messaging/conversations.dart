import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sea/models/ConversationModel.dart';
import 'package:sea/screens/messaging/conversation_view.dart';
import 'package:sea/screens/messaging/new_conversation.dart';
import 'package:sea/screens/messaging/new_group_conversation.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/app_bar_circular_action_button.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:tuple/tuple.dart';

import '../../services/configuration.dart';
import '../../services/helpers.dart';
import '../../widgets/logo_app_bar.dart';
import '../../zap_widgets/zap_button.dart';
import '../notifications/notifications.dart';

class Conversations extends ConsumerStatefulWidget {
  const Conversations({Key? key}) : super(key: key);

  @override
  ConsumerState<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends ConsumerState<Conversations> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final conversationsAsyncValue = ref.watch(conversationsStreamProvider(FBAuth().getUserID()!));
    final groupsConversationsAsyncValue = ref.watch(groupConversationsStreamProvider(FBAuth().getUserID()!));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size(getViewportWidth(context), 103),
          child: Theme(
            data: ThemeData(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: LogoAppBar(
              sliverAppBar: false,
              logoURL: prefs.getSchoolLogoURL(),
              title: 'Conversations',
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AppBarCircularActionButton(
                    onTap: () => RoutingUtil.pushAsync(context, const Notifications()),
                    backgroundColor: Colors.grey[200],
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.black,
                      size: 22,
                    ),
                    radius: 18,
                  ),
                ),
              ],
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                labelColor: prefs.getPrimaryColor(),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: prefs.getPrimaryColor(),
                tabs: const [
                  Tab(text: 'Direct'),
                  Tab(text: 'Group'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: conversationsAsyncValue.when(
                  data: (conversations) {
                    return _buildConversationsList(conversations);
                  },
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (e,__) {
                    print(e.toString());
                    return Text(e.toString());
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: groupsConversationsAsyncValue.when(
                  data: (conversations) {
                    return _buildConversationsList(conversations);
                  },
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (_,__) => const Text('Error')
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: prefs.getPrimaryColor(),
          onPressed: () async {
            RoutingUtil.pushAsync(context, const NewConversation());
          },
          child: const Icon(
            Icons.edit_sharp
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(height: 0);
      },
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _conversationListTile(conversation);
      },
    );
  }

  Widget _conversationListTile(ConversationModel conversationModel) {
    final recipientsAsyncValue = ref.watch(getManyUsersStreamProvider(conversationModel.recipients));
    return recipientsAsyncValue.when(
        data: (recipients) {
          recipients.removeWhere((element) => element.id == FBAuth().getUserID()!);
          return InkWell(
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 150));
              RoutingUtil.pushAsync(context, ConversationView(conversationModel: conversationModel));
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleNetworkImage(
                imageURL: recipients.length > 1 ? conversationModel.imageURL! : recipients.first.profileImageURL,
                fit: BoxFit.cover,
                size: const Size(55, 55),
              ),
              horizontalTitleGap: 12,
              // titleSubtitleGap: 4,
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  ' ${timeAgo(conversationModel.lastMessageDate)}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500]
                  ),
                ),
              ),
              title: Text(
                '${recipients.length > 1 ? conversationModel.name : '${recipients.first.firstName} ${recipients.first.lastName}'}',
                style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                ),
              ),
              subtitle: Text(
                '${conversationModel.lastMessage} ',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox(),
        error: (_,__) => const Text('Error')
    );
  }

  @override
  bool get wantKeepAlive => true;
}
