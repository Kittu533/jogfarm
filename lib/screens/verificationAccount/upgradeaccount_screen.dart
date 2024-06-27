import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/verificationAccount/photoktp_screen.dart';

class UpgradeAkunScreen extends StatelessWidget {
  const UpgradeAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Kembali',
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF2D4739),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: const Text(
                'Dapatkan Fitur dengan membuat akun Premium',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/upgrade.png', // Path yang benar untuk gambar
                width: 1000,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(
                    width: 150,
                    child: Text('Fitur', style: TextStyle(fontSize: 16))),
                Text('Regular', style: TextStyle(fontSize: 16)),
                Text('Premium', style: TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
            ListTile(
              title: const Text('Menjual hewan ternak'),
              leading: const Icon(Icons.lock, color: Colors.grey),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock, color: Colors.grey),
                  SizedBox(width: 40),
                  Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Mengelola Penjualan'),
              leading: const Icon(Icons.lock, color: Colors.grey),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock, color: Colors.grey),
                  SizedBox(width: 40),
                  Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Chat dengan pembeli'),
              leading: const Icon(Icons.lock, color: Colors.grey),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock, color: Colors.grey),
                  SizedBox(width: 40),
                  Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 300),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FotoKtpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4739),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                ),
                child: const Text(
                  'Upgrade Akun',
                  style: TextStyle(fontSize: 16,color: Colors.white ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
