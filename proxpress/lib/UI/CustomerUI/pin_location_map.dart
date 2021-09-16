import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/services/secrets.dart';

class PinLocationMap extends StatefulWidget {
  const PinLocationMap({Key key}) : super(key: key);

  static final kInitialPosition = LatLng(13.621980880497976, 123.19477396693487);

  @override
  _PinLocationMapState createState() => _PinLocationMapState();
}

class _PinLocationMapState extends State<PinLocationMap> {
  PickResult selectedPlace;

  @override
  Widget build(BuildContext context) {
    return PlacePicker(
      apiKey: Secrets.API_KEY,
      initialPosition: PinLocationMap.kInitialPosition,
      useCurrentLocation: false, // switch to true if user activated GPS to track his current location
      selectInitialPosition: true,
      searchForInitialValue: true,
      usePlaceDetailSearch: true,
      region: 'ph',
      onPlacePicked: (result) {
        selectedPlace = result;
        LatLng selectedPlaceCoordinates = LatLng(selectedPlace.geometry.location.lat, selectedPlace.geometry.location.lng);
        Navigator.pop(context, LocationDetails(address: selectedPlace.formattedAddress, coordinates: selectedPlaceCoordinates));
        setState(() {});
      },
    );
  }
}

class LocationDetails {
  String address;
  LatLng coordinates;

  LocationDetails({ this.address, this.coordinates });
}