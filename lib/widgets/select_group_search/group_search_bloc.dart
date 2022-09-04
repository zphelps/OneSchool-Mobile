import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/PostModel.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';

class GroupSearchNotifier extends ChangeNotifier{

  List<GroupModel> _data = [];
  List<GroupModel> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<DocumentSnapshot> _snap = [];

  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool? _hasData;
  bool? get hasData => _hasData;

  String? currentQuery;

  Future<void> getData(mounted, String? query, Future<bool> Function(GroupModel)? filter) async {
    QuerySnapshot rawData;
    currentQuery = query;

    if (lastVisible == null) {
      rawData = await FirebaseFirestore.instance
          .collection('tenants').doc(FBDatabase.tenantID).collection('groups')
          .orderBy('name', descending: true)
          .limit(10)
          .get();
    } else {
      rawData = await FirebaseFirestore.instance
          .collection('tenants').doc(FBDatabase.tenantID).collection('groups')
          .orderBy('name', descending: true)
          .startAfter([lastVisible!['id']])
          .limit(5)
          .get();
    }

    if (rawData.docs.isNotEmpty) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.addAll(rawData.docs);
        _data = _snap.where((element) {
          if(query != null) {
            return element.get('name').toLowerCase().contains(query.toLowerCase());
          }
          return true;
        }).map((e) => GroupModel.fromMap(e.data() as Map<String, dynamic>, e.id)).toList();
        if(filter != null) {
          List<GroupModel> filteredData = [];
          await Future.forEach(_data, (GroupModel element) async {
            if(await filter(element)) {
              filteredData.add(element);
            }
          });
          _data = filteredData;
        }
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


  onRefresh(mounted, String? query, Future<bool> Function(GroupModel)? filter) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, query, filter);
    notifyListeners();
  }



}