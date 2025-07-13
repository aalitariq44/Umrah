import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myplace/features/auth/repository/auth_repository.dart';
import 'package:myplace/data/models/user_model.dart' as model;

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final AuthRepository _authRepository = AuthRepository();
  late Future<List<model.User>> _friendsFuture;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _authRepository.getFriends();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle disabled service
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle denied permission
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permission
      return;
    }

    // Get initial position
    final position = await Geolocator.getCurrentPosition();
    _updateMapWithNewPosition(position, moveCamera: true);

    // Start listening to position stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update when device moves 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        _updateMapWithNewPosition(position);
      }
    });

    // Start timer to upload location every 1 minute
    _locationUpdateTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
      final currentPosition = await Geolocator.getCurrentPosition();
      await _authRepository.updateUserLocation(currentPosition);
    });
  }

  void _updateMapWithNewPosition(Position position,
      {bool moveCamera = false}) {
    setState(() {
      final newLatLng = LatLng(position.latitude, position.longitude);
      _routeCoords.add(newLatLng);

      // Update marker
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: newLatLng,
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );

      // Update polyline
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routeCoords,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    if (moveCamera) {
      _goToCurrentLocation(position);
    }
  }

  Future<void> _goToCurrentLocation(Position position) async {
    final GoogleMapController controller = await _controller.future;
    final newPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.3152, 44.3661), // Default location
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'موقع الاصدقاء',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 120, // Adjust height as needed
                        child: FutureBuilder<List<model.User>>(
                          future: _friendsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No friends found.'));
                            }

                            final friends = snapshot.data!;
                            return ListView.builder(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                final friend = friends[index];
                                return _buildPersonTile(friend.name, '... km');
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonTile(String name, String distance) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            child: Icon(Icons.person),
          ),
          const SizedBox(height: 8),
          Text(name),
          Text(distance),
        ],
      ),
    );
  }
}
