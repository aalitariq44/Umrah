import 'package:geolocator/geolocator.dart';

class LocationRepository {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمات الموقع غير مفعلة. يرجى تفعيل GPS من الإعدادات');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض إذن الوصول للموقع');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('تم رفض إذن الوصول للموقع بشكل دائم. يرجى تفعيل الإذن من إعدادات التطبيق');
    } 

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      throw Exception('فشل في الحصول على الموقع الحالي. يرجى المحاولة مرة أخرى');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<double> distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Future<Position> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition() ?? await getCurrentPosition();
  }

  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
