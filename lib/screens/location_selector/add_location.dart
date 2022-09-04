import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:sea/models/LocationModel.dart';
import 'package:sea/screens/location_selector/configure_online_location.dart';
import 'package:sea/screens/location_selector/physical_location_search.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/zap_widgets/ZAP_list_tile.dart';
import 'package:sea/zap_widgets/zap_button.dart';

class AddLocation extends ConsumerStatefulWidget {
  final String? groupID;
  final String creatorID;
  final AppConfiguration prefs;
  const AddLocation({Key? key, this.groupID, required this.creatorID, required this.prefs}) : super(key: key);

  @override
  ConsumerState<AddLocation> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<AddLocation> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Location Format',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 25),
            _locationTypeCard(
              'Online',
              'Must provide a link for people to access your event.',
              Icons.language,
              () async {
                final location = await RoutingUtil.pushAsync(context, ConfigureOnlineLocation(prefs: widget.prefs, groupID: widget.groupID, creatorID: widget.creatorID));
                print(location);
                Navigator.of(context).pop(location);
              },
            ),
            const SizedBox(height: 12),
            _locationTypeCard(
              'In-Person',
              'Gather a group of people to meet at a specific location.',
              Icons.group,
              () async {
                final location = await RoutingUtil.pushAsync(context, PhysicalLocationSearch(prefs: widget.prefs, groupID: widget.groupID, creatorID: widget.creatorID));
                print(location);
                Navigator.of(context).pop(location);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationTypeCard(String title, String subtitle, IconData iconData, Future Function() onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        onTap: () async => await onTap(),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(
            iconData,
            color: Colors.black,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w400,
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
