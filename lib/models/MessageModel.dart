import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class MessageModel extends Equatable{
  final String id;
  final String createdAt;
  final String senderID;
  final String senderFirstName;
  final String senderLastName;
  final String body;
  final String? imageURL;
  final String? videoURL;
  final String? url;

  const MessageModel({
    required this.id,
    required this.createdAt,
    required this.senderID,
    required this.senderFirstName,
    required this.senderLastName,
    required this.body,
    required this.imageURL,
    required this.videoURL,
    required this.url,
  });

  @override
  List<dynamic> get props => [
    id,
    createdAt,
    senderID,
    senderFirstName,
    senderLastName,
    body,
    imageURL,
    videoURL,
    url,
  ];

  @override
  bool get stringify => true;

  factory MessageModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for message model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for message model: $documentId');
    }

    final createdAt = data['createdAt'] as String?;
    if (createdAt == null) {
      throw StateError('missing createdAt for message model: $documentId');
    }

    final senderID = data['senderID'] as String?;
    if (senderID == null) {
      throw StateError('missing senderID for message model: $documentId');
    }

    final senderFirstName = data['senderFirstName'] as String?;
    if (senderFirstName == null) {
      throw StateError('missing senderFirstName for message model: $documentId');
    }

    final senderLastName = data['senderLastName'] as String?;
    if (senderLastName == null) {
      throw StateError('missing senderLastName for message model: $documentId');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing body for message model: $documentId');
    }

    final imageURL = data['imageURL'];

    final videoURL = data['videoURL'];

    final url = data['url'];

    return MessageModel(
      id: id,
      createdAt: createdAt,
      senderID: senderID,
      senderFirstName: senderFirstName,
      senderLastName: senderLastName,
      body: body,
      imageURL: imageURL,
      videoURL: videoURL,
      url: url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'senderID': senderID,
      'senderFirstName': senderFirstName,
      'senderLastName': senderLastName,
      'body': body,
      'imageURL': imageURL,
      'videoURL': videoURL,
      'url': url,
    };
  }
}