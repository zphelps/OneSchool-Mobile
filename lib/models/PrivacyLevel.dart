import 'package:equatable/equatable.dart';

class PrivacyLevel extends Equatable {
  final bool? isVisibleToPublic;
  final bool? isVisibleToMembers;
  final bool? isVisibleToFollowers;

  const PrivacyLevel({
    this.isVisibleToPublic,
    this.isVisibleToFollowers,
    this.isVisibleToMembers,
  });

  @override
  List<dynamic> get props => [
    isVisibleToPublic,
    isVisibleToMembers,
    isVisibleToFollowers,
  ];

  @override
  bool get stringify => true;

  factory PrivacyLevel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for note model');
    }

    final isVisibleToPublic = data['isVisibleToPublic'] as bool?;

    final isVisibleToMembers = data['isVisibleToMembers'] as bool?;

    final isVisibleToFollowers = data['isVisibleToFollowers'] as bool?;

    return PrivacyLevel(
      isVisibleToPublic: isVisibleToPublic,
      isVisibleToMembers: isVisibleToMembers,
      isVisibleToFollowers: isVisibleToFollowers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isVisibleToPublic': isVisibleToPublic,
      'isVisibleToMembers': isVisibleToMembers,
      'isVisibleToFollowers': isVisibleToFollowers,
    };
  }

}