import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sea/models/NotificationModel.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';

import '../../services/fb_database.dart';

class Notifications extends StatefulWidget {
  final String? notificationID;
  const Notifications({Key? key, this.notificationID}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 17
          ),
        ),
      ),
      body: PaginateFirestore(
        itemsPerPage: 25,
        itemBuilder: (context, documentSnapshots, index) {
          final notification = NotificationModel.fromMap(documentSnapshots[index].data() as Map<String, dynamic>?);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 0),
              Container(
                color: widget.notificationID != null && widget.notificationID == notification.id ? Colors.blue.withOpacity(0.1) : Colors.white,
                padding: const EdgeInsets.all(16),
                child: ZAPListTile(
                  title: Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  titleSubtitleGap: 3,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.body,
                        maxLines: 3,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeAgo(notification.createdAt),
                        maxLines: 3,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 0),
            ],
          );
        },
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance.collection('tenants')
            .doc(FBDatabase.tenantID).collection('users')
            .doc(FBAuth().getUserID()!).collection('notifications')
            .orderBy('createdAt', descending: true),
        //Change types accordingly
        itemBuilderType: PaginateBuilderType.listView,
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
