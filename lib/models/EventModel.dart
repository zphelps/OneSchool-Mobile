import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sea/models/PrivacyLevel.dart';
import 'package:sea/models/RSVPPermissionsModel.dart';

import 'LocationModel.dart';

@immutable
class EventModel extends Equatable{
  final String id;
  final String creatorID;
  final String? title;
  final String? imageURL;
  final String? description;
  final String? eventInfoURL;
  final String? groupID;
  final List<dynamic>? userSegmentIDs;
  final String? gameID;
  final LocationModel location;
  final String dateTimeString;
  final RSVPPermissionsModel rsvpPermissions;
  final List<dynamic>? isGoingIDs;
  final List<dynamic>? isNotGoingIDs;
  final PrivacyLevel privacyLevel;

  const EventModel({
    required this.id,
    required this.creatorID,
    required this.title,
    required this.imageURL,
    required this.description,
    required this.eventInfoURL,
    required this.groupID,
    required this.userSegmentIDs,
    required this.gameID,
    required this.location,
    required this.dateTimeString,
    required this.rsvpPermissions,
    required this.isGoingIDs,
    required this.isNotGoingIDs,
    required this.privacyLevel,
  });

  @override
  List<dynamic> get props => [
    id,
    title,
    creatorID,
    imageURL,
    description,
    eventInfoURL,
    groupID,
    userSegmentIDs,
    gameID,
    location,
    dateTimeString,
    rsvpPermissions,
    isGoingIDs,
    isNotGoingIDs,
    privacyLevel,
  ];

  @override
  bool get stringify => true;

  factory EventModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for event model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for event model: $documentId');
    }

    final creatorID = data['creatorID'] as String?;
    if (creatorID == null) {
      throw StateError('missing creatorID for event model: $documentId');
    }

    final title = data['title'];

    final imageURL = data['imageURL'];

    final description = data['description'];// ?? 'No description has been added yet.';

    final eventInfoURL = data['eventInfoURL'];

    final groupID = data['groupID'];

    final userSegmentIDs = data['userSegmentIDs'];

    final gameID = data['gameID'];

    final location = LocationModel.fromMap(data['location'] as Map<String, dynamic>?);

    final dateTimeString = data['dateTimeString'] as String?;
    if (dateTimeString == null) {
      throw StateError('missing dateTimeString for event model: $documentId');
    }

    final rsvpPermissions = RSVPPermissionsModel.fromMap(data['rsvpPermissions'] as Map<String, dynamic>?);

    final isGoingIDs = data['isGoingIDs'] ?? [];

    final isNotGoingIDs = data['isNotGoingIDs'] ?? [];

    final privacyLevel = PrivacyLevel.fromMap(data['privacyLevel'] as Map<String, dynamic>?);

    return EventModel(
      id: id,
      creatorID: creatorID,
      title: title,
      imageURL: imageURL,
      description: description,
      eventInfoURL: eventInfoURL,
      groupID: groupID,
      userSegmentIDs: userSegmentIDs,
      gameID: gameID,
      location: location,
      dateTimeString: dateTimeString,
      rsvpPermissions: rsvpPermissions,
      isGoingIDs: isGoingIDs,
      isNotGoingIDs: isNotGoingIDs,
      privacyLevel: privacyLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorID': creatorID,
      'title': title,
      'imageURL': imageURL,
      'description': description,
      'eventInfoURL': eventInfoURL,
      'groupID': groupID,
      'userSegmentIDs': userSegmentIDs,
      'gameID': gameID,
      'location': location.toMap(),
      'dateTimeString': dateTimeString,
      'rsvpPermissions': rsvpPermissions.toMap(),
      'isGoingIDs': isGoingIDs,
      'isNotGoingIDs': isNotGoingIDs,
      'privacyLevel': privacyLevel.toMap(),
    };
  }
}