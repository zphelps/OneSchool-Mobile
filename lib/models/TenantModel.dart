import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../enums.dart';

@immutable
class TenantModel extends Equatable{
  final String tenantID;
  final String name;
  final String logoURL;
  final String primaryColorString;

  //Moderation
  final bool enableModeration;
  final bool blockModeratedContent;

  //Post Preferences
  final List<UserRole> userRolesThatCanPostInMainFeed;

  //Event Preferences
  final List<UserRole> userRolesThatCanCreateEventsInMainFeed;

  //Alert Preferences
  final List<UserRole> userRolesThatCanManageAlerts;

  //Messaging Preferences
  final bool enableDirectMessaging;
  final bool enableGroupMessaging;
  final bool allowMessagingBetweenAdministratorsManagersTeachersStaff;
  final bool allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff;
  final bool allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff;
  final bool allowMessagingBetweenStudentLeadersAndStudents;
  final bool allowMessagingBetweenStudentLeaders;
  final bool allowMessagingBetweenStudent;

  const TenantModel({
    required this.tenantID,
    required this.name,
    required this.logoURL,
    required this.primaryColorString,

    required this.enableModeration,
    required this.blockModeratedContent,

    required this.userRolesThatCanPostInMainFeed,

    required this.userRolesThatCanCreateEventsInMainFeed,

    required this.userRolesThatCanManageAlerts,

    required this.enableDirectMessaging,
    required this.enableGroupMessaging,
    required this.allowMessagingBetweenAdministratorsManagersTeachersStaff,
    required this.allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff,
    required this.allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff,
    required this.allowMessagingBetweenStudentLeadersAndStudents,
    required this.allowMessagingBetweenStudentLeaders,
    required this.allowMessagingBetweenStudent,
  });


  @override
  List<dynamic> get props => [
    tenantID,
    name,
    logoURL,
    primaryColorString,

    enableModeration,
    blockModeratedContent,

    userRolesThatCanPostInMainFeed,

    userRolesThatCanCreateEventsInMainFeed,

    userRolesThatCanManageAlerts,

    enableDirectMessaging,
    enableGroupMessaging,
    allowMessagingBetweenAdministratorsManagersTeachersStaff,
    allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff,
    allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff,
    allowMessagingBetweenStudentLeadersAndStudents,
    allowMessagingBetweenStudentLeaders,
    allowMessagingBetweenStudent,
  ];

  @override
  bool get stringify => true;

  Color getPrimaryColor() {
    return Color(int.parse(primaryColorString.split('(0x')[1].split(')')[0], radix: 16));
  }

