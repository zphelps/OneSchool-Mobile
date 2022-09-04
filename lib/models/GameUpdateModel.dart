import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class GameUpdateModel extends Equatable{
  final String id;
  final String gameID;
  final String authorID;
  final String body;
  final String postedAt;

  const GameUpdateModel({
    required this.id,
    required this.gameID,
    required this.authorID,
    required this.postedAt,
    required this.body,
  });

  @override
  List<dynamic> get props => [
    id,
    gameID,
    authorID,
    postedAt,
    body,
  ];

  @override
  bool get stringify => true;

  factory GameUpdateModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for game update model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for game update model: $documentId');
    }

    final gameID = data['gameID'] as String?;
    if (gameID == null) {
      throw StateError('missing gameID for game update model: $documentId');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing body for game update model: $documentId');
    }

    final postedAt = data['postedAt'] as String?;
    if (postedAt == null) {
      throw StateError('missing postedAt for game update model: $documentId');
    }

    final authorID = data['authorID'] as String?;
    if (authorID == null) {
      throw StateError('missing authorID for game update model: $documentId');
    }

    return GameUpdateModel(
      id: id,
      body: body,
      postedAt: postedAt,
      authorID: authorID,
      gameID: gameID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body': body,
      'postedAt': postedAt,
      'authorID': authorID,
      'gameID': gameID,
    };
  }
}