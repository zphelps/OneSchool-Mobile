import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:duration/duration.dart';
import 'PollChoiceModel.dart';
import 'UserSegment.dart';

@immutable
class AlertModel extends Equatable{
  final String id;
  final String creatorID;
  final String title;
  final String body;
  final String postedAt;
  final List<dynamic> userSegmentIDs;
  final bool pinned;
  final Duration pinDuration;

  const AlertModel({
    required this.id,
    required this.creatorID,
    required this.title,
    required this.body,
    required this.postedAt,
    required this.userSegmentIDs,
    required this.pinned,
    required this.pinDuration,
  });

  @override
  List<dynamic> get props => [
    id,
    creatorID,
    title,
    body,
    postedAt,
    userSegmentIDs,
    pinned,
    pinDuration,
  ];

  @override
  bool get stringify => true;

  factory AlertModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for user segment model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for user segment model: $documentId');
    }

    final creatorID = data['creatorID'] as String?;
    if (creatorID == null) {
      throw StateError('missing creatorID for user segment model: $documentId');
    }

    final title = data['title'] as String?;
    if (title == null) {
      throw StateError('missing title for user segment model: $documentId');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing body for user segment model: $documentId');
    }

    final postedAt = data['postedAt'] as String?;
    if (postedAt == null) {
      throw StateError('missing postedAt for user segment model: $documentId');
    }

    final userSegmentIDs = data['userSegmentIDs'] as List<dynamic>?;
    if (userSegmentIDs == null) {
      throw StateError('missing userSegmentIDs for user segment model: $documentId');
    }

    final pinned = data['pinned'] as bool?;
    if (pinned == null) {
      throw StateError('missing pinned for user segment model: $documentId');
    }

    final pinDuration = parseTime(data['pinDuration'] as String);

    return AlertModel(
      id: id,
      creatorID: creatorID,
      title: title,
      body: body,
      postedAt: postedAt,
      userSegmentIDs: userSegmentIDs,
      pinned: pinned,
      pinDuration: pinDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorID': creatorID,
      'title': title,
      'body': body,
      'postedAt': postedAt,
      'userSegmentIDs': userSegmentIDs,
      'pinned': pinned,
      'pinDuration': pinDuration.toString(),
    };
  }
}