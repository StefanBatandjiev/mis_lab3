import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapWidget extends StatefulWidget {
  final Set<Marker> markers;
  const MapWidget({Key? key, required this.markers}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Locations'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(
              42.004186212873655, 21.409531941596985), // University coordinates
          zoom: 15, // Zoom level
        ),
        markers: widget.markers,
        onTap: _handleTap, // Handle tap events on the map
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _handleTap(LatLng tappedPoint) {
    _openGoogleMapsForDirections(tappedPoint);
  }

  void _openGoogleMapsForDirections(LatLng tappedPoint) async {
    final Marker nearestMarker = widget.markers.first;

    // Get the destination coordinates
    final double destinationLatitude = nearestMarker.position.latitude;
    final double destinationLongitude = nearestMarker.position.longitude;

    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude';
    final Uri uri = Uri.parse(googleMapsUrl);

    await launchUrl(uri);
  }
}
