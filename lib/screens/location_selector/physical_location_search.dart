import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:sea/constants.dart';
import 'package:sea/screens/location_selector/configure_physical_location.dart';
import 'package:sea/services/routing_helper.dart';

import '../../services/configuration.dart';
import '../../services/helpers.dart';
import '../../zap_widgets/ZAP_list_tile.dart';

class PhysicalLocationSearch extends StatefulWidget {
  final AppConfiguration prefs;
  final String? groupID;
  final String creatorID;
  const PhysicalLocationSearch({Key? key, required this.prefs, this.groupID, required this.creatorID}) : super(key: key);

  @override
  State<PhysicalLocationSearch> createState() => _PhysicalLocationSearchState();
}

class _PhysicalLocationSearchState extends State<PhysicalLocationSearch> {

  var placesSearch = PlacesSearch(
    apiKey: MAP_BOX_KEY,
    country: 'US',
    limit: 10,
  );

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Add Location',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 17
          ),
        ),
      ),
      body: TypeAheadField(
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _focusNode,
          autocorrect: false,
          decoration: AppConfiguration.inputDecoration1.copyWith(
            hintText: 'Enter address or location name...',
            isDense: true
          ),
          autofocus: true,
        ),
        noItemsFoundBuilder: (context) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Text(
              'Address Not Found.',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
        suggestionsBoxVerticalOffset: 10,
        suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          color: Colors.white,
          elevation: 0
        ),
        suggestionsCallback: (query) async {
          final result = await placesSearch.getPlaces(query);
          return result ?? <MapBoxPlace>[];
        },
        itemBuilder: (context, MapBoxPlace item) {
          return ZAPListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: const Icon(
                Icons.location_on,
                color: Colors.black,
              ),
            ),
            horizontalTitleGap: 10,
            title: SizedBox(
              width: getViewportWidth(context) *0.75,
              child: Text(
                item.placeName ?? 'Not Found',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          );
        },
        onSuggestionSelected: (MapBoxPlace suggestion) async {
          final location = await RoutingUtil.pushAsync(context, ConfigurePhysicalLocation(place: suggestion, prefs: widget.prefs, groupID: widget.groupID, creatorID: widget.creatorID));
          Navigator.of(context).pop(location);
        },
      ),
    );
  }
}
