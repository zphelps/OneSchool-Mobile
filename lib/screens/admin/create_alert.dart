import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/UserSegment.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/email_notifications.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/push_notifications.dart';
import 'package:sea/services/sms_notifications.dart';
import 'package:uuid/uuid.dart';

import '../../models/AlertModel.dart';
import '../../services/helpers.dart';
import '../../services/routing_helper.dart';
import '../../zap_widgets/ZAP_list_tile.dart';
import '../user_segments/select_user_segment.dart';

class CreateAlert extends StatefulWidget {
  final AppConfiguration prefs;
  const CreateAlert({Key? key, required this.prefs}) : super(key: key);

  @override
  State<CreateAlert> createState() => _CreateAlertState();
}

class _CreateAlertState extends State<CreateAlert> {

  final titleTextController = TextEditingController();
  final bodyTextController = TextEditingController();

  bool pushNotification = true;
  bool smsNotification = true;
  bool emailNotification = true;

  bool loading = false;

  List<UserSegment>? audience;

  validate() {
    if(audience != null && titleTextController.text.isNotEmpty && bodyTextController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Create Alert',
            style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17
            ),
          ),
          actions: [
            loading ? const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CupertinoActivityIndicator(),
            ) : PlatformTextButton(
              onPressed: () async {
                if(validate()) {
                  setState(() {
                    loading = true;
                  });
                  final alertModel = AlertModel(
                    id: const Uuid().v4(),
                    creatorID: FBAuth().getUserID()!,
                    title: titleTextController.text,
                    body: bodyTextController.text,
                    postedAt: DateTime.now().toString(),
                    pinDuration: const Duration(days: 1),
                    pinned: true,
                    userSegmentIDs: audience!.map((e) => e.id).toList(),
                  );
                  await FBDatabase.createAlert(alertModel);
                  if(emailNotification) {
                    await EmailNotifications.sendAlertEmail(
                      userSegmentIDs: audience!.map((e) => e.id).toList(),
                      schoolName: widget.prefs.getSchoolName(),
                      date: DateFormat('yMMMMEEEEd').format(DateTime.parse(alertModel.postedAt)),
                      title: alertModel.title,
                      body: alertModel.body,
                    );
                  }
                  if(smsNotification) {
                    await SMSNotifications.sendAlertSMS(
                      userSegmentIDs: audience!.map((e) => e.id).toList(),
                      body: '${alertModel.title}\n${alertModel.body}',
                    );
                  }
                  if(pushNotification) {
                    await PushNotifications.sendAlertNotification(alertModel, audience!);
                  }
                  setState(() {
                    loading = false;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Send',
                style: GoogleFonts.inter(
                    color: validate() ? widget.prefs.getPrimaryColor() : Colors.grey[300],
                    fontSize: 17,
                    fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        onTap: () async {
                          final result = await RoutingUtil.pushAsync(context, SelectUserSegment(prefs: widget.prefs, selectedSegments: audience));
                          if(result != null) {
                            setState(() {
                              audience = result;
                            });
                          }
                        },
                        leading: audience != null ? null : CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.groups,
                            color: Colors.black,
                          ),
                        ),
                        title: audience != null ? Wrap(
                          runSpacing: 6,
                          children: audience!.map((e) => Chip(
                            elevation: 0,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.grey.shade200,
                            onDeleted: () {
                              setState(() {
                                audience!.remove(e);
                              });
                            },
                            label: Text(
                              e.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),).toList(),
                        ) : Text(
                          'Select User Segments',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      color: Colors.white,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        controller: titleTextController,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            labelText: 'Title'
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      color: Colors.white,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        maxLines: null,
                        controller: bodyTextController,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            labelText: 'Body'
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: ZAPListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.black,
                          ),
                        ),
                        horizontalTitleGap: 15,
                        title: Text(
                          'Push Notification',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.625,
                          child: Text(
                            'Send all recipients of this alert a push notification',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        trailing: CupertinoSwitch(
                            value: pushNotification,
                            activeColor: widget.prefs.getPrimaryColor(),
                            onChanged: (save) {
                              setState(() {
                                pushNotification = save;
                              });
                            }
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: ZAPListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: const Icon(
                            Icons.sms,
                            color: Colors.black,
                          ),
                        ),
                        horizontalTitleGap: 15,
                        title: Text(
                          'SMS Notification',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.625,
                          child: Text(
                            'Send all recipients of this alert an SMS notification',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        trailing: CupertinoSwitch(
                            value: smsNotification,
                            activeColor: widget.prefs.getPrimaryColor(),
                            onChanged: (save) {
                              setState(() {
                                smsNotification = save;
                              });
                            }
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      child: ZAPListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 24,
                          child: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                        ),
                        horizontalTitleGap: 15,
                        title: Text(
                          'Email Notification',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: SizedBox(
                          width: getViewportWidth(context) * 0.625,
                          child: Text(
                            'Send all recipients of this alert a push notification',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        trailing: CupertinoSwitch(
                            value: emailNotification,
                            activeColor: widget.prefs.getPrimaryColor(),
                            onChanged: (save) {
                              setState(() {
                                emailNotification = save;
                              });
                            }
                        ),
                      ),
                    ),
                    const Divider(height: 45),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
