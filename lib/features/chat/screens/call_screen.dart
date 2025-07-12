import 'dart:ui';
import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          Image.network(
            'https://via.placeholder.com/400', // Replace with actual user image
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                  title: const Text('مكالمة...'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 50 /*, backgroundImage: ...*/),
                    SizedBox(width: 20),
                    CircleAvatar(radius: 50 /*, backgroundImage: ...*/),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('03:45', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCallButton(Icons.mic_off, () {}),
                    const SizedBox(width: 20),
                    _buildCallButton(Icons.volume_up, () {}),
                    const SizedBox(width: 20),
                    _buildCallButton(Icons.call_end, () {
                      Navigator.of(context).pop();
                    }, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton(IconData icon, VoidCallback onPressed, {Color color = Colors.white}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color.withOpacity(0.3),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
