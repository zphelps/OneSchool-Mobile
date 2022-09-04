import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/create_event.dart';
import 'package:sea/screens/admin/create_game.dart';
import 'package:sea/screens/events/events_bloc.dart';
import 'package:sea/screens/games/game_details.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/widgets/logo_app_bar.dart';
import '../../services/configuration.dart';
import '../../services/routing_helper.dart';
import '../../widgets/app_bar_circular_action_button.dart';
import '../notifications/notifications.dart';
import 'calender.dart';
import 'event_details.dart';
import 'events_list.dart';
import 'events_query.dart';

class Events extends ConsumerStatefulWidget {
  final SEAUser user;
  const Events({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<Events> createState() => _EventsState();
}

class _EventsState extends ConsumerState<Events> with AutomaticKeepAliveClientMixin {

  final upcomingEventsScrollController = ScrollController();
  final goingToEventsScrollController = ScrollController();

  void _upcomingEventsScrollListener() {
    final ap = ref.read(eventsProvider);
    if (!ap.isLoading) {
      if (upcomingEventsScrollController.offset >= upcomingEventsScrollController.position.maxScrollExtent && !upcomingEventsScrollController.position.outOfRange) {
        print("reached the bottom");
        ap.setLoading(true);
        ap.getData(mounted, EventsQuery(user: widget.user));
      }
    }
  }

  void _goingToEventsScrollListener() {
    final ap = ref.read(eventsUserIsGoingToProvider);
    if (!ap.isLoading) {
      if (goingToEventsScrollController.offset >= goingToEventsScrollController.position.maxScrollExtent && !goingToEventsScrollController.position.outOfRange) {
        print("reached the bottom");
        ap.setLoading(true);
        ap.getData(mounted, EventsQuery(user: widget.user, going: true));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    upcomingEventsScrollController.addListener(_upcomingEventsScrollListener);
    goingToEventsScrollController.addListener(_goingToEventsScrollListener);
  }


  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(preferredSize: Size(getViewportWidth(context), 103),
          child: Theme(
            data: ThemeData(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: LogoAppBar(
              sliverAppBar: false,
              logoURL: prefs.getSchoolLogoURL(),
              title: 'Events',
              actions: [
                if(widget.user.userPermissions.canCreateGroupAssociatedEvents
                    || widget.user.userPermissions.canCreateNonGroupAssociatedEvents
                    || widget.user.userPermissions.fullAdmin)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: AppBarCircularActionButton(
                      onTap: () async {
                        showModalBottomSheet(backgroundColor: Colors.transparent, isScrollControlled: true, context: context, builder: (context) {
                          return Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                color: Colors.white
                            ),
                            child: SizedBox(
                              height: 250,
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    width: 50,
                                    height: 5,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        'Create',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ListTile(
                                    onTap: () async {
                                      final event = await RoutingUtil.pushAsync(context, CreateEvent(prefs: prefs, user: widget.user), fullscreenDialog: true);
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      if(event != null) {
                                        await RoutingUtil.pushAsync(context, EventDetails(user: widget.user, eventID: event.id, comingFromGroupProfile: false));
                                        Navigator.of(context).pop();
                                        ref.watch(eventsProvider).onRefresh(mounted, EventsQuery(user: widget.user));
                                      }
                                      else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      radius: 26,
                                      child: const Icon(
                                        Icons.event,
                                        color: Colors.black,
                                      ),
                                    ),
                                    title: Text(
                                      'Event',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  ListTile(
                                    onTap: () async {
                                      final game = await RoutingUtil.pushAsync(context, CreateGame(prefs: prefs, user: widget.user), fullscreenDialog: true);
                                      await Future.delayed(const Duration(milliseconds: 500));
                                      if(game != null) {
                                        await RoutingUtil.pushAsync(context, GameDetails(eventID: game.eventID, gameID: game.id));
                                        Navigator.of(context).pop();
                                        ref.watch(eventsProvider).onRefresh(mounted, EventsQuery(user: widget.user));
                                      }
                                      else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      radius: 26,
                                      child: const Icon(
                                        Icons.sports,
                                        color: Colors.black,
                                      ),
                                    ),
                                    title: Text(
                                      'Game',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                      radius: 18,
                    ),
                  ),
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
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Going'),
                  Tab(text: 'Calender'),
                ],
              ),
            ),
          )),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              color: prefs.getPrimaryColor(),
              displacement: 0,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                ref.read(eventsProvider).onRefresh(mounted, EventsQuery(user: widget.user));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: upcomingEventsScrollController,
                clipBehavior: Clip.none,
                child: EventsList(user: widget.user, query: EventsQuery(user: widget.user), isMainFeed: true, prefs: prefs),
              ),
            ),
            RefreshIndicator(
              color: prefs.getPrimaryColor(),
              displacement: 0,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                ref.read(eventsUserIsGoingToProvider).onRefresh(mounted, EventsQuery(user: widget.user, going: true));
              },
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: goingToEventsScrollController,
                child: EventsList(user: widget.user, query: EventsQuery(user: widget.user, going: true), isMainFeed: true, prefs: prefs),
              ),
            ),
            _buildEventsCalendar(widget.user, prefs),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCalendar(SEAUser user, AppConfiguration prefs) {
    final eventsAsyncValue = ref.watch(eventsStreamProvider(EventsQuery(user: user)));
    return eventsAsyncValue.when(
      data: (events) {
        return CalendarView(user: user, events: events, prefs: prefs);
      },
      loading: () => Center(child: PlatformCircularProgressIndicator()),
      error: (e,__) => Text(e.toString()),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
