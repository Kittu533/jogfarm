import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;

  SearchResultsScreen({required this.searchQuery});

  Future<String> _fetchSellerUsername(String sellerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return userDoc['username'] ?? '';
  }

  String _formatPrice(String price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0);
    return formatter.format(double.tryParse(price) ?? 0);
  }

  Future<List<QueryDocumentSnapshot>> _fetchSearchResults() async {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Pencarian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        future: _fetchSearchResults(),
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
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return FutureBuilder<String>(
                future: _fetchSellerUsername(product['user_id']),
                builder: (context, usernameSnapshot) {
                  if (usernameSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (usernameSnapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error loading username: ${usernameSnapshot.error}'));
                  }

                  final sellerUsername = usernameSnapshot.data ?? '';

                  return _buildProductCard(
                    context,
                    product.id,
                    product['images'][0],
                    product['price'].toString(),
                    product['name'],
                    product['description'],
                    product['location'],
                    product['latitude'],
                    product['longitude'],
                    product['category_id'],
                    product['type_id'],
                    product['is_active'],
                    DateTime.parse(product['created_at']),
                    product['unit_id'],
                    List<String>.from(product['images']),
                    product['weight'],
                    product['age'],
                    product['stock'],
                    sellerUsername,
                    product['user_id'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productId,
    String imageUrl,
    String price,
    String name,
    String description,
    String location,
    double latitude,
    double longitude,
    int categoryId,
    int typeId,
    bool isActive,
    DateTime createdAt,
    int unitId,
    List<String> images,
    double weight,
    int age,
    int stock,
    String sellerUsername,
    String userId,
  ) {
    String unit = unitId == 1 ? "Kg" : "Ekor";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: productId,
              imageUrl: imageUrl,
              price: price,
              name: name,
              description: description,
              location: location,
              latitude: latitude,
              longitude: longitude,
              categoryId: categoryId,
              typeId: typeId,
              isActive: isActive,
              createdAt: createdAt,
              unitId: unitId,
              images: images,
              weight: weight,
              age: age,
              stock: stock,
              sellerName: sellerUsername,
              sellerAddress: '',
              sellerId: userId,
            ),
          ),
        );
      },
      child: Card(
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
                    '${_formatPrice(price)}/$unit',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(name),
                  Text(location),
                  Text('Penjual: $sellerUsername'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
