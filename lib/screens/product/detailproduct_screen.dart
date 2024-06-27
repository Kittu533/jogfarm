import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Kembali', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'images/product_image.jpg', // Ganti dengan jalur gambar yang sesuai
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 10,
                  top: 40,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rp. 6.000.000',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Sapi metal',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Dilihat 13x', style: TextStyle(color: Colors.grey)),
                      Spacer(),
                      Icon(Icons.favorite_border, size: 20, color: Colors.grey),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Detail produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildProductDetailRow('Nama Produk', 'Sapi metal'),
                  _buildProductDetailRow('Kategori', 'Mamalia'),
                  _buildProductDetailRow('Berat produk', '300 Kg'),
                  _buildProductDetailRow('Usia hewan', '12 Bulan'),
                  _buildProductDetailRow('Lokasi', 'Yogyakarta'),
                  const Divider(height: 32),
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sapi Metal adalah sapi unggul dengan pertumbuhan cepat dan daging berkualitas tinggi. Dipelihara dengan standar terbaik, sapi ini menjamin keuntungan bagi peternak dan kualitas untuk konsumen.\n\nPembelian sapi Metal kami memastikan Anda mendapatkan hewan sehat dan produktif. Investasi ini cocok untuk meningkatkan hasil peternakan Anda.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: () {
                        // Handle chat action
                      },
                      child: const Text('Chat Sekarang', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Lainnya ditoko ini',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Lihat semua',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildProductRecommendations(),
                  const Divider(height: 32),
                  const Text(
                    'Rekomendasi Lain',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildProductRecommendations(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductRecommendations() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildProductCard('Sapi metal', 'Rp. 6.000.000', 'images/product_image.jpg'),
          _buildProductCard('Kambing Super', 'Rp. 6.000.000', 'images/product_image.jpg'),
          _buildProductCard('Ayam Boiler', 'Rp. 100.000', 'images/product_image.jpg'),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price, String imageUrl) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl, width: 150, height: 100, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProductDetailScreen(),
    );
  }
}
