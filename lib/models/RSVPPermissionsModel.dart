import 'package:equatable/equatable.dart';

class RSVPPermissionsModel extends Equatable {
  final bool? membersCanRSVP;
  final bool? followersCanRSVP;
  final bool? publicCanRSVP;

  const RSVPPermissionsModel({
    this.membersCanRSVP,
    this.followersCanRSVP,
    this.publicCanRSVP,
  });

  @override
  List<dynamic> get props => [
    membersCanRSVP,
    followersCanRSVP,
    publicCanRSVP,
  ];

  @override
  bool get stringify => true;

  factory RSVPPermissionsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for rsvp permissions model');
    }

    final membersCanRSVP = data['membersCanRSVP'] as bool?;

    final followersCanRSVP = data['followersCanRSVP'] as bool?;

    final publicCanRSVP = data['publicCanRSVP'] as bool?;

    return RSVPPermissionsModel(
      membersCanRSVP: membersCanRSVP,
      followersCanRSVP: followersCanRSVP,
      publicCanRSVP: publicCanRSVP,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'membersCanRSVP': membersCanRSVP,
      'followersCanRSVP': followersCanRSVP,
      'publicCanRSVP': publicCanRSVP,
    };
  }

}