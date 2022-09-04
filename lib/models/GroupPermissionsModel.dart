import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class GroupPermissionsModel extends Equatable{
  final String id;
  final List<dynamic> canCreatePosts;
  final List<dynamic> canCreateEvents;
  final List<dynamic> canEditGroupInformation;
  final List<dynamic> canAddFiles;
  final List<dynamic> canScoreGames;
  final List<dynamic> canPostGameUpdates;

  const GroupPermissionsModel({
    required this.id,
    required this.canCreatePosts,
    required this.canCreateEvents,
    required this.canEditGroupInformation,
    required this.canAddFiles,
    required this.canScoreGames,
    required this.canPostGameUpdates,
  });

  @override
  List<dynamic> get props => [
    id,
    canCreatePosts,
    canCreateEvents,
    canEditGroupInformation,
    canAddFiles,
    canScoreGames,
    canPostGameUpdates,
  ];

  @override
  bool get stringify => true;

  factory GroupPermissionsModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for group permissions model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for group permissions model: $documentId');
    }

    final canCreatePosts = data['canCreatePosts'] as List<dynamic>?;
    if (canCreatePosts == null) {
      throw StateError('missing canCreatePosts for group permissions model: $documentId');
    }

    final canCreateEvents = data['canCreateEvents'] as List<dynamic>?;
    if (canCreateEvents == null) {
      throw StateError('missing canCreateEvents for group permissions model: $documentId');
    }

    final canEditGroupInformation = data['canEditGroupInformation'] as List<dynamic>?;
    if (canEditGroupInformation == null) {
      throw StateError('missing canEditGroupInformation for group permissions model: $documentId');
    }

    final canAddFiles = data['canAddFiles'] as List<dynamic>?;
    if (canAddFiles == null) {
      throw StateError('missing canAddFiles for group permissions model: $documentId');
    }

    final canScoreGames = data['canScoreGames'] as List<dynamic>?;
    if (canScoreGames == null) {
      throw StateError('missing canScoreGames for group permissions model: $documentId');
    }

    final canPostGameUpdates = data['canPostGameUpdates'] as List<dynamic>?;
    if (canPostGameUpdates == null) {
      throw StateError('missing canPostGameUpdates for group permissions model: $documentId');
    }

    return GroupPermissionsModel(
      id: id,
      canCreatePosts: canCreatePosts,
      canCreateEvents: canCreateEvents,
      canEditGroupInformation: canEditGroupInformation,
      canAddFiles: canAddFiles,
      canScoreGames: canScoreGames,
      canPostGameUpdates: canPostGameUpdates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'canCreatePosts': canCreatePosts,
      'canCreateEvents': canCreateEvents,
      'canEditGroupInformation': canEditGroupInformation,
      'canAddFiles': canAddFiles,
      'canScoreGames': canScoreGames,
      'canPostGameUpdates': canPostGameUpdates,
    };
  }
}