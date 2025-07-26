import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../profile/profilescreen.dart';

class NavigationPage extends StatefulWidget {
  final LatLng destination;
  const NavigationPage({super.key, required this.destination});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  List<LatLng> _polylineCoords = [];
  String? _distanceText;
  String? _durationText;

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = pos);
    await _getDirections(
        LatLng(pos.latitude, pos.longitude), widget.destination);
  }

  Future<void> _getDirections(LatLng start, LatLng end) async {
    const apiKey = 'AIzaSyBF1_88o6YzgUa29TQgLZwd_c0ZsBDUxuk';
    final polylinePoints = PolylinePoints(apiKey: apiKey);
    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      setState(() {
        _polylineCoords =
            result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
        _distanceText = (result.distanceTexts?.isNotEmpty ?? false)
            ? result.distanceTexts!.first
            : null;
        _durationText = (result.durationTexts?.isNotEmpty ?? false)
            ? result.durationTexts!.first
            : null;
      });
    }
  }

  void _openExternalMaps() async {
    final start = _currentPosition;
    if (start == null) return;
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${widget.destination.latitude},${widget.destination.longitude}&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Metamorphous',
            fontSize: 22,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final polylines = <Polyline>{};
    if (_polylineCoords.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        color: AppColors.accent.withOpacity(0.85),
        width: 6,
        points: _polylineCoords,
      ));
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('start'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('dest'),
        position: widget.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Metamorphous',
          fontSize: 22,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            polylines: polylines,
            onMapCreated: (c) => _controller = c,
            mapType: MapType.hybrid,
          ),
          if (_distanceText != null && _durationText != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Distance: $_distanceText',
                          style: const TextStyle(
                            fontFamily: 'Metamorphous',
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 1, color: Colors.black54)
                            ],
                          ),
                        ),
                        Text(
                          'ETA: $_durationText',
                          style: const TextStyle(
                            fontFamily: 'Metamorphous',
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 1, color: Colors.black54)
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _openExternalMaps,
                          icon: const Icon(Icons.open_in_new,
                              color: AppColors.accent),
                          tooltip: 'Open in Maps',
                          splashRadius: 26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
