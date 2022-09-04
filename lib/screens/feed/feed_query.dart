import 'package:sea/models/SEAUser.dart';
import 'package:tuple/tuple.dart';

// class FeedQuery {
//   final String? groupID;
//   final String? uid;
//   final bool? containsMedia;
//   final bool isMainFeed;
//   final List<dynamic>? userSegmentIDs;
//
//   const FeedQuery({
//     this.groupID,
//     this.uid,
//     this.containsMedia,
//     required this.isMainFeed,
//     this.userSegmentIDs,
//   });
// }

Tuple5<String?, String?, bool?, bool, SEAUser?> FeedQuery({String? groupID, required bool isMainFeed, String? uid, bool? containsMedia, SEAUser? user}) {
  return Tuple5(groupID, uid, containsMedia, isMainFeed, user);
}
