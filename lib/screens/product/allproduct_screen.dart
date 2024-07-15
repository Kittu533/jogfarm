import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/cart/cartpage_screen.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String? selectedCategory;
  String? selectedSortOption;

  Map<String, int> _categoryIds = {
    'UNGGAS': 1,
    'MAMALIA': 2,
    'HEWAN AKUATIK': 3,
    'PERLENGKAPAN': 4,
  };

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('products').where('is_active', isEqualTo: true);

    if (selectedCategory != null) {
      query = query.where('category_id', isEqualTo: _categoryIds[selectedCategory]);
    }

    if (selectedSortOption != null) {
      if (selectedSortOption == 'Terbaru') {
        query = query.orderBy('created_at', descending: true);
      } else if (selectedSortOption == 'Terlama') {
        query = query.orderBy('created_at', descending: false);
      }
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 50.0, right: 16.0),
            child: Row(
              children: [
                Flexible(
                  child: SizedBox(
                    height: 50.0,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pencarian',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyCartScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text('Kategori', style: TextStyle(color: Colors.white)),
                    dropdownColor: const Color(0xFF2D4739),
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    items: _categoryIds.keys.map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: selectedSortOption,
                    hint: const Text('Sortir', style: TextStyle(color: Colors.white)),
                    dropdownColor: const Color(0xFF2D4739),
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSortOption = newValue;
                      });
                    },
                    items: <String>['Terbaru', 'Terlama'].map<DropdownMenuItem<String>>((String sortOption) {
                      return DropdownMenuItem<String>(
                        value: sortOption,
                        child: Text(sortOption, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _buildQuery().get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          final products = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2 / 3,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
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
                  'Alamat tidak tersedia',
                  product['user_id'],
                );
              },
            ),
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
