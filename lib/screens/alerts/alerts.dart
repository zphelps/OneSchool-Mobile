import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/AlertModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/zap_widgets/zap_button.dart';
import 'package:tuple/tuple.dart';

class Alerts extends ConsumerStatefulWidget {
  final SEAUser user;
  final TenantModel tenantModel;
  const Alerts({Key? key, required this.user, required this.tenantModel}) : super(key: key);

  @override
  ConsumerState<Alerts> createState() => _AlertsState();
}

class _AlertsState extends ConsumerState<Alerts> {

  final controller = PageController(viewportFraction: 0.95);

  int index = 0;

  List<AlertModel>? alerts;

  getPinnedAlerts() async {
    final result = await FBDatabase.getPinnedAlerts(widget.user);
    setState(() {
      alerts = result;
    });
  }

  @override
  void initState() {
    super.initState();
    getPinnedAlerts();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(alertsStreamProvider(Tuple2(widget.user, true)), (previous, next) {
      getPinnedAlerts();
    });
    return alerts == null || alerts!.isEmpty ? const SizedBox() : AnimatedSize(
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: PageView(
              allowImplicitScrolling: true,
              controller: controller,
              scrollDirection: Axis.horizontal,
              children: alerts!.map((e) {
                return _alertCard(e);
              }).toList(),
              onPageChanged: (page) {
                setState(() {
                  index = page;
                });
              },
            ),
          ),
          CarouselIndicator(
            activeColor: Colors.grey.shade400,
            color: Colors.grey.shade200,
            count: alerts!.length,
            index: index,
          ),
        ],
      ),
    );
  }

  Widget _alertCard(AlertModel alert) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 6, 6),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50, //0.35
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, 0),
            )
          ]
      ),
      child: ListTile(
        onTap: () {
          RoutingUtil.pushAsync(context, Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: Text(
                'Alert Detail',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "*This alert will automatically be unpinned from users' main feeds in "
                          '${timeAgo(DateTime.parse(alert.postedAt).subtract(alert.pinDuration).toString()).replaceAll('ago', '')}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: getViewportWidth(context),
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          alert.body,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Created ${DateFormat('yMd').format(DateTime.parse(alert.postedAt))}',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if(PermissionsManager.canManageAlerts(widget.tenantModel, widget.user))
                    ZAPButton(
                      onPressed: () async {
                        await FBDatabase.unpinAlert(alert.id);
                        Navigator.of(context).pop();
                      },
                      backgroundColor: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            CupertinoIcons.pin_slash,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unpin Alert',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ));
        },
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.red.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.notification_important,
            color: Colors.red,
            size: 28,
          ),
        ),
        horizontalTitleGap: 12,
        title: Text(
          alert.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15
          ),
        ),
        subtitle: Text(
          alert.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            fontSize: 14
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
