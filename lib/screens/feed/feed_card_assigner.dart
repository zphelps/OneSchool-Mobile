import 'package:flutter/material.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/feed/cards/event_post_card.dart';
import 'package:sea/screens/feed/cards/regular_post_card.dart';
import 'package:sea/services/configuration.dart';

class FeedCardAssigner extends StatelessWidget {
  final PostModel postModel;
  final bool isMainFeed;
  final SEAUser user;
  final AppConfiguration prefs;
  const FeedCardAssigner({Key? key, required this.postModel, required this.isMainFeed, required this.user, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(postModel.isAnnouncement) {
      return const SizedBox();
    }
    else if(postModel.isArticle) {
      return const SizedBox();
    }
    else if(postModel.eventID != null) {
      return EventPostCard(user: user, postModel: postModel, isMainFeed: isMainFeed, prefs: prefs);
    }
    else {
      return RegularPostCard(user: user, postModel: postModel, isMainFeed: isMainFeed, prefs: prefs);
    }
  }
}
