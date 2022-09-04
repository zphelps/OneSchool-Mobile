import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/services/fb_database.dart';
import 'package:tuple/tuple.dart';

import '../../enums.dart';
import '../../models/SEAUser.dart';

final eventsProvider = ChangeNotifierProvider.autoDispose<EventsNotifier>((ref) {
  return EventsNotifier();
});

final eventsUserIsGoingToProvider = ChangeNotifierProvider.autoDispose<EventsNotifier>((ref) {
  return EventsNotifier();
});

final groupEventsProvider = ChangeNotifierProvider.autoDispose<EventsNotifier>((ref) {
  return EventsNotifier();
});

class EventsNotifier extends ChangeNotifier{

  List<EventModel> _data = [];
  List<EventModel> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _snap = [];

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool? _hasData;
  bool? get hasData => _hasData;

  Tuple4<SEAUser?, bool?, String?, String?>? currentQuery;


  Future<void> getData(mounted, Tuple4<SEAUser?, bool?, String?, String?> query) async {
    QuerySnapshot rawData;
    currentQuery = query;

    rawData = await FBDatabase.getEventsRawData(query, _lastVisible);

    if (rawData.docs.isNotEmpty) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);

        _data = _snap.map((e) => EventModel.fromMap(e.data() as Map<String, dynamic>, e.id)).where((element) {
          if(element.groupID != null) {
            bool isFollower = query.item1!.groupsFollowing!.contains(element.groupID);
            bool isMember = query.item1!.groupsMemberOf!.contains(element.groupID);
            if(element.privacyLevel.isVisibleToFollowers == false && !isMember) {
              return false;
            }
            else if(element.privacyLevel.isVisibleToPublic == false && (!isFollower && !isMember)) {
              return false;
            }
            return true;
          }
          else {
            for(var segment in element.userSegmentIDs!) {
              if(query.item1!.userSegmentIDs!.contains(segment)
                  || query.item1!.userRole == UserRole.administrator
                  || query.item1!.userRole == UserRole.manager) {
                return true;
              }
            }
            return false;
          }

        }).toList();

        // _data = _snap.where((element) {
        //   bool isFollower = query.item1!.groupsFollowing!.contains(element.get('groupID'));
        //   bool isMember = query.item1!.groupsMemberOf!.contains(element.get('groupID'));
        //   if(element.get('privacyLevel.isVisibleToFollowers') == false && !isMember) {
        //     return false;
        //   }
        //   else if(element.get('privacyLevel.isVisibleToPublic') == false && (!isFollower && !isMember)) {
        //     return false;
        //   }
        //   return true;
        // }).map((e) => EventModel.fromMap(e.data() as Map<String, dynamic>, e.id)).toList();
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


  onRefresh(mounted, Tuple4<SEAUser?, bool?, String?, String?> query) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, query);
    notifyListeners();
  }

}