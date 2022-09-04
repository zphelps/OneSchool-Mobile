import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/main.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/widgets/loading_card.dart';
import 'package:tuple/tuple.dart';
import '../../models/SEAUser.dart';
import 'event_card.dart';
import 'events_bloc.dart';

class EventsList extends ConsumerStatefulWidget {
  final Tuple4<SEAUser?, bool?, String?, String?> query;
  final bool isMainFeed;
  final SEAUser user;
  final AppConfiguration prefs;
  const EventsList({Key? key, required this.query, required this.isMainFeed, required this.user, required this.prefs}) : super(key: key);

  @override
  ConsumerState<EventsList> createState() => _EventListState();
}

class _EventListState extends ConsumerState<EventsList> {

  @override
  void initState() {
    super.initState();
    final fp = ref.read((widget.query.item2 ?? false) ? eventsUserIsGoingToProvider : eventsProvider);

    if(mounted){
      fp.data.isNotEmpty ? print('data already loaded') :
      fp.getData(mounted, widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cb = ref.watch((widget.query.item2 ?? false) ? eventsUserIsGoingToProvider : eventsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read((widget.query.item2 ?? false) ? eventsUserIsGoingToProvider : eventsProvider).onRefresh(mounted, widget.query);
      },
      child: cb.hasData == false
          ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: getViewportHeight(context),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                  child: Text(
                    'You are not going to any events.',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey
                    ),
                  )
                  ),
                ],
              ),
            ),
          )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        key: PageStorageKey(widget.query),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 5,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (_, int index) {
          if (index < cb.data.length) {
            return EventCard(user: widget.user, eventModel: cb.data[index], isMainFeed: widget.isMainFeed, prefs: widget.prefs);
          }
          return Opacity(
            opacity: cb.isLoading ? 1.0 : 0.0,
            child: cb.lastVisible == null
                ? const LoadingCard(height: 150)
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


