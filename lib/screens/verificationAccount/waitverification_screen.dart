import 'package:flutter/material.dart';

class TungguVerifikasiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tunggu Verifikasi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Data telah terkirim'),
            SizedBox(height: 20),
            Text('Tunggu verifikasi data agar akun kamu di-upgrade'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}
