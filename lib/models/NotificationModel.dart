import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class NotificationModel extends Equatable{
  final String id;
  final String title;
  final String body;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  @override
  List<dynamic> get props => [
    id,
    title,
    body,
    createdAt,
  ];

  @override
  bool get stringify => true;

  factory NotificationModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for notification model');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for notification model');
    }

    final title = data['title'] as String?;
    if (title == null) {
      throw StateError('missing title for notification model');
    }

    final body = data['body'] as String?;
    if (body == null) {
      throw StateError('missing body for notification model');
    }

    final createdAt = data['createdAt'] as String?;
    if (createdAt == null) {
      throw StateError('missing createdAt for notification model');
    }

    return NotificationModel(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt
    };
  }
}