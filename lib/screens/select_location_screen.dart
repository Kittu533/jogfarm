import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(-6.200000, 106.816666); // Ganti dengan lokasi awal yang diinginkan
  LatLng? _selectedPosition;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _onConfirm() {
    Navigator.pop(context, _selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi'),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _onConfirm,
            )
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15,
        ),
        onTap: _onTap,
        markers: _selectedPosition != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: _selectedPosition!,
                ),
              }
            : {},
      ),
    );
  }
}
