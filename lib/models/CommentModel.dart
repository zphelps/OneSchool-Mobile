import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class CommentModel extends Equatable{
  final String id;
  final String postID;
  final String authorID;
  final String body;
  final String postedAt;

  const CommentModel({
    required this.id,
    required this.postID,
    required this.authorID,
    required this.postedAt,
    required this.body,
  });

  @override
  List<dynamic> get props => [
    id,
    postID,
    authorID,
    postID,
    postedAt,
    body,
  ];

  @override
  bool get stringify => true;

  factory CommentModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for comment model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for comment model: $documentId');
    }

    final postID = data['postID'] as String?;
    if (postID == null) {
      throw StateError('missing postID for comment model: $documentId');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing body for comment model: $documentId');
    }


    final postedAt = data['postedAt'] as String?;
    if (postedAt == null) {
      throw StateError('missing postedAt for comment model: $documentId');
    }

    final authorID = data['authorID'] as String?;
    if (authorID == null) {
      throw StateError('missing authorID for comment model: $documentId');
    }

    return CommentModel(
      id: id,
      body: body,
      postedAt: postedAt,
      authorID: authorID,
      postID: postID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body': body,
      'postedAt': postedAt,
      'authorID': authorID,
      'postID': postID,
    };
  }
}