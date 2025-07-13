import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _friendsFuture.then((friends) => _updateFriendsOnMap(friends));
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

  Future<BitmapDescriptor> _createCustomMarkerBitmap(
      String name, String photoUrl) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double size = 150; // The size of the marker icon
    final double imageSize = 100; // The size of the profile image
    final double textHeight = 50; // The height for the name text

    // Draw background
    final Paint backgroundPaint = Paint()..color = Colors.white;
    final RRect backgroundRRect = RRect.fromLTRBR(
        0, 0, size, size, const Radius.circular(75));
    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // Draw image or placeholder
    if (photoUrl.isNotEmpty) {
      try {
        final ByteData data =
            await NetworkAssetBundle(Uri.parse(photoUrl)).load(photoUrl);
        final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
            targetWidth: imageSize.toInt());
        final ui.FrameInfo fi = await codec.getNextFrame();
        
        final Path clipPath = Path()
          ..addRRect(RRect.fromLTRBR(
              (size - imageSize) / 2,
              (size - imageSize) / 2,
              size - (size - imageSize) / 2,
              size - (size - imageSize) / 2,
              const Radius.circular(50)));
        canvas.clipPath(clipPath);
        canvas.drawImage(fi.image, Offset((size - fi.image.width) / 2, (size - fi.image.height) / 2), Paint());

      } catch (e) {
        // Fallback to placeholder if image fails to load
        _drawPlaceholder(canvas, name, size, imageSize);
      }
    } else {
      _drawPlaceholder(canvas, name, size, imageSize);
    }

    // Draw name
    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.black))
      ..addText(name);
    final ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size));
    canvas.drawParagraph(
        paragraph, Offset(0, size - textHeight + 10));

    final ui.Image recordedImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await recordedImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _drawPlaceholder(Canvas canvas, String name, double size, double imageSize) {
    final Paint placeholderPaint = Paint()..color = Colors.purple;
     canvas.drawCircle(Offset(size / 2, size / 2), imageSize / 2, placeholderPaint);

    final ui.ParagraphBuilder initialBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
    )
      ..pushStyle(ui.TextStyle(color: Colors.white))
      ..addText(name.isNotEmpty ? name[0].toUpperCase() : '');
    final ui.Paragraph initialParagraph = initialBuilder.build();
    initialParagraph.layout(ui.ParagraphConstraints(width: imageSize));
    canvas.drawParagraph(initialParagraph, Offset((size - imageSize) / 2, (size - imageSize) / 2 - 5));
  }

  void _updateFriendsOnMap(List<model.User> friends) async {
    final Set<Marker> friendsMarkers = {};
    final Set<Polyline> friendsPolylines = {};

    for (final friend in friends) {
      if (friend.locations.isNotEmpty) {
        final lastLocation = friend.locations.last;
        final friendPosition =
            LatLng(lastLocation.latitude, lastLocation.longitude);

        final icon = await _createCustomMarkerBitmap(friend.name, friend.photoUrl);

        friendsMarkers.add(
          Marker(
            markerId: MarkerId(friend.uid),
            position: friendPosition,
            icon: icon,
          ),
        );

        final friendRouteCoords = friend.locations
            .map((gp) => LatLng(gp.latitude, gp.longitude))
            .toList();

        friendsPolylines.add(
          Polyline(
            polylineId: PolylineId(friend.uid),
            points: friendRouteCoords,
            color: Colors.purple,
            width: 5,
          ),
        );
      }
    }

    setState(() {
      _markers.addAll(friendsMarkers);
      _polylines.addAll(friendsPolylines);
    });
  }

  void _updateMapWithNewPosition(Position position,
      {bool moveCamera = false}) {
    setState(() {
      final newLatLng = LatLng(position.latitude, position.longitude);
      _routeCoords.add(newLatLng);

      // Update marker
      _markers.removeWhere(
          (marker) => marker.markerId == const MarkerId('currentLocation'));
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: newLatLng,
          infoWindow: const InfoWindow(title: 'My Location'),
        ),
      );

      // Update polyline
      _polylines
          .removeWhere((line) => line.polylineId == const PolylineId('route'));
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
