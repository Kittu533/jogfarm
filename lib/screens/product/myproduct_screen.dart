import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jogfarmv1/model/order.dart';
import 'package:jogfarmv1/model/products.dart';
import 'package:jogfarmv1/screens/product/editmyproduct_screen.dart';
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
            width: 200,
            height: 200,
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

  Future<void> _updateOrderStatus(
      BuildContext context, String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
    _showOrderStatusUpdateAnimation(context, status);
  }

  void _showOrderStatusUpdateAnimation(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status Pesanan Diperbarui'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              status == 'accepted'
                  ? 'assets/animations/success.json'
                  : status == 'delivered'
                      ? 'assets/animations/delivered.json'
                      : 'assets/animations/cancelled.json',
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

  void _showOrderCancelledSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pesanan berhasil dibatalkan'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Stream<List<OrderModel>> getSellerOrders() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          title: const Text(
            'Iklan Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: 4.0, color: Color.fromARGB(255, 0, 255, 13)),
              insets: EdgeInsets.symmetric(horizontal: 50.0),
            ),
            unselectedLabelColor: Colors.grey,
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
            _buildOrdersTab(context, 'Aktif'), // Pesanan
            _buildOrdersTab(context, 'Diantar'), // Diantar
            _buildOrdersTab(context, 'Dibatalkan'), // Dibatalkan
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
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                product.images.isNotEmpty
                                    ? product.images[0]
                                    : 'images/default_product.png',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditProductScreen(product: product)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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

  Widget _buildOrdersTab(BuildContext context, String orderStatus) {
    return StreamBuilder<List<OrderModel>>(
      stream: getSellerOrders().map(
        (orders) =>
            orders.where((order) => order.status == orderStatus).toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada pesanan'));
        }
        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            if (orderStatus == 'Aktif') {
              return _buildActiveOrderItem(context, order);
            } else if (orderStatus == 'Diantar') {
              return _buildDeliveredOrderItem(context, order);
            } else if (orderStatus == 'Dibatalkan') {
              return _buildCancelledOrderItem(context, order);
            }
            return Container();
          },
        );
      },
    );
  }

  Widget _buildActiveOrderItem(BuildContext context, OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Image.network(
                order.productImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(order.buyerId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.orderId}'),
                  Text('Alamat: ${order.address}'),
                  Text('Total Pesanan: Rp${order.price}'),
                  Text('Status: ${order.status}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(context, order.orderId, 'Diantar');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Antar Pesanan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(context, order.orderId, 'Dibatalkan');
                    _showOrderCancelledSnackbar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Tolak Pesanan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(context, order.orderId, 'accepted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Terima Pesanan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveredOrderItem(BuildContext context, OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Image.network(
                order.productImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(order.buyerId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.orderId}'),
                  Text('Alamat: ${order.address}'),
                  Text('Total Pesanan: Rp${order.price}'),
                  Text('Status: ${order.status}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.local_shipping, color: Colors.green),
                Text(
                  'Pesanan Diterima',
                  style: TextStyle(color: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(context, order.orderId, 'Dibatalkan');
                    _showOrderCancelledSnackbar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Batalkan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledOrderItem(BuildContext context, OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Image.network(
                order.productImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(order.buyerId),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.orderId}'),
                  Text('Alamat: ${order.address}'),
                  Text('Total Pesanan: Rp${order.price}'),
                  Text('Status: ${order.status}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.cancel, color: Colors.red),
                Text(
                  'Pesanan Dibatalkan',
                  style: TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(context, order.orderId, 'accepted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Terima Pesanan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
