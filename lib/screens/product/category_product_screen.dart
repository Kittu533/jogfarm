import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogfarmv1/model/products.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  final int categoryId;

  CategoryProductsScreen({required this.category, required this.categoryId});

  Stream<List<Product>> getProductsByCategory() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category_id', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk $category'),
        backgroundColor: const Color(0xFF2D4739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: getProductsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk yang ditemukan'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: product.productId,
              imageUrl: product.images.isNotEmpty
                  ? product.images[0]
                  : 'images/default_product.png',
              price: product.price.toString(),
              name: product.name,
              description: product.description,
              location: product.location,
              latitude: product.latitude,
              longitude: product.longitude,
              categoryId: product.categoryId,
              typeId: product.typeId,
              isActive: product.isActive,
              createdAt: product.createdAt,
              unitId: product.unitId,
              images: product.images,
              weight: product.weight,
              age: product.age,
              stock: product.stock,
              sellerName: product.userName,
              sellerAddress: "", // This value needs to be fetched or added in the Product model
              sellerId: product.userId,
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
                    image: NetworkImage(product.images.isNotEmpty
                        ? product.images[0]
                        : 'images/default_product.png'),
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
                    'Rp. ${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(product.name),
                  Text(product.location),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