  factory TenantModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for note model: $documentId');
    }

    final tenantID = data['tenantID'] as String?;
    if (tenantID == null) {
      throw StateError('missing tenantID for SchoolConfigurationSettingsModal: $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for SchoolConfigurationSettingsModal: $documentId');
    }
    final logoURL = data['logoURL'] ?? 'StudentEngage';
    final primaryColorString = data['primaryColorString'] ?? 'Color(0xff000000)';

    final enableModeration = data['enableModeration'] as bool?;
    if (enableModeration == null) {
      throw StateError('missing enableModeration for SchoolConfigurationSettingsModal: $documentId');
    }
    final blockModeratedContent = data['blockModeratedContent'] as bool?;
    if (blockModeratedContent == null) {
      throw StateError('missing blockModeratedContent for SchoolConfigurationSettingsModal: $documentId');
    }

    List<UserRole> userRolesThatCanPostInMainFeed = [];
    if (data['userRolesThatCanPostInMainFeed'] == null) {
      throw StateError('missing userRolesThatCanPostInMainFeed for SchoolConfigurationSettingsModal: $documentId');
    }
    for(var role in data['userRolesThatCanPostInMainFeed']) {
      userRolesThatCanPostInMainFeed.add(stringToUserRole(role));
    }

    List<UserRole> userRolesThatCanCreateEventsInMainFeed = [];
    if (data['userRolesThatCanCreateEventsInMainFeed'] == null) {
      throw StateError('missing userRolesThatCanCreateEventsInMainFeed for SchoolConfigurationSettingsModal: $documentId');
    }
    for(var role in data['userRolesThatCanCreateEventsInMainFeed']) {
      userRolesThatCanCreateEventsInMainFeed.add(stringToUserRole(role));
    }

    List<UserRole> userRolesThatCanManageAlerts = [];
    if (data['userRolesThatCanManageAlerts'] == null) {
      throw StateError('missing userRolesThatCanManageAlerts for SchoolConfigurationSettingsModal: $documentId');
    }
    for(var role in data['userRolesThatCanManageAlerts']) {
      userRolesThatCanManageAlerts.add(stringToUserRole(role));
    }

    final enableDirectMessaging = data['enableDirectMessaging'] as bool?;
    if (enableDirectMessaging == null) {
      throw StateError('missing enableDirectMessaging for SchoolConfigurationSettingsModal: $documentId');
    }
    final enableGroupMessaging = data['enableGroupMessaging'] as bool?;
    if (enableGroupMessaging == null) {
      throw StateError('missing enableGroupMessaging for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenAdministratorsManagersTeachersStaff = data['allowMessagingBetweenAdministratorsManagersTeachersStaff'] as bool?;
    if (allowMessagingBetweenAdministratorsManagersTeachersStaff == null) {
      throw StateError('missing allowMessagingBetweenAdministratorsManagersTeachersStaff for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff = data['allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff'] as bool?;
    if (allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff == null) {
      throw StateError('missing allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff = data['allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff'] as bool?;
    if (allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff == null) {
      throw StateError('missing allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenStudentLeadersAndStudents = data['allowMessagingBetweenStudentLeadersAndStudents'] as bool?;
    if (allowMessagingBetweenStudentLeadersAndStudents == null) {
      throw StateError('missing allowMessagingBetweenStudentLeadersAndStudents for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenStudentLeaders = data['allowMessagingBetweenStudentLeaders'] as bool?;
    if (allowMessagingBetweenStudentLeaders == null) {
      throw StateError('missing allowMessagingBetweenStudentLeaders for SchoolConfigurationSettingsModal: $documentId');
    }
    final allowMessagingBetweenStudent = data['allowMessagingBetweenStudent'] as bool?;
    if (allowMessagingBetweenStudent == null) {
      throw StateError('missing allowMessagingBetweenStudent for SchoolConfigurationSettingsModal: $documentId');
    }

    return TenantModel(
      tenantID: tenantID,
      name: name,
      logoURL: logoURL,
      primaryColorString: primaryColorString,

      enableModeration: enableModeration,
      blockModeratedContent: blockModeratedContent,

      userRolesThatCanPostInMainFeed: userRolesThatCanPostInMainFeed,

      userRolesThatCanCreateEventsInMainFeed: userRolesThatCanCreateEventsInMainFeed,

      userRolesThatCanManageAlerts: userRolesThatCanManageAlerts,

      enableDirectMessaging: enableDirectMessaging,
      enableGroupMessaging: enableGroupMessaging,
      allowMessagingBetweenAdministratorsManagersTeachersStaff: allowMessagingBetweenAdministratorsManagersTeachersStaff,
      allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff: allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff,
      allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff: allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff,
      allowMessagingBetweenStudentLeadersAndStudents: allowMessagingBetweenStudentLeadersAndStudents,
      allowMessagingBetweenStudentLeaders: allowMessagingBetweenStudentLeaders,
      allowMessagingBetweenStudent: allowMessagingBetweenStudent,
    );
  }

  Map<String, dynamic> toMap() {
    List<String> userRoleStringsThatCanPostInMainFeed = [];
    for(var role in userRolesThatCanPostInMainFeed) {
      userRoleStringsThatCanPostInMainFeed.add(role.name!);
    }

    List<String> userRoleStringsThatCanCreateEventsInMainFeed = [];
    for(var role in userRolesThatCanCreateEventsInMainFeed) {
      userRoleStringsThatCanCreateEventsInMainFeed.add(role.name!);
    }

    List<String> userRoleStringsThatCanManageAlerts = [];
    for(var role in userRolesThatCanManageAlerts) {
      userRoleStringsThatCanManageAlerts.add(role.name!);
    }

    return {
      'tenantID': tenantID,
      'name': name,
      'logoURL': logoURL,
      'primaryColorString': primaryColorString,

      'enableModeration': enableModeration,
      'blockModeratedContent': blockModeratedContent,

      'userRolesThatCanPostInMainFeed': userRoleStringsThatCanPostInMainFeed,

      'userRolesThatCanCreateEventsInMainFeed': userRoleStringsThatCanCreateEventsInMainFeed,

      'userRolesThatCanManageAlerts': userRoleStringsThatCanManageAlerts,

      'enableDirectMessaging': enableDirectMessaging,
      'enableGroupMessaging': enableGroupMessaging,
      'allowMessagingBetweenAdministratorsManagersTeachersStaff': allowMessagingBetweenAdministratorsManagersTeachersStaff,
      'allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff': allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff,
      'allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff': allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff,
      'allowMessagingBetweenStudentLeadersAndStudents': allowMessagingBetweenStudentLeadersAndStudents,
      'allowMessagingBetweenStudentLeaders': allowMessagingBetweenStudentLeaders,
      'allowMessagingBetweenStudent': allowMessagingBetweenStudent,
    };
  }
}