import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sea/models/RSVPPermissionsModel.dart';

import 'LocationModel.dart';

@immutable
class GameModel extends Equatable{
  final String id;
  final String season;
  final String groupID;
  final String eventID;
  final String opponentID;
  final bool isHome;
  final bool isMarkedDone;
  final LocationModel location;
  final String dateTimeString;
  final int? homeTeamScore;
  final int? opposingTeamScore;
  final String? livestreamID;
  final List<dynamic> usersWhoCanUpdateAndScoreGame;

  const GameModel({
    required this.id,
    required this.season,
    required this.eventID,
    required this.groupID,
    required this.opponentID,
    required this.isHome,
    required this.isMarkedDone,
    required this.location,
    required this.dateTimeString,
    required this.homeTeamScore,
    required this.opposingTeamScore,
    required this.livestreamID,
    required this.usersWhoCanUpdateAndScoreGame,
  });

  @override
  List<dynamic> get props => [
    id,
    season,
    eventID,
    groupID,
    opponentID,
    isHome,
    isMarkedDone,
    location,
    dateTimeString,
    homeTeamScore,
    opposingTeamScore,
    livestreamID,
    usersWhoCanUpdateAndScoreGame,
  ];

  @override
  bool get stringify => true;

  factory GameModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for game model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for game model: $documentId');
    }

    final season = data['season'] as String?;
    if (season == null) {
      throw StateError('missing season for game model: $documentId');
    }

    final eventID = data['eventID'] as String?;
    if (eventID == null) {
      throw StateError('missing eventID for game model: $documentId');
    }

    final groupID = data['groupID'] as String?;
    if (groupID == null) {
      throw StateError('missing groupID for game model: $documentId');
    }

    final opponentID = data['opponentID'] as String?;
    if (opponentID == null) {
      throw StateError('missing opponentID for game model: $documentId');
    }

    final isHome = data['isHome'] as bool?;
    if (isHome == null) {
      throw StateError('missing isHome for game model: $documentId');
    }

    final isMarkedDone = data['isMarkedDone'] as bool?;
    if (isMarkedDone == null) {
      throw StateError('missing isMarkedDone for game model: $documentId');
    }

    final location = LocationModel.fromMap(data['location'] as Map<String, dynamic>?);

    final dateTimeString = data['dateTimeString'] as String?;
    if (dateTimeString == null) {
      throw StateError('missing dateTimeString for game model: $documentId');
    }

    final homeTeamScore = data['homeTeamScore'];

    final opposingTeamScore = data['opposingTeamScore'];

    final livestreamID = data['livestreamID'];

    final usersWhoCanUpdateAndScoreGame = data['usersWhoCanUpdateAndScoreGame'] ?? [''];

    return GameModel(
      id: id,
      season: season,
      eventID: eventID,
      groupID: groupID,
      opponentID: opponentID,
      isHome: isHome,
      isMarkedDone: isMarkedDone,
      location: location,
      dateTimeString: dateTimeString,
      homeTeamScore: homeTeamScore,
      opposingTeamScore: opposingTeamScore,
      livestreamID: livestreamID,
      usersWhoCanUpdateAndScoreGame: usersWhoCanUpdateAndScoreGame,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'season': season,
      'eventID': eventID,
      'groupID': groupID,
      'opponentID': opponentID,
      'isHome': isHome,
      'isMarkedDone': isMarkedDone,
      'location': location.toMap(),
      'dateTimeString': dateTimeString,
      'homeTeamScore': homeTeamScore,
      'opposingTeamScore': opposingTeamScore,
      'livestreamID': livestreamID,
      'usersWhoCanUpdateAndScoreGame': usersWhoCanUpdateAndScoreGame,
    };
  }
}