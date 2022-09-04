import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@immutable
class LocationModel extends Equatable{
  final String id;
  final String? groupID;
  final String creatorID;
  final bool isOnline;
  final String? name;
  final String? formattedAddress;
  final String? mapStaticImageURL;
  final String? url;
  final String? description;
  final LatLng? latLng;

  const LocationModel({
    required this.id,
    required this.groupID,
    required this.creatorID,
    required this.isOnline,
    required this.name,
    required this.formattedAddress,
    required this.mapStaticImageURL,
    required this.url,
    required this.description,
    required this.latLng,
  });

  @override
  List<dynamic> get props => [
    id,
    groupID,
    creatorID,
    isOnline,
    name,
    formattedAddress,
    mapStaticImageURL,
    url,
    description,
    latLng,
  ];

  @override
  bool get stringify => true;

  factory LocationModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for location model');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for location model');
    }

    final groupID = data['groupID'];

    final creatorID = data['creatorID'] as String?;
    if (creatorID == null) {
      throw StateError('missing creatorID for location model');
    }

    final isOnline = data['isOnline'] as bool?;
    if (isOnline == null) {
      throw StateError('missing isOnline for location model');
    }

    final name = data['name'];

    final formattedAddress = data['formattedAddress'];

    final mapStaticImageURL = data['mapStaticImageURL'];

    final url = data['url'];

    final description = data['description'];

    final latLng = LatLng.fromJson(data['latLng']);

    return LocationModel(
      id: id,
      groupID: groupID,
      creatorID: creatorID,
      isOnline: isOnline,
      name: name,
      formattedAddress: formattedAddress,
      mapStaticImageURL: mapStaticImageURL,
      url: url,
      description: description,
      latLng: latLng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorID': creatorID,
      'groupID': groupID,
      'isOnline': isOnline,
      'name': name,
      'formattedAddress': formattedAddress,
      'mapStaticImageURL': mapStaticImageURL,
      'url': url,
      'description': description,
      'latLng': latLng?.toJson(),
    };
  }
}