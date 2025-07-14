import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../controller/location_controller.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  final LocationController _locationController = LocationController();
  Position? _currentPosition;
  String? _status;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الموقع'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('جاري الحصول على الموقع...'),
              const SizedBox(height: 32),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              child: const Text('الحصول على الموقع الحالي'),
            ),
            const SizedBox(height: 16),
            if (_status != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحالة:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_status!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_currentPosition != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الموقع الحالي:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('خط العرض: ${_currentPosition!.latitude}'),
                      Text('خط الطول: ${_currentPosition!.longitude}'),
                      Text('الدقة: ${_currentPosition!.accuracy} متر'),
                      Text('الوقت: ${_currentPosition!.timestamp}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _status = null;
    });

    try {
      final position = await _locationController.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _status = 'تم الحصول على الموقع بنجاح';
      });
    } catch (e) {
      setState(() {
        _status = 'خطأ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
