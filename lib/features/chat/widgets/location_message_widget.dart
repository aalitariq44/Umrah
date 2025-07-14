import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMessageWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const LocationMessageWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
              SizedBox(height: 8),
              Text(
                'خطأ في الموقع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () async {
        await _openLocation();
      },
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 40,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
              'موقعي',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'خط العرض: ${latitude!.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              'خط الطول: ${longitude!.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'اضغط لفتح الخريطة',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocation() async {
    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to opening in browser
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      // Handle error silently or show a toast
      debugPrint('Error opening location: $e');
    }
  }
}
