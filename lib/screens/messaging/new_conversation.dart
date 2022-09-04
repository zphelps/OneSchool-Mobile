import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/main.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/messaging/conversation_view.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/SEAUser_search/SEAUser_search.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:uuid/uuid.dart';

import '../../models/ConversationModel.dart';
import '../../widgets/circle_network_image.dart';

class NewConversation extends ConsumerStatefulWidget {
  const NewConversation({Key? key}) : super(key: key);

  @override
  ConsumerState<NewConversation> createState() => _NewConversationState();
}

class _NewConversationState extends ConsumerState<NewConversation> {


  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final usersAsyncValue = ref.watch(usersStreamProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text(
          'New Message',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black
          ),
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: getViewportHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(_loading)
                  Center(child: PlatformCircularProgressIndicator()),
              ],
            ),
          ),
          usersAsyncValue.when(
              data: (users) {
                users.removeWhere((element) => element.id == FBAuth().getUserID()!);
                return TypeAheadField(
                  getImmediateSuggestions: true,
                  textFieldConfiguration: TextFieldConfiguration(
                    autocorrect: false,
                    decoration: AppConfiguration.inputDecoration1.copyWith(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      fillColor: Colors.grey[100],
                      prefix: const Text(
                          'To: '
                      )
                    ),
                    autofocus: true,
                  ),
                  // keepSuggestionsOnSuggestionSelected: true,
                  noItemsFoundBuilder: (context) {
                    return const Center(
                      child: Text(
                        'User not found :(',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 16
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context) => PlatformCircularProgressIndicator(),
                  suggestionsCallback: (pattern) {
                    final hits = users.where((element) {
                      final fullName = element.firstName + element.lastName;
                      return fullName.toLowerCase().contains(pattern.toLowerCase());
                    });
                    return hits;
                  },
                  suggestionsBoxVerticalOffset: 5,
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    elevation: 0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                    shadowColor: Colors.white.withOpacity(0),
                  ),
                  itemBuilder: (BuildContext context, SEAUser suggestion) {
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          horizontalTitleGap: 10,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              backgroundImage: NetworkImage(
                                suggestion.profileImageURL,
                              )
                          ),

                          title: Text(
                            '${suggestion.firstName} ${suggestion.lastName}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(indent: 50, height: 0)
                      ],
                    );
                  },
                  onSuggestionSelected: (SEAUser suggestion) async {
                    setState(() {
                      _loading = true;
                    });
                    final conversationAlreadyIn = await FBDatabase.conversationsAlreadyIn(recipientID: suggestion.id, userID: FBAuth().getUserID()!);
                    if(conversationAlreadyIn != null) {
                      print('already exists');
                      print(conversationAlreadyIn.recipients);
                      RoutingUtil.pushReplacement(context, ConversationView(conversationModel: conversationAlreadyIn));
                    }
                    else {
                      final conversation = ConversationModel(
                        id: const Uuid().v4(),
                        creatorID: FBAuth().getUserID()!,
                        lastMessage: 'New conversation',
                        lastMessageDate: DateTime.now().toString(),
                        imageURL: null,
                        name: null,
                        recipients: [FBAuth().getUserID()!, suggestion.id],
                        groupID: null,
                        isGroupConversation: false,
                      );
                      RoutingUtil.pushReplacement(context, ConversationView(conversationModel: conversation, newConversation: true));
                    }
                  },
                );
              },
              loading: () => Center(child: PlatformCircularProgressIndicator()),
              error: (_,__) => const Text('Error')
          ),
        ],
      ),
    );
  }


}
