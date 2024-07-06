import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/cart/cartpage_screen.dart';
import 'package:jogfarmv1/screens/product/addproduct_screen.dart';
import 'package:jogfarmv1/screens/chat/chatall_screen.dart';
import 'package:jogfarmv1/screens/product/myproduct_screen.dart';
import 'package:jogfarmv1/screens/product/detailproduct_screen.dart';
import 'package:jogfarmv1/screens/product/uploadproduct_screen.dart';
import 'package:jogfarmv1/screens/setting_screen.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart';
import 'package:jogfarmv1/widgets/location_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _showLoginPopup = false;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    const ChatAllScreen(),
    UploadProductScreen(),
    const MyProductScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) {
      setState(() {
        _showLoginPopup = true;
      });
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Tambah',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Produk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: const Color(0xFF2D4739), // Warna hijau sesuai gambar
          onTap: _onItemTapped,
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
  Future<String> _fetchSellerAddress(String sellerId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
    return userDoc['address'] ?? '';
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage(
                      'images/user_profil.png'), // Ubah jalur sesuai dengan gambar profil Anda
                  radius: 24.0,
                ),
                const SizedBox(width: 16),
                Expanded(
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
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.shopping_cart,
                      color: Colors.white), // Ikon keranjang belanja
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
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Location(),
              ),
              const SizedBox(height: 4),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _CategoryIcon(iconData: Icons.location_on, label: 'Terdekat'),
                  _CategoryIcon(iconData: Icons.local_offer, label: 'Big Deals'),
                  _CategoryIcon(iconData: Icons.favorite, label: 'Populer'),
                  _CategoryIcon(iconData: Icons.pets, label: 'Unggas'),
                  _CategoryIcon(iconData: Icons.agriculture, label: 'Mamalia'),
                  _CategoryIcon(iconData: Icons.grass, label: 'Pakan'),
                  _CategoryIcon(iconData: Icons.home, label: 'Kandang'),
                  _CategoryIcon(iconData: Icons.more_horiz, label: 'Lainnya'),
                ],
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
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('images/news_image.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Jelajah UMKM: Poktan Mutiara Indah Terapkan Tiga Pola Kunci Keberhasilan Ternak Sapi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produk terbaru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .orderBy('created_at', descending: true)
                          .limit(6)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading products'));
                        }

                        final products = snapshot.data!.docs;

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
                              future: _fetchSellerAddress(product['user_id']),
                              builder: (context, addressSnapshot) {
                                if (addressSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (addressSnapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading address'));
                                }

                                final sellerAddress = addressSnapshot.data ?? '';

                                return _buildProductCard(
                                  context,
                                  product.id, // Pass the actual product ID
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
                                  product['user_name'], // Pass the userName
                                  sellerAddress, // Pass the sellerAddress
                                  product['user_id'], // Pass the userId for fetching other products
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productId, // Add this parameter
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
    double weight, // Add this parameter
    int age, // Add this parameter
    int stock, // Add this parameter
    String userName, // Change this parameter
    String sellerAddress, // Add this parameter
    String userId, // Add this parameter for fetching other products
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: productId, // Pass the actual product ID
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
              weight: weight, // Pass the parameter
              age: age, // Pass the parameter
              stock: stock, // Pass the parameter
              sellerName: userName, // Pass the userName as sellerName
              sellerAddress: sellerAddress, // Pass the sellerAddress
              sellerId: userId, // Pass the userId for fetching other products
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
                    'Rp. $price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(name),
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
      color: Colors.greenAccent,
      child: Column(
        children: [
          Icon(iconData,
              size: 30, color: const Color.fromARGB(255, 23, 92, 28)),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
