import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/account/myaccount_screen.dart';

import 'package:jogfarmv1/screens/helppage_screen.dart'; // Import halaman bantuan

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          SettingsItem(title: 'Akun Saya', destination: AkunSayaScreen()),
          SettingsItem(title: 'Ganti Password', destination: GantiPasswordScreen()),
          SettingsItem(title: 'Notifikasi', destination: NotifikasiScreen()),
          SettingsItem(title: 'Nonaktifkan akun', destination: NonaktifkanAkunScreen()),
          SettingsItem(title: 'Logout', destination: LogoutScreen()),
          SettingsItem(title: 'Bantuan', destination: HelpPage()), // Tambahkan item ini
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final Widget destination;

  const SettingsItem({super.key, required this.title, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 92, 28),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
        ),
        const Divider(),
      ],
    );
  }
}

// Dummy screens for navigation purposes

class GantiPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti Password'),
      ),
      body: Center(
        child: Text('Ganti Password Screen'),
      ),
    );
  }
}

class NotifikasiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
      ),
      body: Center(
        child: Text('Notifikasi Screen'),
      ),
    );
  }
}

class NonaktifkanAkunScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nonaktifkan Akun'),
      ),
      body: Center(
        child: Text('Nonaktifkan Akun Screen'),
      ),
    );
  }
}

class LogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: Text('Logout Screen'),
      ),
    );
  }
}
