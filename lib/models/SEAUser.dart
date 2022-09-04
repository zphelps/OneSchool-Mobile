import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sea/models/SEAUserPermissionsModel.dart';

import '../enums.dart';
import 'PushNotificationSettingsModel.dart';
import 'UserSegment.dart';

@immutable
class SEAUser extends Equatable{
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String profileImageURL;
  final int? phoneNumber;
  final PushNotificationSettingModel pushNotificationSettings;
  final String? fcmToken;
  final UserRole? userRole;
  final List<dynamic>? userSegmentIDs;
  final SEAUserPermissionsModel userPermissions;
  final List<dynamic>? groupsFollowing;
  final List<dynamic>? groupsMemberOf;
  final List<dynamic>? groupsOwnerOf;

  const SEAUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.pushNotificationSettings,
    required this.fcmToken,
    required this.userRole,
    required this.userSegmentIDs,
    required this.userPermissions,
    required this.groupsFollowing,
    required this.groupsMemberOf,
    required this.groupsOwnerOf,
    required this.profileImageURL,
  });

  @override
  List<dynamic> get props => [
    id,
    email,
    firstName,
    lastName,
    profileImageURL,
    phoneNumber,
    pushNotificationSettings,
    fcmToken,
    userRole,
    userSegmentIDs,
    userPermissions,
    groupsFollowing,
    groupsMemberOf,
    groupsOwnerOf,
  ];

  @override
  bool get stringify => true;

  factory SEAUser.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for SEAUser model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for SEAUser model: $documentId');
    }

    final email = data['email'] as String?;
    if (email == null) {
      throw StateError('missing email for SEAUser model: $documentId');
    }

    final firstName = data['firstName'] as String?;
    if (firstName == null) {
      throw StateError('missing firstName for SEAUser model: $documentId');
    }

    final lastName = data['lastName'] as String?;
    if (lastName == null) {
      throw StateError('missing lastName for SEAUser model: $documentId');
    }

    final phoneNumber = data['phoneNumber'];

    final profileImageURL = data['profileImageURL'] ?? 'https://uploads-ssl.webflow.com/6100cd53975cf962f681e5c6/619d321a4d4109e7c1f19a9a_SeniorPhotoHeadshot-p-500.jpeg';

    final pushNotificationSettings = PushNotificationSettingModel.fromMap(data['pushNotificationSettings'] as Map<String, dynamic>?);

    final fcmToken = data['fcmToken'];

    final userRole = stringToUserRole(data['userRole']);

    final userSegmentIDs = data['userSegmentIDs'];

    final userPermissions = SEAUserPermissionsModel.fromMap(data['userPermissions'] as Map<String, dynamic>?);

    final groupsFollowing = data['groupsFollowing'] ?? [];

    final groupsMemberOf = data['groupsMemberOf'] ?? [];

    final groupsOwnerOf = data['groupsOwnerOf'] ?? [];

    return SEAUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      profileImageURL: profileImageURL,
      pushNotificationSettings: pushNotificationSettings,
      fcmToken: fcmToken,
      userSegmentIDs: userSegmentIDs,
      userRole: userRole,
      userPermissions: userPermissions,
      groupsFollowing: groupsFollowing,
      groupsMemberOf: groupsMemberOf,
      groupsOwnerOf: groupsOwnerOf,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageURL': profileImageURL,
      'pushNotificationSettings': pushNotificationSettings.toMap(),
      'fcmToken': fcmToken,
      'userSegmentIDs': userSegmentIDs,
      'userRole': userRole?.name,
      'userRoles': userPermissions.toMap(),
      'groupsFollowing': groupsFollowing,
      'groupsMemberOf': groupsMemberOf,
      'groupsOwnerOf': groupsOwnerOf,
    };
  }
}