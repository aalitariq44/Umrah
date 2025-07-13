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
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _authRepository.getFriends();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );
    });
    _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition == null) return;
    final GoogleMapController controller = await _controller.future;
    final newPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: 14.4746,
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
