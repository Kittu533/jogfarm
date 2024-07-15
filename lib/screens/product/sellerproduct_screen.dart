import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';

class SellerProductsScreen extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  SellerProductsScreen({required this.sellerId, required this.sellerName});

  Future<List<QueryDocumentSnapshot>> _fetchSellerProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('user_id', isEqualTo: sellerId)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching seller products: $e');
      throw e;
    }
  }

  String _formatPrice(String price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(double.tryParse(price) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produk dari $sellerName',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D4739),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _fetchSellerProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading products: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productId: product.id,
                        imageUrl: product['images'][0],
                        price: product['price'].toString(),
                        name: product['name'],
                        description: product['description'],
                        location: product['location'],
                        latitude: product['latitude'],
                        longitude: product['longitude'],
                        categoryId: product['category_id'],
                        sellerName: product['user_name'],
                        sellerAddress: '', // Update this if needed
                        typeId: product['type_id'],
                        isActive: product['is_active'],
                        createdAt: DateTime.parse(product['created_at']),
                        unitId: product['unit_id'],
                        images: List<String>.from(product['images']),
                        weight: product['weight'],
                        age: product['age'],
                        stock: product['stock'],
                        sellerId: product['user_id'],
                      ),
                    ),
                  );
                },
                child: _buildProductCard(
                  product['images'][0],
                  product['name'],
                  product['price'].toString(),
                  product['location'],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
      String imageUrl, String name, String price, String location) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatPrice(price)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(name),
                Text(location),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
