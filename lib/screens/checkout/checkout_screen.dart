import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jogfarmv1/model/cart.dart';
import 'package:jogfarmv1/model/order.dart';
import 'package:jogfarmv1/screens/checkout/order_screen.dart';
import 'package:jogfarmv1/screens/maps_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Cart> cartItems;

  CheckoutScreen({required this.cartItems});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'Silahkan pilih lokasi pengiriman';
  LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems
        .fold(0, (sum, item) => sum + item.priceProduct * item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D4739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressSection(),
              const SizedBox(height: 16),
              _buildCartItemsSection(),
              const SizedBox(height: 16),
              _buildTotalPriceSection(totalPrice),
              const SizedBox(height: 16),
              _buildPlaceOrderButton(totalPrice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Card(
      child: InkWell(
        onTap: () async {
          if (await Permission.location.request().isGranted) {
            LatLng result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
            if (result != null) {
              setState(() {
                _selectedLatLng = result;
              });
              await _getAddressFromLatLng(result);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Izin lokasi tidak diberikan')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.location_on, size: 40, color: Color(0xFF2D4739)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Alamat Pengiriman:\n$_selectedAddress',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Color(0xFF2D4739)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _selectedAddress =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildCartItemsSection() {
    return Column(
      children: widget.cartItems.map((cartItem) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(cartItem.imageProduct,
                        width: 80, height: 80, fit: BoxFit.cover),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cartItem.productName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp. ${cartItem.priceProduct} / ekor',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.green)),
                          Text('${cartItem.quantity} x',
                              style: const TextStyle(fontSize: 16)),
                          Text(
                              'Rp. ${cartItem.priceProduct * cartItem.quantity}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalPriceSection(double totalPrice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Rp. $totalPrice',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(double totalPrice) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null &&
              _selectedLatLng != null &&
              _selectedAddress.isNotEmpty) {
            for (Cart item in widget.cartItems) {
              String orderId = Uuid().v4();
              OrderModel order = OrderModel(
                orderId: orderId,
                sellerName: item.sellerName,
                productName: item.productName,
                productImage: item.imageProduct,
                price: item.priceProduct.toString(),
                quantity: item.quantity,
                status: 'Aktif',
                orderDate: DateTime.now(),
                buyerId: user.uid,
                sellerId: item.sellerId,
                address: _selectedAddress, // Tambahkan alamat
              );

              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .set(order.toMap());
            }

            // Setelah pesanan dibuat, navigasi ke halaman pesanan
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrdersScreen()),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produk berhasil dibeli')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Silakan pilih alamat pengiriman')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D4739),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: const Text('Buat Pesanan',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
