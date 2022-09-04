import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class GroupModel extends Equatable{
  final String id;
  final String name;
  final String profileImageURL;
  final String? backgroundImageURL;
  final String? description;
  final bool isTeam;
  final bool isPrivate;
  final String creatorID;
  final String? sponsorID;
  final String? groupPermissionsID;
  final List<dynamic> ownerIDs;
  final List<dynamic> memberIDs;
  final List<dynamic> followerIDs;
  final List<dynamic> memberRequestIDs;

  const GroupModel({
    required this.id,
    required this.name,
    required this.profileImageURL,
    required this.backgroundImageURL,
    required this.description,
    required this.isTeam,
    required this.isPrivate,
    required this.sponsorID,
    required this.groupPermissionsID,
    required this.creatorID,
    required this.ownerIDs,
    required this.memberIDs,
    required this.followerIDs,
    required this.memberRequestIDs,
  });

  @override
  List<dynamic> get props => [
    id,
    name,
    profileImageURL,
    backgroundImageURL,
    description,
    isTeam,
    isPrivate,
    groupPermissionsID,
    sponsorID,
    creatorID,
    ownerIDs,
    memberIDs,
    followerIDs,
    memberRequestIDs,
  ];

  @override
  bool get stringify => true;

  factory GroupModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for GroupModel model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for GroupModel model: $documentId');
    }

    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for GroupModel model: $documentId');
    }

    final profileImageURL = data['profileImageURL'] as String?;
    if (profileImageURL == null) {
      throw StateError('missing profileImageURL for GroupModel model: $documentId');
    }

    final backgroundImageURL = data['backgroundImageURL']; //?? 'https://visit.stanford.edu/assets/cardinal/images/home_palm_drive.jpg';

    final description = data['description'] ?? 'No description has been added yet.';

    final sponsorID = data['sponsorID'];

    final isTeam = data['isTeam'] as bool?;
    if (isTeam == null) {
      throw StateError('missing isTeam for GroupModel model: $documentId');
    }

    final isPrivate = data['isPrivate'] as bool?;
    if (isPrivate == null) {
      throw StateError('missing isPrivate for GroupModel model: $documentId');
    }

    final groupPermissionsID = data['groupPermissionsID'];

    final creatorID = data['creatorID'] as String?;
    if (creatorID == null) {
      throw StateError('missing creatorID for GroupModel model: $documentId');
    }

    final ownerIDs = data['ownerIDs'] as List<dynamic>?;
    if (ownerIDs == null) {
      throw StateError('missing ownerIDs for GroupModel model: $documentId');
    }

    final memberIDs = data['memberIDs'] ?? [];

    final followerIDs = data['followerIDs'] ?? [];

    final memberRequestIDs = data['memberRequestIDs'] ?? [];

    return GroupModel(
      id: id,
      name: name,
      profileImageURL: profileImageURL,
      backgroundImageURL: backgroundImageURL,
      description: description,
      isTeam: isTeam,
      isPrivate: isPrivate,
      sponsorID: sponsorID,
      groupPermissionsID: groupPermissionsID,
      creatorID: creatorID,
      ownerIDs: ownerIDs,
      memberIDs: memberIDs,
      followerIDs: followerIDs,
      memberRequestIDs: memberRequestIDs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImageURL': profileImageURL,
      'backgroundImageURL': backgroundImageURL,
      'description': description,
      'isTeam': isTeam,
      'isPrivate': isPrivate,
      'sponsorID': sponsorID,
      'groupPermissionsID': groupPermissionsID,
      'creatorID': creatorID,
      'ownerIDs': ownerIDs,
      'memberIDs': memberIDs,
      'followerIDs': followerIDs,
      'memberRequestIDs': memberRequestIDs,
    };
  }
}