import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class OpponentModel extends Equatable{
  final String id;
  final String name;
  final String logoURL;

  const OpponentModel({
    required this.id,
    required this.name,
    required this.logoURL,
  });

  @override
  List<dynamic> get props => [
    id,
    name,
    logoURL,
  ];

  @override
  bool get stringify => true;

  factory OpponentModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for opponent model');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for opponent model');
    }

    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for opponent model');
    }

    final logoURL = data['logoURL'] as String?;
    if (logoURL == null) {
      throw StateError('missing logoURL for opponent model');
    }

    return OpponentModel(
      id: id,
      name: name,
      logoURL: logoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoURL': logoURL,
    };
  }
}