import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  final int categoryId;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
    required this.categoryId,
  }) : super(key: key);

  Future<String> _fetchSellerAddress(String sellerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return userDoc['address'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk $category'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .where('type_id', isEqualTo: categoryId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return FutureBuilder<String>(
                future: _fetchSellerAddress(product['user_id']),
                builder: (context, addressSnapshot) {
                  if (addressSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (addressSnapshot.hasError) {
                    return const Center(child: Text('Error loading address'));
                  }

                  final sellerAddress = addressSnapshot.data ?? '';

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
                    product['user_name'],
                    sellerAddress,
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
    String userName,
    String sellerAddress,
    String userId,
  ) {
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
              sellerName: userName,
              sellerAddress: sellerAddress,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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
                    'Rp. $price',
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
      ),
    );
  }
}
