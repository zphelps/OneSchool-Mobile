import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'PollChoiceModel.dart';

@immutable
class UserSegment extends Equatable{
  final String id;
  final String name;

  const UserSegment({
    required this.id,
    required this.name,
  });

  @override
  List<dynamic> get props => [
    id,
    name,
  ];

  @override
  bool get stringify => true;

  factory UserSegment.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for user segment model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for user segment model: $documentId');
    }

    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for user segment model: $documentId');
    }

    return UserSegment(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}