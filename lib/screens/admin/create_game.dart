import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sea/enums.dart';
import 'package:sea/models/GameModel.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/models/OpponentModel.dart';
import 'package:sea/models/PrivacyLevel.dart';
import 'package:sea/models/RSVPPermissionsModel.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/admin/create_opponent.dart';
import 'package:sea/screens/location_selector/add_location.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/permissions_manager.dart';
import 'package:sea/widgets/circle_network_image.dart';
import 'package:sea/widgets/select_group_search/select_group_search.dart';
import 'package:sea/widgets/select_opponent_search/select_opponent_search.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:uuid/uuid.dart';

import '../../models/EventModel.dart';
import '../../models/LocationModel.dart';
import '../../services/fb_database.dart';
import '../../services/fb_storage.dart';
import '../../services/providers.dart';
import '../../services/routing_helper.dart';
import '../../widgets/app_bar_circular_action_button.dart';
import '../../zap_widgets/zap_button.dart';
import '../events/event_details_list_tiles.dart';

class CreateGame extends ConsumerStatefulWidget {
  final SEAUser user;
  final AppConfiguration prefs;
  final GroupModel? defaultGroup;
  final String? gameModelIDToEdit;
  const CreateGame({Key? key, required this.user, required this.prefs, this.gameModelIDToEdit, this.defaultGroup}) : super(key: key);

  @override
  ConsumerState<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends ConsumerState<CreateGame> {

  final PageController _controller = PageController(initialPage: 0, keepPage: false);

  OpponentModel? opponentModel;
  GroupModel? groupModel;

  String startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour+1).toString();
  final _gameStartDateTimeController = TextEditingController();

  bool isHome = false;

  AttendanceManagement? _attendanceManagement;

  RSVPPermissions? _rsvpPermissions;

  bool _loading = false;

  LocationModel? _selectedLocationModel;

  final _gameDescriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? gameImage;

  validateLocation() {
    if(_selectedLocationModel != null) {
      return true;
    }
    return false;
  }

  validateGameDetails() {
    if(startDate.isNotEmpty && opponentModel != null && groupModel != null) {
      return true;
    }
    return false;
  }

  validateAttendanceManagement() {
    if(_attendanceManagement != null) {
      return true;
    }
    return false;
  }

  GameModel? gameModelToEdit;
  EventModel? eventModelToEdit;


  setupForEventEditing() async {
    gameModelToEdit = await FBDatabase.getGame(widget.gameModelIDToEdit!);
    opponentModel = await FBDatabase.getOpponent(gameModelToEdit!.groupID);
    eventModelToEdit = await FBDatabase.getEvent(gameModelToEdit!.eventID);
    _gameDescriptionController.text = eventModelToEdit!.description ?? '';
    if(eventModelToEdit!.rsvpPermissions.publicCanRSVP!) {
      _rsvpPermissions = RSVPPermissions.public;
      _attendanceManagement = AttendanceManagement.collectRSVP;
    }
    else if(eventModelToEdit!.rsvpPermissions.followersCanRSVP!) {
      _rsvpPermissions = RSVPPermissions.followersAndMembers;
      _attendanceManagement = AttendanceManagement.collectRSVP;
    }
    else if(eventModelToEdit!.rsvpPermissions.membersCanRSVP!) {
      _rsvpPermissions = RSVPPermissions.membersOnly;
      _attendanceManagement = AttendanceManagement.collectRSVP;
    }
    else {
      _attendanceManagement = AttendanceManagement.none;
    }

    _selectedLocationModel = gameModelToEdit!.location;

    final tempStartDateTime = DateTime.parse(gameModelToEdit!.dateTimeString);
    _gameStartDateTimeController.text = '${DateFormat('MMMMEEEEd').format(tempStartDateTime)} at ${DateFormat('jm').format(tempStartDateTime)}';
    setState(() {});

  }

