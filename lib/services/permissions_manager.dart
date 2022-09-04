
import 'package:sea/enums.dart';
import 'package:sea/models/GroupPermissionsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';

import '../models/GroupModel.dart';

class PermissionsManager {

  static Future addMemberToGroup(GroupModel groupModel, String uid) async {
    await FBDatabase.addMemberToGroup(groupModel.id, uid);
  }

  static Future removeMemberFromGroup(GroupModel groupModel, String uid) async {
    await FBDatabase.removeMemberFromGroup(groupModel.id, uid);
    if(groupModel.ownerIDs.contains(uid)) {
      await removeOwnerFromGroup(groupModel, uid);
    }
  }

  static Future addOwnerToGroup(GroupModel groupModel, String uid) async {
    await FBDatabase.addOwnerToGroup(groupModel.id, uid);
    final permissions = await PermissionsManager.groupPermissions(groupID: groupModel.id);
    await FBDatabase.addUserWhoCanCreatePosts(permissions, uid);
    await FBDatabase.addUserWhoCanCreateEvents(permissions, uid);
    await FBDatabase.addUserWhoCanAddFiles(permissions, uid);
  }

  static Future removeOwnerFromGroup(GroupModel groupModel, String uid) async {
    await FBDatabase.removeOwnerFromGroup(groupModel.id, uid);
    final permissions = await PermissionsManager.groupPermissions(groupID: groupModel.id);
    await FBDatabase.removeUserWhoCanCreatePosts(permissions, uid);
    await FBDatabase.removeUserWhoCanCreateEvents(permissions, uid);
    await FBDatabase.removeUserWhoCanAddFiles(permissions, uid);
  }

  static Future<GroupPermissionsModel> groupPermissions({required String groupID}) async {
    final groupPermissionsID = await FBDatabase.getGroupPermissionsID(groupID);
    return await FBDatabase.getGroupPermissions(groupPermissionsID!);
  }

  static Future<bool> canManageEvent({required String eventID, String? uid}) async {
    final user = await FBDatabase.getUserData(uid??FBAuth().getUserID()!);
    final event = await FBDatabase.getEvent(eventID);
    if(user.userRole == UserRole.administrator || user.userRole == UserRole.manager || user.userRole == UserRole.teacher) {
      return true;
    }
    else if(event.creatorID == (uid ?? FBAuth().getUserID()!)) {
      return true;
    }
    else if(event.groupID != null){
      final groupPermissionsID = await FBDatabase.getGroupPermissionsID(event.groupID!);
      final permissions = await FBDatabase.getGroupPermissions(groupPermissionsID!);
      return permissions.canCreateEvents.contains(uid ?? FBAuth().getUserID()!);
    }
    else {
      return false;
    }
  }

  static Future<bool> showGameUpdateBuilder({required String groupID, String? uid}) async {
    final permissions = await groupPermissions(groupID: groupID);
    return permissions.canPostGameUpdates.contains(uid ?? FBAuth().getUserID()!);
  }

  static Future<bool> showGameScoreOption({required String groupID, String? uid}) async {
    final permissions = await groupPermissions(groupID: groupID);
    return permissions.canScoreGames.contains(uid ?? FBAuth().getUserID()!);
  }

  static bool showGroupActionButtons({required GroupPermissionsModel groupPermissionsModel, String? uid}) {
    if(groupPermissionsModel.canCreatePosts.contains(uid ?? FBAuth().getUserID()!)
        || groupPermissionsModel.canCreateEvents.contains(uid ?? FBAuth().getUserID()!)
        || groupPermissionsModel.canAddFiles.contains(uid ?? FBAuth().getUserID()!)) {
      return true;
    }
    return false;
  }

  static bool canAccessPrivateGroup(GroupModel groupModel, String? uid) {
    if(groupModel.creatorID == uid
        || groupModel.ownerIDs.contains(uid)
        || groupModel.memberIDs.contains(uid)) {
      return true;
    }
    return false;
  }

  static bool canManageAlerts(TenantModel tenantModel, SEAUser user) {
    return tenantModel.userRolesThatCanManageAlerts.contains(user.userRole);
  }

}