import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:jogfarmv1/model/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String imageUrl;
  final String price;
  final String name;
  final String sellerName;
  final String sellerAddress;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final int categoryId;
  final int typeId;
  final bool isActive;
  final DateTime createdAt;
  final int unitId;
  final List<String> images;
  final double weight;
  final int age;
  final int stock;
  final String sellerId;

  ProductDetailScreen({
    required this.productId,
    required this.imageUrl,
    required this.price,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.sellerName,
    required this.sellerAddress,
    required this.typeId,
    required this.isActive,
    required this.createdAt,
    required this.unitId,
    required this.images,
    required this.weight,
    required this.age,
    required this.stock,
    required this.sellerId,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _animationController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> addToCart(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null && userId != widget.sellerId) {
      final cartItem = Cart(
        cartId: FirebaseFirestore.instance.collection('cart').doc().id,
        userId: userId,
        priceProduct: double.parse(widget.price),
        locationProduct: widget.location,
        sellerName: widget.sellerName,
        productName: widget.name,
        imageProduct: widget.imageUrl,
        quantity: 1,
        addedAt: DateTime.now(),
        productId: widget.productId,
      );

      FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItem.cartId)
          .set(cartItem.toMap())
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk ditambahkan ke keranjang')),
        );
        _showAddToCartAnimation(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan ke keranjang')),
        );
      });
    } else {
      openWarningSnackBar(context, 'Anda tidak bisa menambahkan produk Anda sendiri ke keranjang');
    }
  }

  void _showAddToCartAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Produk berhasil ditambahkan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/addtocart.json',
                repeat: false,
                width: 150,
                height: 150,
              ),
            ],
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

  Future<List<QueryDocumentSnapshot>> _fetchOtherProducts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('seller_id', isEqualTo: widget.sellerId)
        .limit(6)
        .get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> _fetchRecommendations() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('seller_id', isNotEqualTo: widget.sellerId)
        .limit(6)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D4739),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.images.length,
                      effect: WormEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        activeDotColor: Colors.white,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp. ${widget.price}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        iconSize: 16,
                        icon: isLiked
                            ? SizedBox(
                                width: 32,
                                height: 32,
                                child: Lottie.asset(
                                  'assets/animations/like.json',
                                  controller: _animationController,
                                  onLoaded: (composition) {
                                    _animationController.duration =
                                        composition.duration;
                                  },
                                ),
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                              ),
                        onPressed: toggleLike,
                      ),
                    ],
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Dilihat 13x', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Detail produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Nama Produk', widget.name),
                  _buildDetailRow(
                      'Kategori', _getCategoryName(widget.categoryId)),
                  _buildDetailRow('Berat produk', '${widget.weight} Kg'),
                  _buildDetailRow('Usia hewan', '${widget.age} Bulan'),
                  _buildDetailRow('Stok', '${widget.stock}'),
                  _buildDetailRow('Lokasi', widget.location),
                  SizedBox(height: 16),
                  Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(widget.description),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            addToCart(context);
                          },
                          icon: Icon(Icons.add_shopping_cart,
                              color: Colors.green),
                          label: Text(
                            '+Keranjang',
                            style: TextStyle(color: Colors.green),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                        'images/user_profil.png'), // Ubah jalur sesuai dengan gambar profil Anda
                    radius: 24.0,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sellerName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.sellerAddress),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lainnya ditoko ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _fetchOtherProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading products'));
                      }
                      final otherProducts = snapshot.data!;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: otherProducts.length,
                          itemBuilder: (context, index) {
                            final product = otherProducts[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    product['images'][0],
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Rp. ${product['price']} /ekor'),
                                  Text(product['location']),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rekomendasi Lain',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _fetchRecommendations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading products'));
                      }
                      final recommendations = snapshot.data!;
                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendations.length,
                          itemBuilder: (context, index) {
                            final product = recommendations[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    product['images'][0],
                                    height: 100,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Rp. ${product['price']} /ekor'),
                                  Text(product['location']),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Unggas';
      case 2:
        return 'Mamalia';
      case 3:
        return 'Hewan Akuatik';
      case 4:
        return 'Perlengkapan';
      default:
        return 'Lainnya';
    }
  }

  void openWarningSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.yellow,
      content: Row(
        children: [
          Icon(Icons.warning, color: Colors.black),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
      duration: Duration(milliseconds: 12500),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
