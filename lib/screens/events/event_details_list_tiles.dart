import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/EventModel.dart';
import '../../services/configuration.dart';
import '../../services/helpers.dart';
import '../../zap_widgets/ZAP_list_tile.dart';

class EventDetailsListTiles extends StatelessWidget {
  final EventModel eventModel;
  final AppConfiguration prefs;
  final PageController? controller;
  const EventDetailsListTiles({Key? key, required this.eventModel, required this.prefs, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eventDateTimeTile(eventModel, prefs),
        const SizedBox(height: 15),
        _eventLocationTile(context, eventModel, prefs),
        const SizedBox(height: 15),
        _eventPrivacyTile(context, eventModel, prefs),
      ],
    );
  }


  Widget _eventDateTimeTile(EventModel eventModel, AppConfiguration prefs) {
    return ZAPListTile(
      leading: _eventDetailIcon(Icons.event, prefs),
      title: Text(
        DateFormat('yMMMMEEEEd').format(DateTime.parse(eventModel.dateTimeString)),
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      titleSubtitleGap: 3,
      horizontalTitleGap: 10,
      subtitle: Text(
        DateFormat('jm').format(DateTime.parse(eventModel.dateTimeString)),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _eventLocationTile(BuildContext context, EventModel eventModel, AppConfiguration prefs) {
    bool isOnline = eventModel.location.isOnline;
    if(isOnline) {
      return ZAPListTile(
        leading: _eventDetailIcon(Icons.language, prefs),
        title: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            eventModel.location.name!,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        horizontalTitleGap: 10,
        subtitle: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            eventModel.location.url!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    else {
      return ZAPListTile(
        leading: _eventDetailIcon(Icons.location_on_outlined, prefs),
        title: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            eventModel.location.name ?? 'Unnamed Location',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        horizontalTitleGap: 10,
        titleSubtitleGap: 3,
        subtitle: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            eventModel.location.formattedAddress!,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
  }

  Widget _eventPrivacyTile(BuildContext context, EventModel eventModel, AppConfiguration prefs) {
    String? titleText;
    String? subtitleText;

    if(eventModel.privacyLevel.isVisibleToPublic!) {
      titleText = 'Public';
      subtitleText = 'Anyone can view this event';
    }
    else if(eventModel.privacyLevel.isVisibleToFollowers!) {
      titleText = 'Restricted';
      subtitleText = 'Only followers and members can view this event';
    }
    else if(eventModel.privacyLevel.isVisibleToMembers!) {
      titleText = 'Private';
      subtitleText = 'Only members can view this event';
    }

    return ZAPListTile(
      leading: _eventDetailIcon(eventModel.privacyLevel.isVisibleToPublic! ? Icons.lock_open : Icons.lock_outline, prefs),
      title: Text(
        titleText!,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      titleSubtitleGap: 3,
      horizontalTitleGap: 10,
      subtitle: SizedBox(
        width: getViewportWidth(context) * 0.75,
        child: Text(
          subtitleText!,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _eventDetailIcon(IconData icon, AppConfiguration prefs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      height: 55,
      width: 55,
      child: Icon(
        icon,
        size: 26,
        color: prefs.getPrimaryColor(),
      ),
    );
  }

}