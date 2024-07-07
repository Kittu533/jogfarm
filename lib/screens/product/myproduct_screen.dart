import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/model/products.dart';
import 'package:jogfarmv1/screens/product/editmyproduct_screen.dart'; // Pastikan jalur ini benar
import 'package:lottie/lottie.dart';

class MyProductScreen extends StatelessWidget {
  const MyProductScreen({super.key});

  Stream<List<Product>> getProducts() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('products')
        .where('user_id', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> _updateProductStatus(
      BuildContext context, String productId, bool isActive) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'is_active': isActive});
    _showStatusUpdateAnimation(context, isActive);
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
    _showDeleteAnimation(context);
  }

  void _showStatusUpdateAnimation(BuildContext context, bool isActive) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isActive ? 'Produk Diaktifkan' : 'Produk Diarsipkan'),
          content: SizedBox(
            width: 200, // Adjust width as needed
            height: 200, // Adjust height as needed
            child: Lottie.asset(
              isActive
                  ? 'assets/animations/success.json'
                  : 'assets/animations/archivev1.json',
              repeat: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Produk Dihapus'),
          content: Lottie.asset(
            'assets/animations/success.json',
            repeat: false,
            width: 150,
            height: 150,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          title: const Text(
            'Produk Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: 4.0, color: Color.fromARGB(255, 0, 255, 13)),
              insets: EdgeInsets.symmetric(
                  horizontal: 50.0), // Lebar horizontal dari indikator
            ), // Warna teks tab yang terpilih
            unselectedLabelColor:
                Colors.grey, // Warna teks tab yang tidak terpilih
            tabs: [
              Tab(text: 'Produk'),
              Tab(text: 'Pesanan'),
              Tab(text: 'Diantar'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductsTab(context),
            _buildOrdersTab('Pesanan'),
            _buildOrdersTab('Diantar'),
            _buildOrdersTab('Dibatalkan'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<Product>>(
        stream: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk yang diunggah'));
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Opacity(
                opacity: product.isActive ? 1.0 : 0.5,
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Sesuaikan nilai radius sesuai kebutuhan
                              child: Image.network(
                                product.images.isNotEmpty
                                    ? product.images[0]
                                    : 'images/default_product.png', // Ganti dengan jalur gambar yang sesuai
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Rp${product.price}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  Text(
                                    'Stok :${product.stock.toString()}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  Text(
                                    'Lokasi :${product.location}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProductScreen(
                                          product:
                                              product)), // Pass the product here
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .green, // Ganti dengan warna latar belakang yang diinginkan
                                foregroundColor: Colors
                                    .white, // Ganti dengan warna teks yang diinginkan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Ganti dengan nilai radius yang diinginkan
                                ),
                              ),
                              child: const Text('Ubah'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _updateProductStatus(context, product.productId,
                                    !product.isActive);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .green, // Ganti dengan warna latar belakang yang diinginkan
                                foregroundColor: Colors
                                    .white, // Ganti dengan warna teks yang diinginkan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Ganti dengan nilai radius yang diinginkan
                                ),
                              ),
                              child: Text(
                                  product.isActive ? 'Arsipkan' : 'Aktifkan'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _deleteProduct(context, product.productId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .green, // Ganti dengan warna latar belakang yang diinginkan
                                foregroundColor: Colors
                                    .white, // Ganti dengan warna teks yang diinginkan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Ganti dengan nilai radius yang diinginkan
                                ),
                              ),
                              child: const Text('Hapus'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab(String status) {
    // Implementasi tab pesanan, diantar, dan dibatalkan
    return Center(child: Text('Tab $status'));
  }
}

// class IconText extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const IconText({super.key, required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: Colors.grey),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     );
//   }
// }
