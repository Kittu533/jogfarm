import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Item> _data = [
    Item(header: 'Cara membeli', body: '1. Pilih hewan yang ingin dibeli untuk masuk ke halaman detail produk\n2. Klik tombol Beli\n3. Masukkan jumlah hewan yang ingin dibeli\n4. Lanjut proses pembayaran\n5. Pesanan telah masuk ke halaman “Pesanan”'),
    Item(header: 'Cara Upgrade Akun', body: '1. Masuk ke halaman profile\n2. Pilih menu akun bisnis\n3. Kemudian pada halaman upgrade akun, pilih lanjutkan\n4. Siapkan KTP sebagai data yang dibutuhkan untuk mengupgrade akun\n5. Foto kartu KTP yang telah disiapkan\n6. Kemudian klik tombol “simpan dan lanjut” untuk melanjutkan ke proses berikutnya.\n7. apabila gambar kurang jelas dapat klik tombol “ulang” untuk mengulangi pengambilan gambar kartu KTP\n8. Lanjutkan dengan foto wajah untuk verifikasi lebih lanjut\n9. kemudian klik simpan dan lanjutkan\n10. Tunggu proses verifikasi sampai selesai'),
    Item(header: 'Cara Upload Produk', body: 'Deskripsi cara upload produk di sini...'),
    Item(header: 'Cara kelola produk', body: 'Deskripsi cara kelola produk di sini...'),
    Item(header: 'Cara mengganti password akun', body: 'Deskripsi cara mengganti password akun di sini...'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
        title: const Text(
          'Bantuan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: _data.map<Widget>((Item item) {
          return ExpansionTile(
            title: Text(
              item.header,
              style: TextStyle(
                color: Color.fromARGB(255, 23, 92, 28),
                fontWeight: FontWeight.bold,
              ),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(item.body),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class Item {
  Item({required this.header, required this.body});

  final String header;
  final String body;
}
