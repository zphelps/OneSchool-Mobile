import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/screens/events/events_bloc.dart';
import 'package:sea/screens/events/events_query.dart';

import '../services/configuration.dart';
import '../services/fb_auth.dart';
import '../services/fb_database.dart';
import '../services/providers.dart';
import '../zap_widgets/zap_button.dart';

class EventAttendanceSegmentedControl extends ConsumerStatefulWidget {
  final String eventID;
  final Color selectedColor;
  const EventAttendanceSegmentedControl({Key? key, required this.eventID, required this.selectedColor}) : super(key: key);

  @override
  ConsumerState<EventAttendanceSegmentedControl> createState() => _EventAttendanceSegmentedControlState();
}

class _EventAttendanceSegmentedControlState extends ConsumerState<EventAttendanceSegmentedControl> {

  bool _goingButtonLoading = false;
  bool _notGoingButtonLoading = false;

  @override
  Widget build(BuildContext context) {
    final uid = FBAuth().getUserID()!;
    final eventAsyncValue = ref.watch(getEventStreamProvider(widget.eventID));

    return eventAsyncValue.when(
      data: (event) {
        bool? isGoing;

        if(event.isGoingIDs!.contains(uid)) {
          isGoing = true;
        }
        else if(event.isNotGoingIDs!.contains(uid)) {
          isGoing = false;
        }
        return Row(
          children: [
            Expanded(
              child: ZAPButton(
                padding: const EdgeInsets.symmetric(vertical: 6),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                border: Border.all(color: isGoing == null || !isGoing ? Colors.grey.shade300 : widget.selectedColor),
                backgroundColor: isGoing == null || !isGoing ? Colors.white : widget.selectedColor,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _goingButtonLoading = true;
                  });
                  if(isGoing != null && isGoing) {
                    await FBDatabase.removeUserFromEventAttendees(event.id, uid);
                  }
                  else {
                    await FBDatabase.addUserToEventAttendees(event.id, uid);
                    await FBDatabase.removeUserFromEventNonAttendees(event.id, uid);
                  }
                  // final user = await FBDatabase.getUserData(uid);
                  // final cb = ref.watch(eventsUserIsGoingToProvider);
                  // if(!cb.hasData!) {
                  //   print('in if');
                  //   await cb.getData(mounted, EventsQuery(user: user, going: true));
                  //   print(cb.data);
                  // }
                  // else {
                  //   ref.watch(eventsUserIsGoingToProvider).onRefresh(mounted, EventsQuery(user: user, going: true));
                  // }
                  setState(() {
                    _goingButtonLoading = false;
                  });
                },
                child: _goingButtonLoading ? const CupertinoActivityIndicator(radius: 7.5) : Text(
                  'Going',
                  style: GoogleFonts.inter(
                      color: isGoing == null || !isGoing ? Colors.grey[500] : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12
                  ),
                ),
              ),
            ),
            Expanded(
              child: ZAPButton(
                padding: const EdgeInsets.symmetric(vertical: 6),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                border: Border.all(color: isGoing == null || isGoing ? Colors.grey.shade300 : widget.selectedColor),
                backgroundColor: isGoing == null || isGoing ? Colors.white : widget.selectedColor,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _notGoingButtonLoading = true;
                  });
                  if(isGoing != null && !isGoing) {
                    await FBDatabase.removeUserFromEventNonAttendees(event.id, uid);
                  }
                  else {
                    await FBDatabase.addUserToEventNonAttendees(event.id, uid);
                    await FBDatabase.removeUserFromEventAttendees(event.id, uid);
                  }
                  setState(() {
                    _notGoingButtonLoading = false;
                  });
                },
                child: _notGoingButtonLoading ? const CupertinoActivityIndicator(radius: 7.5) : Text(
                  'Not Going',
                  style: GoogleFonts.inter(
                      color: isGoing == null || isGoing ? Colors.grey[500] : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }
}
