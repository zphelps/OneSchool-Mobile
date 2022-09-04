import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class ConversationModel extends Equatable{
  final String id;
  final String creatorID;
  final String lastMessage;
  final String lastMessageDate;
  final String? name;
  final String? imageURL;
  final List<dynamic> recipients;
  final String? groupID;
  final bool isGroupConversation;

  const ConversationModel({
    required this.id,
    required this.creatorID,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.imageURL,
    required this.name,
    required this.recipients,
    required this.groupID,
    required this.isGroupConversation,
  });

  @override
  List<dynamic> get props => [
    id,
    creatorID,
    lastMessage,
    lastMessageDate,
    imageURL,
    name,
    recipients,
    groupID,
    isGroupConversation,
  ];

  @override
  bool get stringify => true;

  factory ConversationModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for message channel model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for message channel model: $documentId');
    }

    final creatorID = data['creatorID'] as String?;
    if (creatorID == null) {
      throw StateError('missing creatorID for message channel model: $documentId');
    }

    final lastMessage = data['lastMessage'] as String?;
    if (lastMessage == null) {
      throw StateError('missing lastMessage for message channel model: $documentId');
    }

    final lastMessageDate = data['lastMessageDate'] as String?;
    if (lastMessageDate == null) {
      throw StateError('missing lastMessageDate for message channel model: $documentId');
    }

    final imageURL = data['imageURL'] as String?;

    final name = data['name'] as String?;

    final recipients = data['recipients'] as List<dynamic>?;
    if (recipients == null) {
      throw StateError('missing recipients for message channel model: $documentId');
    }

    final groupID = data['groupID'] as String?;

    final isGroupConversation = data['isGroupConversation'] as bool?;
    if (isGroupConversation == null) {
      throw StateError('missing isGroupConversation for message channel model: $documentId');
    }

    return ConversationModel(
      id: id,
      creatorID: creatorID,
      lastMessage: lastMessage,
      lastMessageDate: lastMessageDate,
      imageURL: imageURL,
      name: name,
      recipients: recipients,
      groupID: groupID,
      isGroupConversation: isGroupConversation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorID': creatorID,
      'lastMessage': lastMessage,
      'lastMessageDate': lastMessageDate,
      'imageURL': imageURL,
      'name': name,
      'recipients': recipients,
      'groupID': groupID,
      'isGroupConversation': isGroupConversation,
    };
  }
}