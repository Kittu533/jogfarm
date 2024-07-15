import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jogfarmv1/screens/account/myaccount_screen.dart';
import 'package:jogfarmv1/screens/cart/cartpage_screen.dart';
import 'package:jogfarmv1/screens/chat/chatall_screen.dart';
import 'package:jogfarmv1/screens/chat/chatlist_screen.dart';
import 'package:jogfarmv1/screens/product/allproduct_screen.dart';
import 'package:jogfarmv1/screens/product/category_product_screen.dart';
import 'package:jogfarmv1/screens/product/myproduct_screen.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';
import 'package:jogfarmv1/screens/product/uploadproduct_screen.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart';
import 'package:jogfarmv1/screens/search_results_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isSeller = false;
  bool _showLoginPopup = false;
  List<Widget> _widgetOptions = [];
  String _searchQuery = "";
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      _isLoggedIn = isLoggedIn;

      _widgetOptions = [
        HomePage(),
        ChatListScreen(),
        UploadProductScreen(),
        const MyProductScreen(),
        const AkunSayaScreen(),
      ];

      if (!isLoggedIn) {
        _showLoginPopup = true;
      }
    });
  }

  void _navigateToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyCartScreen()),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  String _formatPrice(String price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp.', decimalDigits: 0);
    return formatter.format(double.tryParse(price) ?? 0);
  }

  Future<String> _fetchSellerUsername(String sellerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return userDoc['username'] ?? '';
  }

  Future<List<QueryDocumentSnapshot>> _fetchProducts() async {
    Query query = FirebaseFirestore.instance.collection('products');
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: _searchQuery + '\uf8ff');
    }
    query = query
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(6);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgList = [
      'images/news_image.jpg',
      'images/news_image.jpg',
      'images/news_image.jpg',
    ];
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
            if (_showLoginPopup)
              Center(
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: const Text('Login Diperlukan'),
                  content: const Text(
                      'Anda dianjurkan untuk login untuk menikmati semua fitur aplikasi.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showLoginPopup = false;
                        });
                      },
                      child: const Text('Nanti'),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavBarFb1(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class BottomNavBarFb1 extends StatelessWidget {
  const BottomNavBarFb1({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  final int selectedIndex;
  final Function(int) onItemTapped;

  final primaryColor = const Color(0xFF2D4739);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: SizedBox(
        height: 56,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBottomBar(
                icon: Icons.home,
                selected: selectedIndex == 0,
                onPressed: () => onItemTapped(0),
                primaryColor: primaryColor,
              ),
              IconBottomBar(
                icon: Icons.chat,
                selected: selectedIndex == 1,
                onPressed: () => onItemTapped(1),
                primaryColor: primaryColor,
              ),
              IconBottomBar2(
                icon: Icons.add_circle_outline,
                selected: selectedIndex == 2,
                onPressed: () => onItemTapped(2),
                primaryColor: primaryColor,
              ),
              IconBottomBar(
                icon: Icons.inventory,
                selected: selectedIndex == 3,
                onPressed: () => onItemTapped(3),
                primaryColor: primaryColor,
              ),
              IconBottomBar(
                icon: Icons.person,
                selected: selectedIndex == 4,
                onPressed: () => onItemTapped(4),
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  const IconBottomBar({
    Key? key,
    required this.icon,
    required this.selected,
    required this.onPressed,
    required this.primaryColor,
  }) : super(key: key);

  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 25,
        color: selected ? primaryColor : Colors.black54,
      ),
    );
  }
}

class IconBottomBar2 extends StatelessWidget {
  const IconBottomBar2({
    Key? key,
    required this.icon,
    required this.selected,
    required this.onPressed,
    required this.primaryColor,
  }) : super(key: key);

  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: primaryColor,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> _categoryIds = {
    'Sapi': 8,
    'Kambing': 9,
    'Ayam': 1,
    'Ikan': 3,
    'Bebek': 2,
    'Pakan': 25,
    'Kandang': 26,
    'Lainnya': 27,
  };

  Map<String, int> _typeIds = {
    'Ayam': 1,
    'Bebek': 2,
    'Angsa': 3,
    'Puyuh': 4,
    'Kalkun': 5,
    'Merpati': 6,
    'Lainnya': 7,
    'Sapi': 8,
    'Kambing': 9,
    'Domba': 10,
    'Kelinci': 11,
    'Babi': 12,
    'Kerbau': 13,
    'Kuda': 14,
    'Lainnya': 15,
    'Ikan Lele': 16,
    'Ikan Nila': 17,
    'Ikan Gurame': 18,
    'Ikan Patin': 19,
    'Ikan Mas': 20,
    'Ikan Bawal': 21,
    'Udang': 22,
    'Lobster': 23,
    'Lainnya': 24,
    'Pakan Ternak': 25,
    'Kandang': 26,
    'Alat Peternakan': 27,
    'Vitamin dan Obat-obatan': 28,
    'Lainnya': 29,
  };

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<String> _fetchSellerAddress(String sellerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return userDoc['address'] ?? '';
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  String _formatPrice(String price) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(double.tryParse(price) ?? 0);
  }

  Future<String> _fetchSellerUsername(String sellerId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return userDoc['username'] ?? '';
  }

  Future<List<QueryDocumentSnapshot>> _fetchProducts() async {
    Query query = FirebaseFirestore.instance.collection('products');
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: _searchQuery + '\uf8ff');
    }
    query = query.orderBy('created_at', descending: true).limit(6);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgList = [
      'images/news_image.jpg',
      'images/news_image.jpg',
      'images/news_image.jpg',
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            backgroundImage:
                                AssetImage('images/user_profil.png'),
                            radius: 24.0,
                          );
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const CircleAvatar(
                            backgroundImage:
                                AssetImage('images/user_profil.png'),
                            radius: 24.0,
                          );
                        } else {
                          var userData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          return CircleAvatar(
                            backgroundImage: NetworkImage(
                                userData?['profile_picture'] ??
                                    'images/user_profil.png'),
                            radius: 24.0,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: SizedBox(
                        height: 50.0,
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (query) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SearchResultsScreen(searchQuery: query),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Pencarian',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyCartScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color.fromARGB(255, 252, 93, 0)),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Memuat lokasi...');
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const Text('Lokasi tidak tersedia');
                        } else {
                          var userData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          return Flexible(
                            child: Text(
                              userData?['address'] ?? 'Lokasi tidak tersedia',
                              overflow: TextOverflow.visible,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _categoryIds.keys.map((String category) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            category: category,
                            categoryId: _categoryIds[category]!,
                          ),
                        ),
                      );
                    },
                    child: _CategoryIcon(
                      iconData: _getCategoryIcon(category),
                      label: category,
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tersedia Space Iklan !!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                      ),
                      items: imgList
                          .map((item) => Container(
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Image.asset(item, fit: BoxFit.cover),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Produk terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllProductsScreen()),
                        );
                      },
                      child: const Text(
                        'Produk Lainnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child:
                            Text('Error loading products: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  final products = snapshot.data!;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            return const Center(
                                child: CircularProgressIndicator());
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
              )
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sapi':
        return FontAwesomeIcons.cow;
      case 'Kambing':
        return FontAwesomeIcons.hippo;
      case 'Ayam':
        return FontAwesomeIcons.dove;
      case 'Ikan':
        return FontAwesomeIcons.fish;
      case 'Bebek':
        return FontAwesomeIcons.baby;
      case 'Pakan':
        return FontAwesomeIcons.seedling;
      case 'Kandang':
        return FontAwesomeIcons.warehouse;
      case 'Lainnya':
        return FontAwesomeIcons.ellipsisH;
      default:
        return FontAwesomeIcons.questionCircle;
    }
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

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({Key? key, required this.iconData, required this.label})
      : super(key: key);

  final IconData iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      // color: Colors.greenAccent,
      child: Column(
        children: [
          FaIcon(iconData, size: 30, color: const Color(0xFF2D4739)),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
