import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'PrivacyLevel.dart';
import 'UserSegment.dart';

@immutable
class PostModel extends Equatable{
  final String id;
  final String body;
  final String? title;
  final String postedAt;
  final String authorID;
  final List<dynamic>? userSegmentIDs;
  final String? groupID;
  final String? imageURL;
  final String? videoURL;
  final bool containsMedia;
  final String? url;
  final bool isArticle;
  final bool isAnnouncement;
  final String? pollID;
  final String? gameID;
  final String? eventID;
  final List<dynamic>? likes;
  final int? commentCount;
  final PrivacyLevel privacyLevel;

  const PostModel({
    required this.id,
    required this.body,
    required this.title,
    required this.postedAt,
    required this.authorID,
    required this.userSegmentIDs,
    required this.groupID,
    required this.imageURL,
    required this.videoURL,
    required this.containsMedia,
    required this.url,
    required this.isArticle,
    required this.isAnnouncement,
    required this.pollID,
    required this.gameID,
    required this.eventID,
    required this.likes,
    required this.commentCount,
    required this.privacyLevel,
  });

  @override
  List<dynamic> get props => [
    id,
    body,
    title,
    postedAt,
    authorID,
    userSegmentIDs,
    groupID,
    imageURL,
    videoURL,
    containsMedia,
    url,
    isArticle,
    isAnnouncement,
    pollID,
    gameID,
    eventID,
    likes,
    commentCount,
    privacyLevel,
  ];

  @override
  bool get stringify => true;

  factory PostModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for post model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for post model: $documentId');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing name for post model: $documentId');
    }

    final title = data['title'];

    final postedAt = data['postedAt'] as String?;
    if (postedAt == null) {
      throw StateError('missing postedAt for post model: $documentId');
    }

    final authorID = data['authorID'] as String?;
    if (authorID == null) {
      throw StateError('missing authorID for post model: $documentId');
    }

    final groupID = data['groupID'];

    final userSegmentIDs = data['userSegmentIDs'];

    final imageURL = data['imageURL'];

    final videoURL = data['videoURL'];

    final containsMedia = data['containsMedia'] ?? false;

    final url = data['url'];

    final isArticle = data['isArticle'] as bool?;
    if (isArticle == null) {
      throw StateError('missing isArticle for post model: $documentId');
    }

    final isAnnouncement = data['isAnnouncement'] as bool?;
    if (isAnnouncement == null) {
      throw StateError('missing isAnnouncement for post model: $documentId');
    }

    final pollID = data['pollID'];

    final gameID = data['gameID'];

    final eventID = data['eventID'];

    final likes = data['likes'];

    final commentCount = data['commentCount'];

    final privacyLevel = PrivacyLevel.fromMap(data['privacyLevel'] as Map<String, dynamic>?);

    return PostModel(
      id: id,
      body: body,
      title: title,
      postedAt: postedAt,
      authorID: authorID,
      userSegmentIDs: userSegmentIDs,
      groupID: groupID,
      imageURL: imageURL,
      videoURL: videoURL,
      containsMedia: containsMedia,
      url: url,
      isArticle: isArticle,
      isAnnouncement: isAnnouncement,
      pollID: pollID,
      gameID: gameID,
      eventID: eventID,
      likes: likes,
      commentCount: commentCount,
      privacyLevel: privacyLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body': body,
      'title': title,
      'postedAt': postedAt,
      'authorID': authorID,
      'userSegmentIDs': userSegmentIDs,
      'groupID': groupID,
      'imageURL': imageURL,
      'videoURL': videoURL,
      'containsMedia': containsMedia,
      'url': url,
      'isArticle': isArticle,
      'isAnnouncement': isAnnouncement,
      'pollID': pollID,
      'gameID': gameID,
      'eventID': eventID,
      'likes': likes,
      'commentCount': commentCount,
      'privacyLevel': privacyLevel.toMap(),
    };
  }
}