import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:sea/enums.dart';
import 'package:sea/main.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/create_post.dart';
import 'package:sea/screens/events/group_events_list.dart';
import 'package:sea/screens/feed/feed_list.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/screens/feed/group_feed_list.dart';
import 'package:sea/screens/games/group_games.dart';
import 'package:sea/screens/groups/group_action_buttons.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/group_association_buttons.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:tuple/tuple.dart';
import '../../models/GroupPermissionsModel.dart';
import '../../services/configuration.dart';
import '../../widgets/circle_network_image.dart';
import '../events/events_list.dart';
import '../events/events_query.dart';
import '../feed/feed_bloc.dart';
import '../media_gallery/media_gallery.dart';

class GroupProfile extends ConsumerStatefulWidget {
  final String groupID;
  final SEAUser user;
  const GroupProfile({Key? key, required this.groupID, required this.user}) : super(key: key);

  @override
  ConsumerState<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends ConsumerState<GroupProfile> with TickerProviderStateMixin {

  late final TabController primaryTC;
  final GlobalKey<ExtendedNestedScrollViewState> _key =
  GlobalKey<ExtendedNestedScrollViewState>();

  final NestedScrollController scrollController = NestedScrollController();

  Tuple5<String?, String?, bool?, bool, SEAUser?>? feedQuery;

  double expandedHeight = 390;

  _profileNeedsMoreSetup(GroupModel groupModel) {
    if(groupModel.backgroundImageURL == null || groupModel.backgroundImageURL!.isEmpty) {
      return true;
    }
    else if(groupModel.description == null || groupModel.description!.isEmpty) {
      return true;
    }
    return false;
  }

  scrollListener() {
    final ap = ref.read(groupFeedProvider);
    if (!ap.isLoading && scrollController.innerScrollController!.positions.isNotEmpty) {
      if (scrollController.innerScrollController!.positions.last.pixels >=
          scrollController.innerScrollController!.positions.last.maxScrollExtent &&
          !scrollController.innerScrollController!.positions.last.outOfRange) {
        print("reached the bottom");
        ap.setLoading(true);
        ap.getData(mounted, feedQuery!);
      }
    }
    final mp = ref.read(mediaFeedProvider);
    if (!mp.isLoading && scrollController.innerScrollController!.positions.isNotEmpty) {
      if (scrollController.innerScrollController!.positions.last.pixels >=
          scrollController.innerScrollController!.positions.last.maxScrollExtent &&
          !scrollController.innerScrollController!.positions.last.outOfRange) {
        print("reached the bottom");
        mp.setLoading(true);
        mp.getData(mounted, FeedQuery(groupID: widget.groupID, isMainFeed: false, uid: FBAuth().getUserID()!));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    feedQuery = FeedQuery(groupID: widget.groupID, uid: FBAuth().getUserID()!, isMainFeed: false);
    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    const double pinnedHeaderHeight = 0;
    final prefs = ref.watch(sharedPreferencesServiceProvider);
    final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
    return groupAsyncValue.when(
      data: (group) {
        return DefaultTabController(
          length: group.isTeam ? 5 : 4,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            extendBodyBehindAppBar: true,
            body: ExtendedNestedScrollView(
            //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
              pinnedHeaderSliverHeightBuilder: () {
                return pinnedHeaderHeight;
              },
              //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
              onlyOneScrollInBody: true,
              key: _key,
              controller: scrollController,
              physics: const RangeMaintainingScrollPhysics(),
              headerSliverBuilder: (context, boxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.grey[50],
                    pinned: true,
                    expandedHeight: expandedHeight,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[50],
                          child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
                        ),
                      ),
                    ),
                    // collapsedHeight: 50,
                    toolbarHeight: 28,
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: Size(getViewportWidth(context), 50),
                      child: SafeArea(
                        child: Container(
                          color: Colors.grey[50],
                          child: TabBar(
                            // controller: primaryTC,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                            labelColor: prefs.getPrimaryColor(),
                            unselectedLabelColor: Colors.grey[600],
                            indicatorColor: prefs.getPrimaryColor(),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                            tabs: [
                              const Tab(text: 'FEED'),
                              if(group.isTeam)
                                const Tab(text: 'GAMES'),
                              const Tab(text: 'EVENTS'),
                              // const Tab(text: 'POLLS'),
                              const Tab(text: 'MEDIA',),
                              const Tab(text: 'FILES'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      expandedTitleScale: 1,
                      background: Stack(
                        children: <Widget>[
                          SizedBox(height: getViewportHeight(context) * 0.4),
                          /// Banner image
                          SizedBox(
                            height: getViewportHeight(context) * 0.25,
                            width: getViewportWidth(context),
                            child: CachedNetworkImage(
                              imageUrl: group.backgroundImageURL != null && group.backgroundImageURL!.isNotEmpty ? group.backgroundImageURL! : 'https://www.stanford.edu/wp-content/uploads/2022/04/Memorial-Church.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// UserModel avatar, message icon, profile edit and follow/following button
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white, width: 6),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 15,
                                                spreadRadius: 1,
                                              )
                                            ]
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10000),
                                          child: Container(
                                            color: Colors.white,
                                            padding: const EdgeInsets.all(0),
                                            child: CachedNetworkImage(
                                              imageUrl: group.profileImageURL,
                                              fit: BoxFit.cover,
                                              height: 80,
                                              width: 80,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: _buildFollowerMemberDisplayText(group),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    group.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    height: 40,
                                    child: Text(
                                      group.description ?? 'No description yet',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GroupAssociationButtons(groupModel: group, prefs: prefs),
                                  // AnimatedSize(
                                  //   duration: const Duration(milliseconds: 150),
                                  //   alignment: Alignment.topLeft,
                                  //   child: FutureBuilder(
                                  //     future: PermissionsManager.groupPermissions(groupID: group.id),
                                  //     builder: (BuildContext context, AsyncSnapshot<GroupPermissionsModel> snap) {
                                  //       if(snap.hasData && PermissionsManager.showGroupActionButtons(groupPermissionsModel: snap.data!)) {
                                  //         return GroupActionButtons(prefs: prefs, groupModel: group, groupPermissionsModel: snap.data!, user: widget.user);
                                  //       }
                                  //       return const SizedBox();
                                  //     },
                                  //   ),
                                  // ),
                                  const SizedBox(height: 55),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ];
                },
                body: LayoutBuilder(
                  builder: (context, constraints) {
                    scrollController.enableScroll(context);
                    return Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            children: group.isPrivate && !PermissionsManager.canAccessPrivateGroup(group, FBAuth().getUserID()!) ? List.generate(group.isTeam ? 5 : 4, (index) {
                              return Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Private Group.',
                                        style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey
                                        ),
                                      ),
                                    ],
                                  )
                              );
                            }) : [
                              Column(
                                children: [
                                  // if(_profileNeedsMoreSetup(group))
                                  //   _buildGroupProfileFinisher(group, prefs),
                                  Expanded(child: GroupFeedList(prefs: prefs, user: widget.user, query: feedQuery!, contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12))),
                                ],
                              ),
                              if(group.isTeam)
                                GroupGames(groupModel: group),
                              Column(
                                children: [
                                  Expanded(child: GroupEventsList(user: widget.user, query: EventsQuery(user: widget.user, groupID: group.id), isMainFeed: false, prefs: prefs)),
                                ],
                              ),
                              MediaGallery(feedQuery: FeedQuery(groupID: widget.groupID, isMainFeed: false, containsMedia: true, uid: FBAuth().getUserID()!), prefs: prefs),
                              Center(
                                  child: Text(
                                    'Files are still in development',
                                    style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey
                                    ),
                                  )
                              ),
                              // _buildAboutSection(group),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                )
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () => RoutingUtil.pushAsync(context, CreatePost(groupModel: group), fullscreenDialog: true),
            //   backgroundColor: prefs.getPrimaryColor(),
            //   child: const Icon(
            //     Icons.create,
            //   ),
            // ),
          ),
        );
      },
      loading: () => PlatformCircularProgressIndicator(),
      error: (_,__) => const Text('Error'),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final prefs = ref.watch(sharedPreferencesServiceProvider);
  //   final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
  //   return groupAsyncValue.when(
  //     data: (group) {
  //       return Scaffold(
  //         backgroundColor: Colors.white,
  //         extendBodyBehindAppBar: !addTabBarPadding,
  //         appBar: AppBar(
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           automaticallyImplyLeading: false,
  //           toolbarHeight: 40,
  //           systemOverlayStyle: SystemUiOverlayStyle.dark,
  //           title: Text(
  //             addTabBarPadding ? group.name : '',
  //             style: GoogleFonts.inter(
  //               color: Colors.black,
  //               fontWeight: FontWeight.w600,
  //               fontSize: 17
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Padding(
  //               padding: const EdgeInsets.only(right: 5),
  //               child: InkWell(
  //                 onTap: () {},
  //                 child: CircleAvatar(
  //                   radius: 16,
  //                   backgroundColor: Colors.white.withOpacity(0.95),
  //                   child: const Icon(CupertinoIcons.search, color: Colors.black, size: 18),
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(right: 10),
  //               child: InkWell(
  //                 onTap: () {},
  //                 child: CircleAvatar(
  //                   radius: 16,
  //                   backgroundColor: Colors.white.withOpacity(0.95),
  //                   child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
  //                 ),
  //               ),
  //             ),
  //           ],
  //           leading: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 12),
  //             child: InkWell(
  //               onTap: () => Navigator.of(context).pop(),
  //               child: CircleAvatar(
  //                 backgroundColor: Colors.white.withOpacity(0.95),
  //                 child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
  //               ),
  //             ),
  //           ),
  //         ),
  //         body: DefaultTabController(
  //           length: 5,
  //           child: NestedScrollView(
  //             controller: scrollController,
  //             physics: const BouncingScrollPhysics(),
  //             headerSliverBuilder: (context, boxIsScrolled) {
  //               return [
  //                 SliverList(
  //                   delegate: SliverChildListDelegate(
  //                     [
  //                       Stack(
  //                         children: <Widget>[
  //                           SizedBox(height: getViewportHeight(context) * 0.4),
  //                           /// Banner image
  //                           SizedBox(
  //                             height: getViewportHeight(context) * 0.25,
  //                             width: getViewportWidth(context),
  //                             child: CachedNetworkImage(
  //                               imageUrl: group.backgroundImageURL != null && group.backgroundImageURL!.isNotEmpty ? group.backgroundImageURL! : 'https://www.stanford.edu/wp-content/uploads/2022/04/Memorial-Church.jpg',
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //
  //                           /// UserModel avatar, message icon, profile edit and follow/following button
  //                           Positioned(
  //                             bottom: 0,
  //                             left: 0,
  //                             right: 0,
  //                             child: Container(
  //                               padding: const EdgeInsets.symmetric(horizontal: 15),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 mainAxisAlignment: MainAxisAlignment.end,
  //                                 children: [
  //                                   Row(
  //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                     crossAxisAlignment: CrossAxisAlignment.end,
  //                                     children: <Widget>[
  //                                       AnimatedContainer(
  //                                         duration: const Duration(milliseconds: 500),
  //                                         decoration: BoxDecoration(
  //                                             border: Border.all(color: Colors.white, width: 6),
  //                                             shape: BoxShape.circle,
  //                                             boxShadow: [
  //                                               BoxShadow(
  //                                                 color: Colors.black.withOpacity(0.05),
  //                                                 blurRadius: 15,
  //                                                 spreadRadius: 1,
  //                                               )
  //                                             ]
  //                                         ),
  //                                         child: ClipRRect(
  //                                           borderRadius: BorderRadius.circular(10000),
  //                                           child: Container(
  //                                             color: Colors.white,
  //                                             padding: const EdgeInsets.all(0),
  //                                             child: CachedNetworkImage(
  //                                               imageUrl: group.profileImageURL,
  //                                               fit: BoxFit.cover,
  //                                               height: 80,
  //                                               width: 80,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       Padding(
  //                                         padding: const EdgeInsets.only(bottom: 8),
  //                                         child: _buildFollowerMemberDisplayText(group),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   const SizedBox(height: 8),
  //                                   Text(
  //                                     group.name,
  //                                     style: GoogleFonts.inter(
  //                                       fontSize: 22,
  //                                       fontWeight: FontWeight.w800,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 3),
  //                                   Text(
  //                                     group.description ?? 'No description yet',
  //                                     style: GoogleFonts.inter(
  //                                       color: Colors.grey[600],
  //                                       fontSize: 14,
  //                                       fontWeight: FontWeight.w500,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(height: 10),
  //                                   GroupAssociationButtons(groupModel: group, prefs: prefs),
  //                                   const SizedBox(height: 5),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ]
  //                   ),
  //                 ),
  //               ];
  //             },
  //             body: LayoutBuilder(
  //               builder: (context, constraints) {
  //                 scrollController.enableScroll(context);
  //                 scrollController.enableCenterScroll(constraints);
  //                 return Column(
  //                   children: [
  //                     Container(
  //                       color: Colors.white,
  //                       child: TabBar(
  //                         indicatorSize: TabBarIndicatorSize.label,
  //                         labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
  //                         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
  //                         labelColor: prefs.getPrimaryColor(),
  //                         unselectedLabelColor: Colors.grey[600],
  //                         indicatorColor: prefs.getPrimaryColor(),
  //                         labelPadding: const EdgeInsets.symmetric(horizontal: 5),
  //                         tabs: const [
  //                           Tab(text: 'FEED'),
  //                           Tab(text: 'EVENTS'),
  //                           Tab(text: 'POLLS'),
  //                           Tab(text: 'FILES'),
  //                           Tab(text: 'ABOUT'),
  //                         ],
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: TabBarView(
  //                         children: [
  //                           Column(
  //                             children: [
  //                               if(_profileNeedsMoreSetup(group))
  //                                 _buildGroupProfileFinisher(group, prefs),
  //                               Expanded(child: FeedList(user: widget.user, query: feedQuery!, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
  //                             ],
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  //                             child: EventsList(user: widget.user, query: EventsQuery(user: widget.user, groupID: group.id), isMainFeed: false),
  //                           ),
  //                           Center(
  //                               child: Text(
  //                                 'Polls are still in development',
  //                                 style: GoogleFonts.inter(
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.grey
  //                                 ),
  //                               )
  //                           ),
  //                           Center(
  //                               child: Text(
  //                                 'Files are still in development',
  //                                 style: GoogleFonts.inter(
  //                                     fontSize: 20,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.grey
  //                                 ),
  //                               )
  //                           ),
  //                           _buildAboutSection(group),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               },
  //             )
  //           ),
  //         ),
  //         floatingActionButton: FloatingActionButton(
  //           onPressed: () => RoutingUtil.pushAsync(context, CreatePost(groupModel: group), fullscreenDialog: true),
  //           backgroundColor: prefs.getPrimaryColor(),
  //           child: const Icon(
  //             Icons.create,
  //           ),
  //         ),
  //       );
  //     },
  //     loading: () => PlatformCircularProgressIndicator(),
  //     error: (_,__) => const Text('Error'),
  //   );
  // }


// class GroupProfile extends ConsumerStatefulWidget {
//   final String groupID;
//   const GroupProfile({Key? key, required this.groupID}) : super(key: key);
//
//   @override
//   ConsumerState<GroupProfile> createState() => _GroupProfileState();
// }
//
// class _GroupProfileState extends ConsumerState<GroupProfile> {
//
//   final NestedScrollController nestedScrollController = NestedScrollController();
//
//   FeedQuery? feedQuery;
//
//   _profileNeedsMoreSetup(GroupModel groupModel) {
//     if(groupModel.backgroundImageURL == null || groupModel.backgroundImageURL!.isEmpty) {
//       return true;
//     }
//     else if(groupModel.description == null || groupModel.description!.isEmpty) {
//       return true;
//     }
//     return false;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     feedQuery = FeedQuery(groupID: widget.groupID, uid: FBAuth().getUserID()!, isMainFeed: false);
//     nestedScrollController.addListener(() {
//       final ap = ref.read(feedProvider);
//       if (!ap.isLoading) {
//         if (nestedScrollController.innerOffset >= nestedScrollController.innerScrollController!.position.maxScrollExtent && !nestedScrollController.innerScrollController!.position.outOfRange) {
//           print("reached the bottom");
//           ap.setLoading(true);
//           ap.getData(mounted, feedQuery!);
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final prefs = ref.watch(sharedPreferencesServiceProvider);
//     final uid = FBAuth().getUserID()!;
//     final groupAsyncValue = ref.watch(getGroupStreamProvider(widget.groupID));
//     final userAsyncValue = ref.watch(getUserStreamProvider(uid));
//     return groupAsyncValue.when(
//       data: (group) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           body: DefaultTabController(
//             length: 5,
//             child: NestedScrollView(
//                 controller: nestedScrollController,
//               headerSliverBuilder: (context, boxIsScrolled) {
//                 return [
//                   SliverAppBar(
//                     forceElevated: false,
//                     expandedHeight: getViewportHeight(context) * 0.4,
//                     elevation: 0,
//                     stretch: true,
//                     pinned: true,
//                     floating: true,
//                     snap: true,
//                     iconTheme: const IconThemeData(color: Colors.black),
//                     backgroundColor: Colors.white,
//                     actions: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.only(right: 5),
//                         child: InkWell(
//                           onTap: () {},
//                           child: CircleAvatar(
//                             radius: 16,
//                             backgroundColor: Colors.white.withOpacity(0.95),
//                             child: const Icon(CupertinoIcons.search, color: Colors.black, size: 18),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(right: 10),
//                         child: InkWell(
//                           onTap: () {},
//                           child: CircleAvatar(
//                             radius: 16,
//                             backgroundColor: Colors.white.withOpacity(0.95),
//                             child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
//                           ),
//                         ),
//                       ),
//                     ],
//                     automaticallyImplyLeading: false,
//                     leading: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: InkWell(
//                         onTap: () => Navigator.of(context).pop(),
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white.withOpacity(0.95),
//                           child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
//                         ),
//                       ),
//                     ),
//                     flexibleSpace: FlexibleSpaceBar(
//                       stretchModes: const <StretchMode>[
//                         StretchMode.zoomBackground,
//                         StretchMode.blurBackground
//                       ],
//                       background: Stack(
//                         alignment: Alignment.topCenter,
//                         children: <Widget>[
//                           SizedBox.expand(
//                             child: Container(
//                               padding: const EdgeInsets.only(top: 50),
//                               height: 30,
//                               color: Colors.white,
//                             ),
//                           ),
//
//                           /// Banner image
//                           SizedBox(
//                             height: getViewportHeight(context) * 0.225,
//                             width: getViewportWidth(context),
//                             child: CachedNetworkImage(
//                               imageUrl: group.backgroundImageURL != null && group.backgroundImageURL!.isNotEmpty ? group.backgroundImageURL! : 'https://www.stanford.edu/wp-content/uploads/2022/04/Memorial-Church.jpg',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//
//                           /// UserModel avatar, message icon, profile edit and follow/following button
//                           Container(
//                             alignment: Alignment.bottomLeft,
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     AnimatedContainer(
//                                       duration: const Duration(milliseconds: 500),
//                                       decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.white, width: 6),
//                                           shape: BoxShape.circle,
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.black.withOpacity(0.05),
//                                             blurRadius: 15,
//                                             spreadRadius: 1,
//                                           )
//                                         ]
//                                       ),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(10000),
//                                         child: Container(
//                                           color: Colors.white,
//                                           padding: const EdgeInsets.all(0),
//                                           child: CachedNetworkImage(
//                                             imageUrl: group.profileImageURL,
//                                             fit: BoxFit.cover,
//                                             height: 80,
//                                             width: 80,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(bottom: 8),
//                                       child: _buildFollowerMemberDisplayText(group),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   group.name,
//                                   style: GoogleFonts.inter(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 3),
//                                 Text(
//                                   group.description ?? 'No description yet',
//                                   style: GoogleFonts.inter(
//                                     color: Colors.grey[600],
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 GroupAssociationButtons(groupModel: group, prefs: prefs),
//                                 const SizedBox(height: 50),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     bottom: PreferredSize(
//                       preferredSize: Size(getViewportWidth(context), 50),
//                       child: Container(
//                         color: Colors.white,
//                         child: TabBar(
//                           indicatorSize: TabBarIndicatorSize.label,
//                           labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
//                           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//                           labelColor: prefs.getPrimaryColor(),
//                           unselectedLabelColor: Colors.grey[600],
//                           indicatorColor: prefs.getPrimaryColor(),
//                           labelPadding: const EdgeInsets.symmetric(horizontal: 5),
//                           tabs: const [
//                             Tab(text: 'FEED'),
//                             Tab(text: 'EVENTS'),
//                             Tab(text: 'POLLS'),
//                             Tab(text: 'FILES'),
//                             Tab(text: 'ABOUT'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ];
//               },
//               body: LayoutBuilder(
//                 builder: (context, constraints) {
//                   nestedScrollController.enableScroll(context);
//                   nestedScrollController.enableCenterScroll(constraints);
//                   return userAsyncValue.when(
//                       data: (user) {
//                         return TabBarView(
//                           children: [
//                             Column(
//                               children: [
//                                 if(_profileNeedsMoreSetup(group))
//                                   _buildGroupProfileFinisher(group, prefs),
//                                 Expanded(child: FeedList(query: feedQuery!, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12))),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//                               child: EventsList(query: EventsQuery(user: user, groupID: group.id), isMainFeed: false),
//                             ),
//                             Center(
//                                 child: Text(
//                                   'Polls are still in development',
//                                   style: GoogleFonts.inter(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.grey
//                                   ),
//                                 )
//                             ),
//                             Center(
//                                 child: Text(
//                                   'Files are still in development',
//                                   style: GoogleFonts.inter(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.grey
//                                   ),
//                                 )
//                             ),
//                             _buildAboutSection(group),
//                           ],
//                         );
//                       },
//                       loading: () => Center(child: PlatformCircularProgressIndicator()),
//                       error: (_,__) => const Text('Error')
//                   );
//                 },
//               ),
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () => RoutingUtil.pushAsync(context, CreatePost(groupModel: group), fullscreenDialog: true),
//             backgroundColor: prefs.getPrimaryColor(),
//             child: const Icon(
//               Icons.create,
//             ),
//           ),
//         );
//       },
//       loading: () => PlatformCircularProgressIndicator(),
//       error: (_,__) => const Text('Error'),
//     );
//   }

  Widget _buildFollowerMemberDisplayText(GroupModel groupModel) {
    return Row(
      children: [
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              Text(
                '${groupModel.followerIDs.length}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'Followers',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {},
          child: Row(
            children: [
              Text(
                '${groupModel.memberIDs.length}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                groupModel.memberIDs.length > 1 ? 'Members' : 'Member',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _buildAboutSection(GroupModel groupModel) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildSponsorCard(groupModel.sponsorID ?? ''),
          const SizedBox(height: 10),
          _buildGroupMembersCard(groupModel)
        ],
      )
    );
  }

  Widget _buildSponsorCard(String sponsorID) {
    final sponsorAsyncValue = ref.watch(getUserStreamProvider(sponsorID));
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 15
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsor',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          const Divider(height: 14),
          const SizedBox(height: 2),
          sponsorAsyncValue.when(
            data: (user) {
              return ZAPListTile(
                horizontalTitleGap: 8,
                titleSubtitleGap: 1,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(user.profileImageURL),
                ),
                title: Text(
                  '${user.firstName} ${user.lastName}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_,__) => const Text('Error'),
          )
        ],
      ),
    );
  }

  Widget _buildGroupMembersCard(GroupModel groupModel) {
    List memberIDs = groupModel.memberIDs.isEmpty ? [''] : groupModel.memberIDs;
    final membersAsyncValue = ref.watch(getManyUsersStreamProvider(memberIDs));
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 15
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Members',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          const Divider(height: 14),
          const SizedBox(height: 2),
          membersAsyncValue.when(
            data: (members) {
              return ListView.builder(
                itemCount: members.length < 5 ? members.length : 5,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ZAPListTile(
                    titleSubtitleGap: 1,
                    horizontalTitleGap: 8,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(member.profileImageURL),
                    ),
                    title: Text(
                      '${member.firstName} ${member.lastName}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      member.email,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  );
                },
              );
            },
            loading: () => Center(
                child: Text(
                  'No members found.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey
                  ),
                )
            ),
            error: (e,__) => Text(e.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupProfileFinisher(GroupModel groupModel, AppConfiguration prefs) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), //0.35
              spreadRadius: 3,
              blurRadius: 24,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue setting up ${groupModel.name}',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Customize your group to attract to members and followers.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          if(groupModel.description! == 'No description has been added yet.')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ZAPListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
                horizontalTitleGap: 10,
                title: Text(
                  'Add a description',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: prefs.getPrimaryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.add,
                    color: prefs.getPrimaryColor(),
                    size: 22,
                  ),
                ),
              ),
            ),
          if(groupModel.backgroundImageURL == null || groupModel.backgroundImageURL!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ZAPListTile(
                leading: const Icon(
                  Icons.photo_size_select_actual,
                  color: Colors.black,
                ),
                horizontalTitleGap: 10,
                title: Text(
                  'Add background photo',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: prefs.getPrimaryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.add,
                    color: prefs.getPrimaryColor(),
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}