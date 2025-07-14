import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repository/location_repository.dart';

class LocationController with ChangeNotifier {
  final LocationRepository _locationRepository;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;

  LocationController({LocationRepository? locationRepository})
      : _locationRepository = locationRepository ?? LocationRepository();

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Position> getCurrentPosition() async {
    _setLoading(true);
    _setError(null);

    try {
      final position = await _locationRepository.getCurrentPosition();
      _currentPosition = position;
      notifyListeners();
      return position;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await _locationRepository.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await _locationRepository.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await _locationRepository.requestPermission();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
