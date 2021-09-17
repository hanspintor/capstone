import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
//import 'package:lottie/lottie.dart';
import 'package:proxpress/models/deliveries.dart';

class DeliveryStatus extends StatefulWidget {
  final Delivery delivery;

  DeliveryStatus({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    GoogleMapController _googleMapController;

    LatLng pickup_pos = LatLng(widget.delivery.pickupCoordinates.latitude, widget.delivery.pickupCoordinates.longitude,);
    Marker _pickup = Marker(
      markerId: const MarkerId('pickup'),
      infoWindow: const InfoWindow(title: 'Pickup Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: pickup_pos,
    );

    LatLng dropOff_pos = LatLng(widget.delivery.dropOffCoordinates.latitude, widget.delivery.dropOffCoordinates.longitude,);
    Marker _dropOff = Marker(
      markerId: const MarkerId('dropOff'),
      infoWindow: const InfoWindow(title: 'Drop Off Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOff_pos,
    );

    Future<Directions> _infoFetch = DirectionsRepository().getDirections(origin: _pickup.position, destination: _dropOff.position);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
        actions: [
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('nice'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
              );
            },
            iconSize: 25,
          ),
        ],
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 10),
          child: Image.asset(
            "assets/PROExpress-logo.png",
            height: 120,
            width: 120,
          ),
        ),
        //title: Text("PROExpress"),
      ),
      body: Center(
        // child: Column(
        //   children: [
        //     Container(
        //       margin: EdgeInsets.fromLTRB(0, 20, 40, 10),
        //         child: Lottie.asset('assets/delivery.json')
        //     ),
        //     Row(
        //       children: [
        //         Container(
        //           margin: EdgeInsets.fromLTRB(50, 0, 0, 10),
        //           child: Text('Delivery in Progress',
        //             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.only(top: 6),
        //           child: SizedBox(
        //             height: 50,
        //               width: 50,
        //               child: Lottie.asset('assets/dots.json')
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        child: SingleChildScrollView(
          child: Column(
            children: [
                FutureBuilder<Directions>(
                  future: _infoFetch,
                  builder: (context, AsyncSnapshot<Directions> snapshot) {
                    if (snapshot.hasData) {
                      Directions _info = snapshot.data;


                      CameraPosition _initialCameraPosition = CameraPosition(
                        target: LatLng(13.621980880497976, 123.19477396693487),
                        zoom: 15,
                      );

                      return Container(
                        height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _googleMapController = controller;

                            _googleMapController.animateCamera(
                              CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                            );

                            _googleMapController.showMarkerInfoWindow(MarkerId('pickup'));
                            //_googleMapController.showMarkerInfoWindow(MarkerId('dropOff'));
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          initialCameraPosition: _initialCameraPosition,
                          markers: {
                            if (_pickup != null) _pickup,
                            if (_dropOff != null) _dropOff
                          },
                          polylines: {
                            if (_info != null)
                              Polyline(
                                polylineId: const PolylineId('overview_polyline'),
                                color: Colors.red,
                                width: 5,
                                points: _info.polylinePoints
                                    .map((e) => LatLng(e.latitude, e.longitude))
                                    .toList(),
                              ),
                          },
                        ),
                      );
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()]
                        ),
                      );
                    }
                  }
                ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  'Send Feedback',
                  style:
                  TextStyle(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xfffb0d0d)),
                onPressed: () => showFeedback(),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: ElevatedButton.icon(
                  label: Text('Message Courier'),
                  icon: Icon(Icons.message_outlined),
                  style : ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                  onPressed: (){
                    Navigator.pushNamed(context, '/chatPage');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //shows the alert dialog for sending a feedback to the courier's service
  void showFeedback() => showDialog(
    context : context,
    builder: (context) => AlertDialog(
      title: Text('How\'s My Service?'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            minRating: 1,
            itemBuilder: (context, _) => Icon(Icons.star, color: Color(0xfffb0d0d)),
            updateOnDrag: true,
            onRatingUpdate: (rating) => setState((){
              this.rating = rating;
            }),
          ),
          Text('Rate Me',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          TextFormField(
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Leave a Feedback',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      ],
    ),
  );
}
