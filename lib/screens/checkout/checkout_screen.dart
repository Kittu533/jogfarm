import 'package:flutter/material.dart';
import 'package:jogfarmv1/model/cart.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Cart> cartItems;

  CheckoutScreen({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(0, (sum, item) => sum + item.priceProduct * item.quantity);

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: const [
            Icon(Icons.location_on, size: 40, color: Color(0xFF2D4739)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alamat Pengiriman:\nJl. Siliwangi, Jombor Lor, Sendangadi, Kec. Mlati, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55285',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: Color(0xFF2D4739)),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsSection() {
    return Column(
      children: cartItems.map((cartItem) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(cartItem.imageProduct, width: 80, height: 80, fit: BoxFit.cover),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cartItem.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp. ${cartItem.priceProduct} / ekor', style: const TextStyle(fontSize: 16, color: Colors.green)),
                          Text('${cartItem.quantity} x', style: const TextStyle(fontSize: 16)),
                          Text('Rp. ${cartItem.priceProduct * cartItem.quantity}', style: const TextStyle(fontSize: 16, color: Colors.green)),
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
            const Text('Total Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Rp. $totalPrice', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(double totalPrice) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle order placement logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D4739),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: const Text('Buat Pesanan', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
