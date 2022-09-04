
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/configuration.dart';

import '../../../services/fb_database.dart';

class MessagingPreferences extends StatefulWidget {
  final TenantModel tenantModel;
  final AppConfiguration prefs;
  const MessagingPreferences({Key? key, required this.tenantModel, required this.prefs}) : super(key: key);

  @override
  State<MessagingPreferences> createState() => _MessagingPreferencesState();
}

class _MessagingPreferencesState extends State<MessagingPreferences> {

  late bool enableDirectMessaging;
  late bool enableGroupMessaging;
  late bool allowMessagingBetweenAdministratorsManagersTeachersStaff;
  late bool allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff;
  late bool allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff;
  late bool allowMessagingBetweenStudentLeadersAndStudents;
  late bool allowMessagingBetweenStudentLeaders;
  late bool allowMessagingBetweenStudent;

  @override
  void initState() {
    super.initState();
    enableDirectMessaging = widget.tenantModel.enableDirectMessaging;
    enableGroupMessaging = widget.tenantModel.enableGroupMessaging;
    allowMessagingBetweenAdministratorsManagersTeachersStaff = widget.tenantModel.allowMessagingBetweenAdministratorsManagersTeachersStaff;
    allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff = widget.tenantModel.allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff;
    allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff = widget.tenantModel.allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff;
    allowMessagingBetweenStudentLeadersAndStudents = widget.tenantModel.allowMessagingBetweenStudentLeadersAndStudents;
    allowMessagingBetweenStudentLeaders = widget.tenantModel.allowMessagingBetweenStudentLeaders;
    allowMessagingBetweenStudent = widget.tenantModel.allowMessagingBetweenStudent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Moderation Preferences',
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
                      'Direct Messaging',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    'Enable Direct Messaging',
                    enableDirectMessaging,
                    (value) async {
                      setState(() {
                        enableDirectMessaging = value;
                      });
                      if(!enableDirectMessaging) {
                        await FBDatabase.updateTenantConfiguration('enableDirectMessaging', value);
                        setState(() {
                          allowMessagingBetweenAdministratorsManagersTeachersStaff = false;
                          allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff = false;
                          allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff = false;
                          allowMessagingBetweenStudentLeadersAndStudents = false;
                          allowMessagingBetweenStudentLeaders = false;
                          allowMessagingBetweenStudent = false;
                        });
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenAdministratorsManagersTeachersStaff', false);
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff', false);
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff', false);
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentLeadersAndStudents', false);
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentLeaders', false);
                        await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudent', false);
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('enableDirectMessaging', value);
                      }
                    },
                  ),
                  if(enableDirectMessaging)
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        children: [
                          _tile(
                            'Allow messaging between Administrators/Managers/Teachers/Staff',
                            allowMessagingBetweenAdministratorsManagersTeachersStaff,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenAdministratorsManagersTeachersStaff = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenAdministratorsManagersTeachersStaff', value);
                            },
                          ),
                          _tile(
                            'Allow messaging between Students and Administrators/Managers/Teachers/Staff',
                            allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentsAndAdministratorsManagersTeachersStaff', value);
                            },
                          ),
                          _tile(
                            'Allow messaging between Parents and Administrators/Managers/Teachers/Staff',
                            allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenParentsAndAdministratorsManagersTeachersStaff', value);
                            },
                          ),
                          _tile(
                            'Allow messaging between Student Leaders and Students',
                            allowMessagingBetweenStudentLeadersAndStudents,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenStudentLeadersAndStudents = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentLeadersAndStudents', value);
                            },
                          ),
                          _tile(
                            'Allow messaging between Student Leaders',
                            allowMessagingBetweenStudentLeaders,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenStudentLeaders = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudentLeaders', value);
                            },
                          ),
                          _tile(
                            'Allow messaging between Students',
                            allowMessagingBetweenStudent,
                                (value) async {
                              setState(() {
                                allowMessagingBetweenStudent = value;
                              });
                              await FBDatabase.updateTenantConfiguration('allowMessagingBetweenStudent', value);
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
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
                      'Group Messaging',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    'Allow Group Conversations',
                    enableGroupMessaging,
                        (value) async {
                      setState(() {
                        enableGroupMessaging = value;
                      });
                      await FBDatabase.updateTenantConfiguration('enableGroupMessaging', value);
                    },
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

  Widget _tile(String label, bool selection, void Function(bool) onChanged) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16
        ),
      ),
      trailing: CupertinoSwitch(
        activeColor: widget.prefs.getPrimaryColor(),
        value: selection,
        onChanged: onChanged,
      ),
    );
  }
}
