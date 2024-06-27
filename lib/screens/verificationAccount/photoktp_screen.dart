import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/verificationAccount/confirmktpscan_screen.dart';

class FotoKtpScreen extends StatelessWidget {
  const FotoKtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Letakkan KTP di dalam Frame',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: 300,
              color: Colors.grey[300],
              child: const Center(child: Text('Frame KTP')),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  KonfirmKtpScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4739),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
              child: const Text(
                'Ambil Gambar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
