import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/screens/admin/create_alert.dart';
import 'package:sea/screens/admin/create_event.dart';
import 'package:sea/screens/admin/create_game.dart';
import 'package:sea/screens/admin/create_post.dart';
import 'package:sea/screens/alerts/alerts.dart';
import 'package:sea/screens/feed/feed_bloc.dart';
import 'package:sea/screens/feed/feed_list.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/screens/feed/group_feed_list.dart';
import 'package:sea/screens/media_gallery/media_gallery.dart';
import 'package:sea/screens/notifications/notifications.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/widgets/logo_app_bar.dart';
import 'package:sea/zap_widgets/zap_button.dart';
import 'package:tuple/tuple.dart';

import '../../models/SEAUser.dart';
import '../../services/configuration.dart';
import '../../services/fb_auth.dart';
import '../../services/fb_messaging.dart';
import '../../services/routing_helper.dart';
import '../../widgets/app_bar_circular_action_button.dart';
import '../events/events.dart';
import '../events/todays_events_card.dart';
import '../groups/groups.dart';
import '../messaging/conversations.dart';

class Home extends ConsumerStatefulWidget {
  final SEAUser user;
  final AppConfiguration prefs;
  final TenantModel tenantModel;
  const Home({Key? key, required this.user, required this.prefs, required this.tenantModel}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {

  final ScrollController scrollController = ScrollController();

  late Tuple5<String?, String?, bool?, bool, SEAUser?> feedQuery;

  void _feedScrollListener() {
    final ap = ref.read(feedProvider);
    if (!ap.isLoading) {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        print("reached the bottom");
        ap.setLoading(true);
        ap.getData(mounted, feedQuery);
      }
    }
  }

  refreshToken() async {
    final token = await FBMessaging.firebaseMessaging.getToken();
    if(token != null && token != widget.user.fcmToken && FBAuth().getUserID() != null && FBAuth().getTenantID() != null) {
      print(token);
      print(widget.user.fcmToken);
      print('token updated');
      FBDatabase.updateUserFCMToken(FBAuth().getUserID()!, token);
    }
  }

  @override
  void initState() {
    super.initState();
    feedQuery = FeedQuery(uid: FBAuth().getUserID()!, isMainFeed: true, user: widget.user);
    scrollController.addListener(_feedScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    feedQuery = FeedQuery(uid: FBAuth().getUserID()!, isMainFeed: true, user: widget.user);
    ref.listen(fcmTokenStreamProvider, (previous, next) {
      refreshToken();
    });
    // refreshToken();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeAreaColor(
        color: Colors.white,
        child: RefreshIndicator(
          color: widget.prefs.getPrimaryColor(),
          displacement: 50,
          onRefresh: () async {
            ref.read(feedProvider).onRefresh(mounted, feedQuery);
            HapticFeedback.heavyImpact();
          },
          child: CustomScrollView(
            physics: const RangeMaintainingScrollPhysics(),
            controller: scrollController,
            slivers: [
              LogoAppBar(sliverAppBar: true, logoURL: widget.prefs.getSchoolLogoURL(), title: widget.prefs.getSchoolName(),
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
              ),
              SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    Alerts(tenantModel: widget.tenantModel, user: widget.user),
                    greetingCard(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                      child: TodaysEventsCard(user: widget.user),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FeedList(user: widget.user, query: feedQuery, prefs: widget.prefs),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget greetingCard() {
    String getGreeting() {
      if(DateTime.now().hour > 0 && DateTime.now().hour < 13) {
        return 'Good morning,';
      }
      else if(DateTime.now().hour > 12 && DateTime.now().hour < 17) {
        return 'Good afternoon,';
      }
      else {
        return 'Good evening,';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(6, 15, 6, 6),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, //0.35
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, 0),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 15,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.red, Colors.orange]
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              getGreeting(),
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '${widget.user.firstName}!',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(widget.tenantModel.userRolesThatCanPostInMainFeed.contains(widget.user.userRole))
                Expanded(
                  child: ZAPButton(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    onPressed: () {
                      RoutingUtil.pushAsync(context, const CreatePost(), fullscreenDialog: true);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.post_add_rounded,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Post',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(width: 1, height: 25, color: Colors.grey.shade200),
              Expanded(
                child: ZAPButton(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  onPressed: () {
                    RoutingUtil.pushAsync(context, CreateEvent(user: widget.user, prefs: widget.prefs), fullscreenDialog: true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Event',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 25, color: Colors.grey.shade200),
              Expanded(
                child: ZAPButton(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  onPressed: () {
                    RoutingUtil.pushAsync(context, CreateAlert(prefs: widget.prefs), fullscreenDialog: true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_alert_outlined,
                        size: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alert',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 25, color: Colors.grey.shade200),
              Expanded(
                child: ZAPButton(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  onPressed: () {
                    RoutingUtil.pushAsync(context, CreateGame(user: widget.user, prefs: widget.prefs), fullscreenDialog: true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sports_baseball_outlined,
                        size: 20,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Game',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}
