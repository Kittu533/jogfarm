import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalPayment;

  const CheckoutScreen({Key? key, required this.cartItems, required this.totalPayment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_pin, color: Colors.black),
                title: const Text(
                  'Alamat Pengiriman:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Jl. Siliwangi, Jombor Lor, Sendangadi, Kec. Mlati, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55285',
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.asset(cartItems[index].imagePath), // Ganti dengan path gambar Anda
                          title: Text(cartItems[index].productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rp. ${cartItems[index].price.toString()} / ${cartItems[index].unit}'),
                              Text(cartItems[index].sellerName),
                              Text('x${cartItems[index].quantity}'),
                            ],
                          ),
                          trailing: Text(
                            'Rp. ${cartItems[index].totalPrice.toString()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Pesanan (${cartItems[index].quantity} hewan)',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp. ${cartItems[index].totalPrice.toString()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp. ${totalPayment.toString()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add your order submission logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      ),
                      child: const Text('Buat Pesanan'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final String productName;
  final double price;
  final int quantity;
  final String unit;
  final String sellerName;
  final String imagePath;
  final double totalPrice;

  CartItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.sellerName,
    required this.imagePath,
    required this.totalPrice,
  });
}
