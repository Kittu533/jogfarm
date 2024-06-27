import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/verificationAccount/facephoto_screen.dart';

class KonfirmKtpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi KTP'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Pastikan KTP dapat dilihat dengan jelas'),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 300,
              color: Colors.grey,
              child: Center(child: Text('Gambar KTP')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  FotoWajahScreen()),
                );
              },
              child: Text('Simpan dan Lanjut'),
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
