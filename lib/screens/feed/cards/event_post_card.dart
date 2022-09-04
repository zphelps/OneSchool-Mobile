import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/providers.dart';
import '../../events/event_card.dart';

class EventPostCard extends ConsumerStatefulWidget {
  final PostModel postModel;
  final SEAUser user;
  final bool isMainFeed;
  final AppConfiguration prefs;
  const EventPostCard({Key? key, required this.postModel, required this.isMainFeed, required this.user, required this.prefs}) : super(key: key);

  @override
  ConsumerState<EventPostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<EventPostCard> {

  @override
  Widget build(BuildContext context) {
    final eventAsyncValue = ref.watch(getEventStreamProvider(widget.postModel.eventID!));
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eventAsyncValue.when(
            data: (event) {
              return EventCard(user: widget.user, eventModel: event, isMainFeed: widget.isMainFeed, postID: widget.postModel.id, prefs: widget.prefs);
            },
            loading: () => const SizedBox(),
            error: (_,__) => const Text('Error'),
          ),
        ],
      ),
    );
  }
}
