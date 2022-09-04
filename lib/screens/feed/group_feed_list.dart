import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/screens/feed/feed_bloc.dart';
import 'package:sea/services/configuration.dart';
import 'package:tuple/tuple.dart';

import '../../models/SEAUser.dart';
import 'feed_card_assigner.dart';
import 'feed_query.dart';

class GroupFeedList extends ConsumerStatefulWidget {
  final Tuple5<String?, String?, bool?, bool, SEAUser?> query;
  final SEAUser user;
  final EdgeInsets contentPadding;
  final AppConfiguration prefs;
  const GroupFeedList({Key? key, required this.query, this.contentPadding = EdgeInsets.zero, required this.user, required this.prefs}) : super(key: key);

  @override
  ConsumerState<GroupFeedList> createState() => _GroupFeedListState();
}

class _GroupFeedListState extends ConsumerState<GroupFeedList> {
  @override
  void initState() {
    super.initState();
    final fp = ref.read(groupFeedProvider);

    if(mounted){
      fp.data.isNotEmpty ? print('data already loaded') :
      fp.getData(mounted, widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cb = ref.watch(groupFeedProvider);
    return RefreshIndicator(
      color: widget.prefs.getPrimaryColor(),
      onRefresh: () async {
        ref.read(groupFeedProvider).onRefresh(mounted, widget.query);
      },
      child: cb.hasData == false
          ? Center(
          child: Text(
            'There are no posts.',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey
            ),
          )
      )
          : ListView.separated(
        padding: widget.contentPadding,
        key: PageStorageKey(widget.query),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 5,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (_, int index) {
          if (index < cb.data.length) {
            return FeedCardAssigner(user: widget.user, postModel: cb.data[index], isMainFeed: widget.query.item4, prefs: widget.prefs);
          }
          return Opacity(
            opacity: cb.isLoading ? 1.0 : 0.0,
            child: cb.lastVisible == null
                ? const SizedBox() //LoadingCard(height: 250)
                : const Center(
              child: SizedBox(
                  width: 32.0,
                  height: 32.0,
                  child: CupertinoActivityIndicator()),
            ),
          );
        },
      ),
    );
  }
}
