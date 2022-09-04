
import 'package:equatable/equatable.dart';

class SEAUserPermissionsModel extends Equatable {
  final bool fullAdmin;
  final bool canCreateGroups;
  final bool canCreateGroupAssociatedEvents;
  final bool canCreateNonGroupAssociatedEvents;

  SEAUserPermissionsModel({
    required this.fullAdmin,
    required this.canCreateGroups,
    required this.canCreateGroupAssociatedEvents,
    required this.canCreateNonGroupAssociatedEvents
  });

  @override
  List<dynamic> get props => [
    fullAdmin,
    canCreateGroups,
    canCreateGroupAssociatedEvents,
    canCreateNonGroupAssociatedEvents
  ];

  @override
  bool get stringify => true;

  factory SEAUserPermissionsModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for user permissions model');
    }

    final fullAdmin = data['fullAdmin'] as bool?;
    if (fullAdmin == null) {
      throw StateError('missing fullAdmin for user permissions model');
    }

    final canCreateGroups = data['canCreateGroups'] as bool?;
    if (canCreateGroups == null) {
      throw StateError('missing canCreateGroups for user permissions model');
    }

    final canCreateGroupAssociatedEvents = data['canCreateGroupAssociatedEvents'] as bool?;
    if (canCreateGroupAssociatedEvents == null) {
      throw StateError('missing canCreateGroupAssociatedEvents for user permissions model');
    }

    final canCreateNonGroupAssociatedEvents = data['canCreateNonGroupAssociatedEvents'] as bool?;
    if (canCreateNonGroupAssociatedEvents == null) {
      throw StateError('missing canCreateNonGroupAssociatedEvents for user permissions model');
    }

    return SEAUserPermissionsModel(
      fullAdmin: fullAdmin,
      canCreateGroups: canCreateGroups,
      canCreateGroupAssociatedEvents: canCreateGroupAssociatedEvents,
      canCreateNonGroupAssociatedEvents: canCreateNonGroupAssociatedEvents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullAdmin': fullAdmin,
      'canCreateGroups': canCreateGroups,
      'canCreateGroupAssociatedEvents': canCreateGroupAssociatedEvents,
      'canCreateNonGroupAssociatedEvents': canCreateNonGroupAssociatedEvents,
    };
  }

}