  @override
  void initState() {
    super.initState();
    if(widget.defaultGroup != null) {
      groupModel = widget.defaultGroup;
    }
    if(widget.gameModelIDToEdit != null) {
      setupForEventEditing();
    }
    else {
      final tempStartDateTime = DateTime.parse(startDate);
      _gameStartDateTimeController.text = '${DateFormat('MMMMEEEEd').format(tempStartDateTime)} at ${DateFormat('jm').format(tempStartDateTime)}';
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          splashRadius: 25,
          onPressed: () {
            if(_controller.page == 0) {
              Navigator.of(context).pop();
            }
            else {
              _controller.animateToPage(_controller.page!.toInt()-1, duration: const Duration(milliseconds: 200), curve: Curves.linear);
            }
            setState(() {});
          },
          icon: const Icon(Icons.chevron_left, size: 36),
        ),
      ),
      body: Stack(
        children: [
          widget.gameModelIDToEdit != null && gameModelToEdit == null ? const Center(child: CupertinoActivityIndicator()) : SafeArea(
            child: PageView(controller: _controller, physics: const NeverScrollableScrollPhysics(), children: [
              _gameDetails(),
              if(validateGameDetails())
                _locationSelection(),
              _eventDescriptionPage(),
              _eventAttendanceManagementPage(),
              if(validateLocation())
                _reviewEvent(),
            ]),
          ),
        ],
      )
    );
  }

  Widget _gameDetails() {
    final focusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Details',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: TextFormField(
              focusNode: focusNode,
              onTap: () {
                showPlatformDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2021, 8),
                  lastDate: DateTime(2023, 8),
                  cupertino: (_,__) => CupertinoDatePickerData(
                    mode: CupertinoDatePickerMode.dateAndTime,
                    onDateTimeChanged: (datetime) {
                      startDate = datetime.toString();
                      _gameStartDateTimeController.text = '${DateFormat('MMMMEEEEd').format(datetime)} at ${DateFormat('jm').format(datetime)}';
                    },
                  ),
                );
              },
              controller: _gameStartDateTimeController,
              readOnly: true,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusColor: Colors.grey.shade300,
                labelText: 'Date and Time',
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              horizontalTitleGap: 10,
              onTap: () async {
                final result = await RoutingUtil.pushAsync(context, Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(color: Colors.black),
                    title: Text(
                      'Select Group',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  body: SelectGroupSearch(
                    filter: (group) async {
                      final permissions = await PermissionsManager.groupPermissions(groupID: group.id);
                      if(permissions.canCreateEvents.contains(FBAuth().getUserID()!) && group.isTeam) {
                        return true;
                      }
                      return false;
                    },
                    separator: const Divider(),
                    searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    listTile: (group, notifier) => ListTile(
                      onTap: () => Navigator.of(context).pop(group),
                      leading: CircleNetworkImage(imageURL: group.profileImageURL, fit: BoxFit.cover),
                      title: Text(
                        group.name,
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 17
                        ),
                      ),
                      trailing: Icon(
                        Icons.radio_button_off_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ));
                if(result != null) {
                  setState(() {
                    groupModel = result;
                  });
                }
              },
              leading: groupModel == null ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.group,
                  color: Colors.black,
                ),
              ) : CircleNetworkImage(imageURL: groupModel!.profileImageURL, fit: BoxFit.cover),
              title: Text(
                groupModel?.name ?? 'Select Group',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                ),
              ),
              trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400]
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              horizontalTitleGap: 10,
              onTap: () async {
                final result = await RoutingUtil.pushAsync(context, Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    iconTheme: const IconThemeData(color: Colors.black),
                    title: Text(
                      'Select Opponent',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: AppBarCircularActionButton(
                          onTap: () async {
                            final opponent = await RoutingUtil.pushAsync(context, CreateOpponent(prefs: widget.prefs));
                            if(opponent != null) {
                              Navigator.of(context).pop(opponent);
                            }
                          },
                          radius: 18,
                          backgroundColor: Colors.grey[100],
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: SelectOpponentSearch(
                    separator: const Divider(),
                    searchBarPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    listTile: (opponent, notifier) => ListTile(
                      onTap: () => Navigator.of(context).pop(opponent),
                      leading: CircleNetworkImage(imageURL: opponent.logoURL, fit: BoxFit.cover),
                      title: Text(
                        opponent.name,
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 17
                        ),
                      ),
                      trailing: Icon(
                        Icons.radio_button_off_outlined,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ));
                if(result != null) {
                  setState(() {
                    opponentModel = result;
                  });
                }
              },
              leading: opponentModel == null ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.group,
                  color: Colors.black,
                ),
              ) : CircleNetworkImage(imageURL: opponentModel!.logoURL, fit: BoxFit.cover),
              title: Text(
                opponentModel?.name ?? 'Select Opponent',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                ),
              ),
              trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400]
              ),
            ),
          ),
          const SizedBox(height: 15),
          if(opponentModel != null)
            TextFormField(
              readOnly: true,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              onTap: () {
                setState(() {
                  isHome = !isHome;
                });
                HapticFeedback.mediumImpact();
              },
              initialValue: 'Home Game?',
              decoration: InputDecoration(
                suffixIcon: Icon(
                  isHome ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                  color: isHome ? widget.prefs.getPrimaryColor() : Colors.grey,
                ),
                // hintText: 'Home Game?',
                contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)
                ),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ZAPButton(
              onPressed: () async {
                focusNode.unfocus();
                if(validateGameDetails()) {
                  _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                }
              },
              backgroundColor: validateGameDetails() ? widget.prefs.getPrimaryColor() : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Next',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //LOCATION SELECTION SCREEN
  Widget _locationSelection() {
    final groupLocationsAsyncValue = ref.watch(groupLocationsStreamProvider(groupModel!.id));
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Location',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 15),
              ZAPButton(
                onPressed: () async {
                  final result = await RoutingUtil.pushAsync(context, AddLocation(groupID: opponentModel!.id, prefs: widget.prefs, creatorID: eventModelToEdit?.creatorID ?? FBAuth().getUserID()!));
                  setState(() {
                    _selectedLocationModel = result;
                  });
                  await Future.delayed(const Duration(milliseconds: 500));
                  if(validateLocation()) {
                    _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                  }
                },
                borderRadius: BorderRadius.circular(6),
                backgroundColor: Colors.grey.shade300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_location_alt_outlined,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Location',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if(_selectedLocationModel != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 35),
                    _selectedLocation(_selectedLocationModel!),
                  ],
                ),
              const Divider(height: 35),
              Text(
                'Saved Locations',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              groupLocationsAsyncValue.when(
                data: (locations) {
                  return _buildLocationsList(locations);
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e,__) => Text(e.toString()),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: SafeArea(
            child: ZAPButton(
              onPressed: () async {
                if(validateLocation()) {
                  _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                }
              },
              backgroundColor: validateLocation() ? widget.prefs.getPrimaryColor() : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Next',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildLocationsList(List<LocationModel> locationModels) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locationModels.length,
      itemBuilder: (context, index) {
        final location = locationModels[index];
        if(_selectedLocationModel != null && location.id == _selectedLocationModel!.id && locationModels.length == 1) {
          return Center(
            child: Text(
              'No more saved locations.',
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }
        else if(_selectedLocationModel != null && location.id == _selectedLocationModel!.id) {
          return const SizedBox();
        }
        return Column(
          children: [
            _locationListTile(location),
            const Divider(height: 20),
          ],
        );
      },
    );
  }

  Widget _locationListTile(LocationModel locationModel) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        setState(() {
          _selectedLocationModel = locationModel;
        });
        if(validateLocation()) {
          _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
        }
      },
        title: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            locationModel.name!,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SizedBox(
            width: getViewportWidth(context) * 0.65,
            child: Text(
              locationModel.formattedAddress ?? locationModel.url!,
              maxLines: 2,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
        trailing: locationModel.mapStaticImageURL == null ?
        Container(
          height: 80,
          width: 80,
          color: Colors.grey[200],
          child: const Icon(
            Icons.language,
            color: Colors.grey,
          ),
        )
            : CachedNetworkImage(
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          imageUrl: locationModel.mapStaticImageURL!,
        )
    );
  }

  Widget _selectedLocation(LocationModel locationModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: widget.prefs.getPrimaryColor(), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: SizedBox(
          width: getViewportWidth(context) * 0.75,
          child: Text(
            locationModel.name!,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: SizedBox(
            width: getViewportWidth(context) * 0.65,
            child: Text(
              locationModel.formattedAddress ?? locationModel.url!,
              maxLines: 2,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
        trailing: locationModel.mapStaticImageURL == null ?
        Container(
          height: 80,
          width: 80,
          color: Colors.grey[200],
          child: const Icon(
            Icons.language,
            color: Colors.grey,
          ),
        )
            : CachedNetworkImage(
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          imageUrl: locationModel.mapStaticImageURL!,
        )
      ),
    );
  }

  Widget _eventDescriptionPage() {
    final focusNode = FocusNode();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Description',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Add some information about your event to get people interested.',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  maxLines: null,
                  minLines: 10,
                  controller: _gameDescriptionController,
                  onChanged: (value) {
                    setState(() {
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    hintText: 'Describe your event...',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300)
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: SafeArea(
            child: ZAPButton(
              onPressed: () {
                focusNode.unfocus();
                _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
              },
              backgroundColor: widget.prefs.getPrimaryColor(),
              borderRadius: BorderRadius.circular(8),
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Next',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _eventAttendanceManagementPage() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Attendance',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'How would you like to keep track of attendance for your event?',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.075),
                        spreadRadius: 0,
                        blurRadius: 15
                      )
                    ]
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        CupertinoIcons.tickets_fill,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      'Sell Tickets',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.radio_button_off_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.topCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.075),
                              spreadRadius: 0,
                              blurRadius: 15
                          )
                        ]
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            setState(() {
                              _attendanceManagement = AttendanceManagement.collectRSVP;
                              _rsvpPermissions = RSVPPermissions.public;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(
                              CupertinoIcons.mail_solid,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(
                            'Collect RSVPs',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: Icon(
                            _attendanceManagement == AttendanceManagement.collectRSVP ? Icons.arrow_drop_down_rounded : Icons.radio_button_off_outlined,
                            color: Colors.grey,
                            size: _attendanceManagement == AttendanceManagement.collectRSVP ? 32 : 24,
                          ),
                        ),
                        if(_attendanceManagement == AttendanceManagement.collectRSVP)
                          _whoCanRSVPSelector(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.075),
                            spreadRadius: 0,
                            blurRadius: 15
                        )
                      ]
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _attendanceManagement = AttendanceManagement.none;
                      });
                      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                    },
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                    title: Text(
                      "Don't Manage Attendance",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    trailing: Icon(
                      _attendanceManagement == AttendanceManagement.none ? Icons.radio_button_checked : Icons.radio_button_off_outlined,
                      color: _attendanceManagement == AttendanceManagement.none ? widget.prefs.getPrimaryColor() : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: SafeArea(
            child: ZAPButton(
              onPressed: () {
                if(validateAttendanceManagement()) {
                  _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);
                }
              },
              backgroundColor: validateAttendanceManagement() ? widget.prefs.getPrimaryColor() : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Next',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _whoCanRSVPSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Divider(height: 0),
          const SizedBox(height: 20),
          ZAPListTile(
              onTap: () {
                setState(() {
                  _rsvpPermissions = RSVPPermissions.public;
                });
              },
              leading: const Icon(
                Icons.public,
                color: Colors.black,
              ),
              title: Text(
                'Public',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              crossAxisAlignment: CrossAxisAlignment.center,
              horizontalTitleGap: 10,
              subtitle: SizedBox(
                width: getViewportWidth(context) * 0.65,
                child: Text(
                  "Anyone can RSVP to this event.",
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              trailing: _rsvpPermissions == RSVPPermissions.public ?
              Icon(Icons.radio_button_checked, color: widget.prefs.getPrimaryColor()) :
              const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
          ),
          const SizedBox(height: 25),
          ZAPListTile(
              onTap: () {
                setState(() {
                  _rsvpPermissions = RSVPPermissions.followersAndMembers;
                });
              },
              leading: const Icon(
                Icons.language,
                color: Colors.black,
              ),
              title: Text(
                'Followers and Members',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              crossAxisAlignment: CrossAxisAlignment.center,
              horizontalTitleGap: 10,
              subtitle: SizedBox(
                width: getViewportWidth(context) * 0.65,
                child: Text(
                  "Both followers and members of this group can RSVP.",
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              trailing: _rsvpPermissions == RSVPPermissions.followersAndMembers ?
              Icon(Icons.radio_button_checked, color: widget.prefs.getPrimaryColor()) :
              const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
          ),
          const SizedBox(height: 25),
          ZAPListTile(
              onTap: () {
                setState(() {
                  _rsvpPermissions = RSVPPermissions.membersOnly;
                });
              },
              leading: const Icon(
                Icons.lock,
                color: Colors.black,
              ),
              title: Text(
                'Members Only',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              crossAxisAlignment: CrossAxisAlignment.center,
              horizontalTitleGap: 10,
              subtitle: SizedBox(
                width: getViewportWidth(context) * 0.65,
                child: Text(
                  "Only members of this group can RSVP.",
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              trailing: _rsvpPermissions == RSVPPermissions.membersOnly ?
              Icon(Icons.radio_button_checked, color: widget.prefs.getPrimaryColor()) :
              const Icon(Icons.radio_button_off_outlined, color: Colors.grey)
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  Widget _reviewAttendanceSettingsSection() {

    String? text;

    if(_rsvpPermissions == RSVPPermissions.public) {
      text = 'Anyone can RSVP for this event.';
    }
    else if(_rsvpPermissions == RSVPPermissions.followersAndMembers) {
      text = 'Both followers and members of this group can RSVP for this event.';
    }
    else {
      text = 'Only members of this group can RSVP for this event.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Attendance',
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _reviewEvent() {
    final gameID = const Uuid().v4();
    final event = EventModel(
      id: gameModelToEdit?.id ?? const Uuid().v4(),
      creatorID: FBAuth().getUserID()!,
      title: null,
      description: _gameDescriptionController.text,
      imageURL: eventModelToEdit?.imageURL,
      dateTimeString: startDate,
      groupID: groupModel!.id,
      userSegmentIDs: null,
      rsvpPermissions: RSVPPermissionsModel(
        membersCanRSVP: _attendanceManagement != AttendanceManagement.none ? true : false,
        followersCanRSVP: _attendanceManagement != AttendanceManagement.none && (_rsvpPermissions == RSVPPermissions.followersAndMembers || _rsvpPermissions == RSVPPermissions.public) ? true : false,
        publicCanRSVP: _attendanceManagement != AttendanceManagement.none && _rsvpPermissions == RSVPPermissions.public ? true : false,
      ),
      privacyLevel: const PrivacyLevel(
        isVisibleToMembers: true,
        isVisibleToFollowers: true,
        isVisibleToPublic: true,
      ),
      location: _selectedLocationModel!,
      eventInfoURL: null,
      isGoingIDs: null,
      isNotGoingIDs: null,
      gameID: gameModelToEdit == null ? gameID : gameModelToEdit!.id,
    );
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 5),
              Text(
                '${widget.prefs.getSchoolName()} vs. ${opponentModel?.name}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  XFile? image =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      gameImage = File(image.path);
                    });
                  }
                },
                child: Container(
                    height: getViewportHeight(context) * 0.225,
                    width: getViewportWidth(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey[100],
                    ),
                    child: Center(
                      child: gameImage != null ?
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            gameImage!,
                            fit: BoxFit.cover, width: getViewportWidth(context),
                            height: getViewportHeight(context) * 0.225,
                          )
                      )
                          : eventModelToEdit != null && eventModelToEdit?.imageURL != null ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: eventModelToEdit!.imageURL!,
                            fit: BoxFit.cover, width: getViewportWidth(context),
                            height: getViewportHeight(context) * 0.225,
                          )
                      ) : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[300],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Add Event Photo',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
              ),
              const Divider(height: 25),
              EventDetailsListTiles(eventModel: event, prefs: widget.prefs, controller: widget.gameModelIDToEdit != null ? _controller : null),
              const Divider(height: 25),
              if(_attendanceManagement == AttendanceManagement.collectRSVP)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reviewAttendanceSettingsSection(),
                    const Divider(height: 25),
                  ],
                ),
              if(event.description != null && event.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventAboutSection(event.description!),
                    const Divider(height: 25),
                  ],
                ),
            ],
          ),
        ),
        if(_loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CupertinoActivityIndicator(color: Colors.white, radius: 16),
              ),
            ),
          ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: SafeArea(
            child: ZAPButton(
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                if(gameImage != null) {
                  final url = await FBStorage.uploadEventPhotoToFireStorage(gameImage!, context);
                  final eventWithImage = EventModel(
                    id: event.id,
                    creatorID: event.creatorID,
                    title: event.title,
                    gameID: event.gameID,
                    imageURL: url.url,
                    rsvpPermissions: event.rsvpPermissions,
                    privacyLevel: event.privacyLevel,
                    isGoingIDs: null,
                    isNotGoingIDs: null,
                    description: event.description,
                    location: event.location,
                    eventInfoURL: null,
                    dateTimeString: event.dateTimeString,
                    groupID: groupModel!.id,
                    userSegmentIDs: null,
                  );
                  if(widget.gameModelIDToEdit != null) {
                    await FBDatabase.updateEvent(eventWithImage);
                  }
                  else {
                    await FBDatabase.createEvent(eventWithImage);
                  }
                }
                else {
                  if(widget.gameModelIDToEdit != null) {
                    await FBDatabase.updateEvent(event);
                  }
                  else {
                    await FBDatabase.createEvent(event);
                  }
                }
                final groupPermissions = await PermissionsManager.groupPermissions(groupID: event.groupID!);
                final game = GameModel(
                  id: gameModelToEdit?.id ?? gameID,
                  season: getCurrentSeason(gameDataTimeString: startDate),
                  dateTimeString: startDate,
                  groupID: event.groupID!,
                  location: _selectedLocationModel!,
                  eventID: event.id,
                  usersWhoCanUpdateAndScoreGame: groupPermissions.canScoreGames,
                  opponentID: opponentModel!.id,
                  isHome: isHome,
                  isMarkedDone: false,
                  homeTeamScore: null,
                  opposingTeamScore: null,
                  livestreamID: null,
                );
                await FBDatabase.createGame(game);
                setState(() {
                  _loading = false;
                });
                Navigator.of(context).pop(game);
              },
              backgroundColor: widget.prefs.getPrimaryColor(),
              borderRadius: BorderRadius.circular(8),
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                widget.gameModelIDToEdit != null ? 'Update Game' : 'Create Game',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventAboutSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Event',
          style: GoogleFonts.inter(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

}

enum EventPrivacy { public, membersAndFollowers, members }
enum AttendanceManagement {sellTickets, collectRSVP, none}
enum RSVPPermissions {public, followersAndMembers, membersOnly}
