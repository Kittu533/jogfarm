import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogfarmv1/screens/verificationAccount/photoktp_screen.dart';

class UpgradeAkunScreen extends StatelessWidget {
  const UpgradeAkunScreen({super.key});

  Future<bool> _isKtpConfirmed(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc['is_ktp_confirmed'] ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Kembali'),
        backgroundColor: const Color(0xFF2D4739),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dapatkan Fitur dengan membuat akun Premium',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              child: Center(
                child: Image.asset(
                  'assets/images/upgrade.png',
                   // Path yang benar untuk gambar // Ukuran tinggi gambar
                  width: 800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Fitur', style: TextStyle(fontSize: 16)),
                Text('Regular', style: TextStyle(fontSize: 16)),
                Text('Premium', style: TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
            FutureBuilder<bool>(
              future: _isKtpConfirmed(currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading data');
                } else {
                  bool isKtpConfirmed = snapshot.data ?? false;
                  return Column(
                    children: [
                      ListTile(
                        title: const Text('Menjual hewan ternak'),
                        trailing: isKtpConfirmed
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.lock, color: Colors.grey),
                        leading: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Mengelola Penjualan'),
                        trailing: isKtpConfirmed
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.lock, color: Colors.grey),
                        leading: const Icon(Icons.lock, color: Colors.grey),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Chat dengan pembeli'),
                        trailing: isKtpConfirmed
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.lock, color: Colors.grey),
                        leading: const Icon(Icons.lock, color: Colors.grey),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoKtpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4739),
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                ),
                child: const Text(
                  'Upgrade Akun',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
