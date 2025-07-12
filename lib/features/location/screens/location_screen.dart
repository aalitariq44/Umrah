import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // This will be the map view
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text('Map Placeholder'),
            ),
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
                        'الأشخاص القريبون',
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
                        child: ListView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildPersonTile('زينب', '10 كم'),
                            _buildPersonTile('ساره', '100 كم'),
                            _buildPersonTile('مريم', '120 كم'),
                            _buildPersonTile('محمد', '132 كم'),
                          ],
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
            // backgroundImage: AssetImage('...'),
          ),
          const SizedBox(height: 8),
          Text(name),
          Text(distance),
        ],
      ),
    );
  }
}
