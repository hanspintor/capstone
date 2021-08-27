import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      apiKey: 'AIzaSyD5uXWSGt2uIXHixz51hP2URf3D59ieTyw',
      initialPosition: PinLocationMap.kInitialPosition,
      useCurrentLocation: true,
      selectInitialPosition: true,
      searchForInitialValue: true,
      usePlaceDetailSearch: true,
      region: 'ph',
      onPlacePicked: (result) {
        selectedPlace = result;
        Navigator.pop(context, selectedPlace.formattedAddress);
        print(selectedPlace.formattedAddress);
        setState(() {});
      },
    );
  }
}