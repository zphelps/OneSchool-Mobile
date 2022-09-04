import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:tuple/tuple.dart';

import '../../enums.dart';

final feedProvider = ChangeNotifierProvider.autoDispose<FeedNotifier>((ref) {
  return FeedNotifier();
});

final groupFeedProvider = ChangeNotifierProvider.autoDispose<FeedNotifier>((ref) {
  return FeedNotifier();
});

final mediaFeedProvider = ChangeNotifierProvider.autoDispose<FeedNotifier>((ref) {
  return FeedNotifier();
});

class FeedNotifier extends ChangeNotifier{

  List<PostModel> _data = [];
  List<PostModel> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _snap = [];

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool? _hasData;
  bool? get hasData => _hasData;

  Tuple5<String?, String?, bool?, bool, SEAUser?>? currentQuery;

  Future<void> getData(mounted, Tuple5<String?, String?, bool?, bool, SEAUser?> query) async {
    QuerySnapshot rawData;
    currentQuery = query;

    rawData = await FBDatabase.getPostRawData(query, _lastVisible);

    if (rawData.docs.isNotEmpty) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        List<dynamic> groupsFollowing = await FBDatabase.getGroupsUserIsFollowing(query.item2!);
        List<dynamic> groupsMemberOf = await FBDatabase.getGroupsUserIsMemberOf(query.item2!);
        _isLoading = false;
        _snap.addAll(rawData.docs);

        _data = _snap.map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>, e.id)).where((element) {
          if(query.item5 != null && (query.item5!.userRole! == UserRole.administrator || query.item5!.userRole! == UserRole.manager)) {
            return true;
          }
          else if(element.groupID != null) {
            bool isFollower = groupsFollowing.contains(element.groupID);
            bool isMember = groupsMemberOf.contains(element.groupID);
            if(element.privacyLevel.isVisibleToFollowers == false && !isMember) {
              return false;
            }
            else if(element.privacyLevel.isVisibleToPublic == false && (!isFollower && !isMember)) {
              return false;
            }
            return true;
          }
          else {
            for(var segment in element.userSegmentIDs ?? []) {
              if((query.item5!.userSegmentIDs ?? []).contains(segment)
                  || query.item5!.userRole == UserRole.administrator
                  || query.item5!.userRole == UserRole.manager) {
                return true;
              }
            }
            return false;
          }
        }).toList();
        notifyListeners();
      }
    } else {

      if(_lastVisible == null){

        _isLoading = false;
        _hasData = false;
        print('no items');

      }else{
        _isLoading = false;
        _hasData = true;
        print('no more items');
      }

    }
    notifyListeners();
    return;
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }


  onRefresh(mounted, Tuple5<String?, String?, bool?, bool, SEAUser?> query) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, query);
    notifyListeners();
  }



}