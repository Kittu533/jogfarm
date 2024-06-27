import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/verificationAccount/confirmface_screen.dart';

class FotoWajahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Wajah'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Arahkan wajah ke dalam frame'),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 300,
              color: Colors.grey,
              child: Center(child: Text('Frame Wajah')),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  KonfirmWajahScreen()),
                );
              },
              child: Text('Ambil Gambar'),
            ),
          ],
        ),
      ),
    );
  }
}
