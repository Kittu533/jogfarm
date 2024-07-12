import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Item> _data = [
    Item(header: 'Cara membeli', body: '• Pilih hewan yang ingin dibeli untuk masuk ke halaman detail produk\n• Klik tombol Beli\n• Masukkan jumlah hewan yang ingin dibeli\n• Lanjut proses pembayaran\n• Pesanan telah masuk ke halaman “Pesanan”'),
    Item(header: 'Cara Upgrade Akun', body: '• Masuk ke halaman profile\n• Pilih menu akun bisnis\n• Kemudian pada halaman upgrade akun, pilih lanjutkan\n• Siapkan KTP sebagai data yang dibutuhkan untuk mengupgrade akun\n• Foto kartu KTP yang telah disiapkan\n• Kemudian klik tombol “simpan dan lanjut” untuk melanjutkan ke proses berikutnya.\n• apabila gambar kurang jelas dapat klik tombol “ulang” untuk mengulangi pengambilan gambar kartu KTP\n• Lanjutkan dengan foto wajah untuk verifikasi lebih lanjut\n• kemudian klik simpan dan lanjutkan\n• Tunggu proses verifikasi sampai selesai'),
    Item(header: 'Cara Upload Iklan', body: '• Pastikan akun sudah terupgrade ke “akun bisnis”\n• Klik Tombol “+” pada navbar\n• kemudian pilih\n• Pilih kategori dan jenis hewan yang ingin di upload kemudian klik “Lanjutkan”\n• Isi detail data dari hewan yang akan di iklankan seperti gambar, nama, harga, deskripsi, berat, usia, dan lokasi.\n• setelah semua data terisi klik tombol “unggah iklan”\n• setelah itu iklan akan terupload dan iklan dapat dilihat pada halaman produk saya'),
    Item(header: 'Cara Kelola Iklan', body: '• masuk ke halaman Iklan saya\n• pada halaman ini, anda dapat mengedit iklan, mengarsipkan dan menghapus iklan\n• apabila anda ingin mengedit iklan maka klik tombol edit kemudian ganti data yang ingin diperbarui.\n• apabila anda ingin mengarsipkan iklan, maka klik tombol arsipkan dan status iklan akan menjadi diarsipkan dan anda dapat klik tombol “aktifkan” untuk mengaktifkan kembali iklan yang diarsipkan\n• apabila anda ingin menghapus iklan, maka klik tombol hapus'),
    Item(header: 'Cara Ganti Password', body: '• Masuk ke halaman “profile”\n• Klik menu “pengaturan”\n• Kemudian klik tombol “ganti password”\n• Pada halaman “Ganti password” masukkan email anda kemudian klik tombol “Kirim OTP”\n• Masukkan kode OTP yang dikirimkan melalui email ke dalam halaman verifikasi kode OTP\n• apabila kode OTP tidak muncul dalam email, klik tombol “kirim ulang”\n• setelah kode OTP terisi, klik tombol “verifikasi” ketikkan kata sandi baru dan masukkan kembali kata sandi baru yang telah dibuat pada kolom yang sudah disediakan\n• apabila anda sudah yakin dengan password baru yang sudah di isi, klik tombol “confirm password”\n• password telah terganti'),
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
