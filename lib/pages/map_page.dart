// lib/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../profile/profilescreen.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng? initialSelectedLocation;

  const GoogleMapPage({super.key, this.initialSelectedLocation});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  LatLng _currentMapCenter = const LatLng(3.1390, 101.6869); // Default KL
  late GoogleMapController _mapController;

  final Set<Marker> _markers = {};
  int _markerIdCounter = 1;
  MarkerId? _selectedMarkerId;

  BitmapDescriptor _customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedCustomIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    if (widget.initialSelectedLocation != null) {
      _currentMapCenter = widget.initialSelectedLocation!;
      _addMarker(_currentMapCenter, selectIt: true);
    }
  }

  Future<void> _loadCustomMarker() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      "assets/images/al-marhum/gravelocator.png",
    );
    setState(() {});
  }

  void _addMarker(LatLng position, {bool selectIt = false}) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final markerId = MarkerId(markerIdVal);

    final newMarker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(
        title: 'Location #${_markerIdCounter - 1}',
        snippet: 'Tap marker to select',
      ),
      onTap: () => _onMarkerTapped(markerId),
    );

    setState(() {
      _markers.add(newMarker);
      if (selectIt) _selectedMarkerId = markerId;
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    setState(() {
      _selectedMarkerId = markerId;
    });
  }

  Set<Marker> _getDisplayedMarkers() {
    return _markers.map((marker) {
      return marker.copyWith(
          iconParam: marker.markerId == _selectedMarkerId
              ? _selectedCustomIcon
              : _customIcon);
    }).toSet();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _pinMyLocation() async {
    try {
      final position = await _determinePosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 19),
        ),
      );

      _addMarker(currentLatLng, selectIt: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  void _confirmLocation() {
    if (_selectedMarkerId != null) {
      final selectedMarker =
          _markers.firstWhere((m) => m.markerId == _selectedMarkerId);
      Navigator.pop(context, selectedMarker.position);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please tap on a marker to select a location first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pin Grave Location'),
        titleTextStyle: const TextStyle(
          fontFamily: "Metamorphous",
          fontSize: 20,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary.withOpacity(0.95),
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check, color: AppColors.accent),
            label: const Text(
              'Confirm',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Metamorphous',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentMapCenter, zoom: 16),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: _getDisplayedMarkers(),
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.hybrid,
            onTap: _addMarker,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: SizedBox(
              width: 72,
              height: 72,
              child: FloatingActionButton(
                onPressed: _pinMyLocation,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                tooltip: 'Pin My Current Location',
                child: const Icon(Icons.my_location, size: 36),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
