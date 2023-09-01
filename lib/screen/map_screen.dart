import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  LatLng myCurrentLocation = const LatLng(0, 0);
  final Set<Polyline> _polyline = {};
  final List<LatLng> _polylineLocations = [];
  Marker _marker = const Marker(markerId: MarkerId("my_current_location"));
  bool isPolyLineUpdated = true;

  @override
  void initState() {
    super.initState();
    getMyLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLng(myCurrentLocation),
    );
  }

  void getMyLocation() async {
    Location.instance.onLocationChanged
        .listen((LocationData myNewLocationData) {
      myCurrentLocation =
          LatLng(myNewLocationData.latitude!, myNewLocationData.longitude!);
      if (isPolyLineUpdated) {
        updatePolyline();
      }
      updateMarker();
      setState(() {});
    });
    locationUpdate();
  }

  void updatePolyline() {
    _polylineLocations.add(myCurrentLocation);
    _polyline.add(
      Polyline(
        polylineId: const PolylineId("current_polyline"),
        points: _polylineLocations,
        color: Colors.blue,
        width: 5,
        jointType: JointType.round,
      ),
    );
  }

  void updateMarker() {
    _marker = Marker(
      markerId: const MarkerId("my_current_location"),
      position: myCurrentLocation,
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: "Current Location",
          snippet:
              "Lat: ${myCurrentLocation.latitude}, Lng: ${myCurrentLocation.longitude},"),
      onTap: () {
        _googleMapController
            ?.showMarkerInfoWindow(const MarkerId("my_current_location"));
      },
    );
  }

  Future<void> locationUpdate() async {
    if (await Location.instance.serviceEnabled()) {
      Location.instance.changeSettings(interval: 10000);
      Location.instance.enableBackgroundMode(enable: true);
    } else {
      bool requestService = await Location.instance.requestService();
      if (!requestService) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real Time Location Tracking"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          zoom: 15,
          target: myCurrentLocation,
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        markers: {_marker},
        polylines: _polyline,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              isPolyLineUpdated = true;
              setState(() {});
            },
            child: const Text("Draw"),
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            onPressed: () {
              isPolyLineUpdated = false;
              setState(() {});
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
