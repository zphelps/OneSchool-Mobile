import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sea/models/EventModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/group_profile/group_profile.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';
import 'package:table_calendar/table_calendar.dart';

import '../games/game_details.dart';
import 'event_details.dart';


final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year, kNow.month - 5, kNow.day);
final kLastDay = DateTime(kNow.year, kNow.month + 5, kNow.day);

class CalendarView extends ConsumerStatefulWidget {

  const CalendarView({required this.events, required this.prefs, required this.user});

  final List<dynamic> events;
  final SEAUser user;
  final AppConfiguration prefs;

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late final ValueNotifier<List<EventModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    prevPageEvents = _getEventsForDay(DateTime.now());
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    // Implementation example
    List<EventModel> eventsForDay = [];
    for(EventModel event in widget.events) {
      if(day.isSameDate(DateTime.parse(event.dateTimeString))) {
        eventsForDay.add(event);
      }
    }
    return eventsForDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  List<EventModel>? prevPageEvents;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 0),
        TableCalendar<EventModel>(
          formatAnimationDuration: const Duration(milliseconds: 250),
          availableCalendarFormats: const {
            CalendarFormat.month: 'month',
            CalendarFormat.week: 'week',
          },
          headerStyle: HeaderStyle(
            formatButtonTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 13
            ),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: widget.prefs.getPrimaryColor(),
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: widget.prefs.getPrimaryColor(),
            ),
          ),
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          calendarStyle: CalendarStyle(
            todayTextStyle: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            weekendTextStyle: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            defaultTextStyle: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            selectedTextStyle: TextStyle(
              color: _selectedDay!.day == DateTime.now().day ? Colors.white : widget.prefs.getPrimaryColor(),
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selectedDay!.day == DateTime.now().day ? widget.prefs.getPrimaryColor() : Colors.transparent,
              border: Border.all(color: widget.prefs.getPrimaryColor(), width: 2),
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.prefs.getPrimaryColor(),
            ),
            // Use `CalendarStyle` to customize the UI
            markersMaxCount: 3,
            markerSize: 4,
            markerDecoration: BoxDecoration(
                color: widget.prefs.getPrimaryColor(),
                shape: BoxShape.circle
            ),
            markersAnchor: 2.35,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            // print(_focusedDay.toString());
          },
        ),
        const Divider(
          thickness: 1,
          height: 0,
        ),
        Expanded(
          child: ValueListenableBuilder<List<EventModel>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              _selectedEvents.value.sort((a, b) {
                if(a.groupID == null && b.groupID != null) {
                  return a.creatorID.compareTo(b.groupID!);
                }
                else if(a.groupID != null && b.groupID == null) {
                  return a.groupID!.compareTo(b.creatorID);
                }
                else if(a.groupID == null && b.groupID == null) {
                  return a.creatorID.compareTo(b.creatorID);
                }
                return a.groupID!.compareTo(b.groupID!);
              });
              return _selectedEvents.value.isEmpty ?
                Center(
                    child: Text(
                      'No events found.',
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey
                      ),
                    )
                )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: value.length,
                separatorBuilder: (context, index){
                  return const Divider(height: 0, thickness: 0.5,);
                },
                itemBuilder: (context, index) {
                  if((index == 0 && _selectedEvents.value[index].groupID == null) || (index != 0 && _selectedEvents.value[index].groupID == null && _selectedEvents.value[index-1].groupID != null)
                      || (index != 0 && _selectedEvents.value[index].creatorID != _selectedEvents.value[index-1].creatorID)) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserDivider(_selectedEvents.value[index].creatorID),
                        if(_selectedEvents.value[index].gameID != null)
                          _buildCalendarGameListTile(_selectedEvents.value[index]),
                        if(_selectedEvents.value[index].gameID == null)
                          _buildCalendarEventListTile(_selectedEvents.value[index]),
                      ],
                    );
                  }
                  else if((index == 0 && _selectedEvents.value[index].groupID != null) || (index != 0 && _selectedEvents.value[index].groupID != null && _selectedEvents.value[index-1].groupID == null)
                      || (index != 0 && _selectedEvents.value[index].groupID != _selectedEvents.value[index-1].groupID)) {
                    final groupAsyncValue = ref.watch(getGroupStreamProvider(_selectedEvents.value[index].groupID!));
                    return groupAsyncValue.when(
                      data: (group) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGroupDivider(group),
                            if(_selectedEvents.value[index].gameID != null)
                              _buildCalendarGameListTile(_selectedEvents.value[index]),
                            if(_selectedEvents.value[index].gameID == null)
                              _buildCalendarEventListTile(_selectedEvents.value[index]),
                          ],
                        );
                      },
                      loading: () => PlatformCircularProgressIndicator(),
                      error: (_,__) => const Text('Error'),
                    );
                  }
                  else {
                    if(_selectedEvents.value[index].gameID != null) {
                      return _buildCalendarGameListTile(_selectedEvents.value[index]);
                    }
                    else {
                      return _buildCalendarEventListTile(_selectedEvents.value[index]);
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserDivider(String uid) {
    final userAsyncValue = ref.watch(getUserStreamProvider(uid));
    return userAsyncValue.when(
      data: (user) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImageURL),
                      backgroundColor: Colors.transparent,
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black
                      ),
                    )
                  ],
                ),
              ),
              const Divider(height: 0),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }

  Widget _buildGroupDivider(GroupModel groupModel) {
    return GestureDetector(
      onTap: () => RoutingUtil.push(context, GroupProfile(user: widget.user, groupID: groupModel.id)),
      child: Column(
        children: [
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(groupModel.profileImageURL),
                  backgroundColor: Colors.transparent,
                  radius: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  groupModel.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  Widget _buildCalendarGameListTile(EventModel eventModel) {
    final gameAsyncValue = ref.watch(getGameStreamProvider(eventModel.gameID!));
    return gameAsyncValue.when(
      data: (game) {
        final opponentAsyncValue = ref.watch(getOpponentStreamProvider(game.opponentID));
        return InkWell(
          onTap: () => RoutingUtil.pushAsync(context, GameDetails(eventID: eventModel.id, gameID: game.id)),
          child: ZAPListTile(
            contentPadding: const EdgeInsets.fromLTRB(15, 8, 8, 10),
            titleSubtitleGap: 3,
            title: opponentAsyncValue.when(
              data: (opponent) {
                return Text(
                  'Park Tudor vs. ${opponent.name}',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (e,__) => Text(e.toString())
            ),
            subtitle: Text(
              game.isHome ? '@ Home' : 'Away',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey
              ),
            ),
            trailing: Row(
              children: [
                Text(
                  DateFormat.jm().format(DateTime.parse(eventModel.dateTimeString)),
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 22,
                )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (e,__) => Text(e.toString())
    );
  }

  Widget _buildCalendarEventListTile(EventModel eventModel) {
    return InkWell(
      onTap: () => RoutingUtil.push(context, EventDetails(user: widget.user, eventID: eventModel.id, comingFromGroupProfile: false)),
      child: ZAPListTile(
        contentPadding: const EdgeInsets.fromLTRB(15, 8, 8, 10),
        titleSubtitleGap: 3,
        title: Text(
          eventModel.title!,
          style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black
          ),
        ),
        subtitle: SizedBox(
          width: getViewportWidth(context) * 0.715,
          child: Text(
            eventModel.location.formattedAddress ?? 'Online Event',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey
            ),
          ),
        ),
        trailing: Row(
          children: [
            Text(
              DateFormat.jm().format(DateTime.parse(eventModel.dateTimeString)),
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            )
          ],
        ),
      ),
    );
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month
        && day == other.day;
  }
}