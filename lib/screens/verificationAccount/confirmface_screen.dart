import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/verificationAccount/waitverification_screen.dart';

class KonfirmWajahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Wajah'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Pastikan wajah dapat dilihat dengan jelas'),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 300,
              color: Colors.grey,
              child: Center(child: Text('Gambar Wajah')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  TungguVerifikasiScreen()),
                );
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ulangi'),
            ),
          ],
        ),
      ),
    );
  }
}
