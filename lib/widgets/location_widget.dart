// lib/widgets/location_widget.dart
import 'package:flutter/material.dart';

class Location extends StatelessWidget {
  const Location({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.location_on, color: Color.fromARGB(255, 196, 14, 14)),
        SizedBox(width: 8),
        Text(
          'Lokasi',
          style: TextStyle(color: Color.fromARGB(255, 84, 60, 60)),
        ),
      ],
    );
  }
}
