import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/enums.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/configuration.dart';

import '../../../services/fb_database.dart';

class AlertPreferences extends StatefulWidget {
  final AppConfiguration prefs;
  final TenantModel tenantModel;
  const AlertPreferences({Key? key, required this.prefs, required this.tenantModel}) : super(key: key);

  @override
  State<AlertPreferences> createState() => _AlertPreferencesState();
}

class _AlertPreferencesState extends State<AlertPreferences> {

  late bool administrator;
  late bool manager;
  late bool teacher;
  late bool staff;
  late bool studentLeader;
  late bool student;
  late bool parent;
  late bool guest;

  @override
  void initState() {
    super.initState();
    administrator = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.administrator);
    manager = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.manager);
    teacher = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.teacher);
    staff = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.staff);
    studentLeader = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.studentLeader);
    student = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.student);
    parent = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.parent);
    guest = widget.tenantModel.userRolesThatCanManageAlerts.contains(UserRole.guest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Alert Preferences',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Alert Preferences',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Allow the following roles to create and manage school-wide alerts.',
                      style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          fontSize: 15
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    'Administrator',
                    administrator,
                    (value) {},
                    Colors.grey.shade300,
                  ),
                  _tile(
                    'Manager',
                    manager,
                    (value) {},
                    Colors.grey.shade300,
                  ),
                  _tile(
                    'Teacher',
                    teacher,
                        (value) async {
                      setState(() {
                        teacher = value!;
                      });
                      if(teacher) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.teacher.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.teacher.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  _tile(
                    'Staff',
                    staff,
                        (value) async {
                      setState(() {
                        staff = value!;
                      });
                      if(staff) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.staff.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.staff.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  _tile(
                    'Student Leader',
                    studentLeader,
                        (value) async {
                      setState(() {
                        studentLeader = value!;
                      });
                      if(studentLeader) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.studentLeader.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.studentLeader.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  _tile(
                    'Student',
                    student,
                        (value) async {
                      setState(() {
                        student = value!;
                      });
                      if(student) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.student.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.student.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  _tile(
                    'Parent',
                    parent,
                        (value) async {
                      setState(() {
                        parent = value!;
                      });
                      if(parent) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.parent.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.parent.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  _tile(
                    'Guest',
                    guest,
                        (value) async {
                      setState(() {
                        guest = value!;
                      });
                      if(guest) {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayUnion([UserRole.guest.name]));
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('userRolesThatCanManageAlerts', FieldValue.arrayRemove([UserRole.guest.name]));
                      }
                    },
                    widget.prefs.getPrimaryColor(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, bool selection, void Function(bool?) onChanged, Color activeColor) {
    return CheckboxListTile(
      activeColor: activeColor,
      dense: true,
      title: Text(
        label,
        style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16
        ),
      ),
      value: selection,
      onChanged: onChanged,
    );
  }
}
