// lib/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng? initialSelectedLocation;

  const GoogleMapPage({
    super.key,
    this.initialSelectedLocation,
  });

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  LatLng _currentMapCenter = const LatLng(3.1390, 101.6869); // Default to KL
  late GoogleMapController _mapController;

  // --- MODIFIED STATE VARIABLES ---
  // The set now holds all markers pinned during the session.
  final Set<Marker> _markers = {};
  // A counter to ensure each new marker gets a unique ID.
  int _markerIdCounter = 1;
  // This will store the ID of the marker that the user has selected for confirmation.
  MarkerId? _selectedMarkerId;

  // Icons for default and selected states for clear visual feedback.
  BitmapDescriptor _customIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedCustomIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // A distinct selected icon

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    // If an initial location was passed, add it as the first marker and select it
    if (widget.initialSelectedLocation != null) {
      _currentMapCenter = widget.initialSelectedLocation!;
      // Add the initial marker and pre-select it
      _addMarker(_currentMapCenter, selectIt: true);
    }
  }

  Future<void> _loadCustomMarker() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      "assets/images/al-marhum/gravelocator.png",
    );
    // You could also load a different asset for the selected state if you have one:
    // _selectedCustomIcon = await BitmapDescriptor.fromAssetImage(...);
    setState(() {}); // Redraw with custom icon once loaded
  }

  // --- MODIFIED: Handles adding markers without clearing old ones ---
  void _addMarker(LatLng position, {bool selectIt = false}) {
    // Generate a unique ID for the new marker
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker newMarker = Marker(
      markerId: markerId,
      position: position,
      // The icon will be determined by the _generateMarkers method based on selection
      infoWindow: InfoWindow(
        title: 'Location #${_markerIdCounter - 1}',
        snippet: 'Tap marker to select',
      ),
      // Set the handler for when this marker is tapped.
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );

    setState(() {
      _markers.add(newMarker);
      // If specified, also select this new marker
      if (selectIt) {
        _selectedMarkerId = markerId;
      }
    });
  }

  // --- NEW: Handles the logic when a marker is tapped ---
  void _onMarkerTapped(MarkerId markerId) {
    setState(() {
      // Update the state to reflect the new selection
      _selectedMarkerId = markerId;
    });
  }

  // --- NEW: Dynamically builds the marker set for the map ---
  // This ensures the selected marker has a different icon.
  Set<Marker> _getDisplayedMarkers() {
    final Set<Marker> displayedMarkers = {};
    for (final marker in _markers) {
      // Create a copy of the marker, but change its icon if it's the selected one
      displayedMarkers.add(
        marker.copyWith(
          iconParam: marker.markerId == _selectedMarkerId
              ? _selectedCustomIcon
              : _customIcon,
        ),
      );
    }
    return displayedMarkers;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _pinMyLocation() async {
    try {
      final position = await _determinePosition();
      final LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 19),
        ),
      );

      // Add a new marker at the user's location and select it automatically
      _addMarker(currentLatLng, selectIt: true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  // --- MODIFIED: Confirms the currently selected marker's location ---
  void _confirmLocation() {
    if (_selectedMarkerId != null) {
      // Find the selected marker from our source-of-truth set
      final Marker selectedMarker = _markers.firstWhere(
            (marker) => marker.markerId == _selectedMarkerId,
      );
      Navigator.pop(context, selectedMarker.position);
    } else {
      // Show an error if no marker is selected yet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on a marker to select a location first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Grave Location'),
        titleTextStyle: const TextStyle(
          fontFamily: "Metamorphous",
          fontSize: 20,
          color: Colors.black87,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: _confirmLocation,
            icon: const Icon(Icons.check, color: Colors.green),
            label: const Text('Confirm', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentMapCenter, zoom: 16),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            // Use the new method to get markers with correct icons
            markers: _getDisplayedMarkers(),
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.hybrid,
            onTap: (LatLng position) {
              // Tapping the map adds a new marker (but doesn't auto-select it)
              _addMarker(position);
            },
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
                foregroundColor: Colors.green.shade800,
                tooltip: 'Pin My Current Location',
                child: const Icon(Icons.my_location, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}