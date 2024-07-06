import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogfarmv1/model/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCartScreen extends StatefulWidget {
  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  List<Cart> _cartItems = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('cart')
          .where('user_id', isEqualTo: userId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        List<Cart> fetchedItems = querySnapshot.docs.map((doc) {
          return Cart.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        
        setState(() {
          _cartItems = fetchedItems;
          _totalPrice = _cartItems.fold(
              0, (sum, item) => sum + item.priceProduct * item.quantity);
        });
      });
    }
  }

  void _incrementQuantity(Cart cartItem) {
    setState(() {
      cartItem.quantity++;
      _totalPrice += cartItem.priceProduct;
    });
    FirebaseFirestore.instance
        .collection('cart')
        .doc(cartItem.cartId)
        .update({'quantity': cartItem.quantity});
  }

  void _decrementQuantity(Cart cartItem) {
    if (cartItem.quantity > 1) {
      setState(() {
        cartItem.quantity--;
        _totalPrice -= cartItem.priceProduct;
      });
      FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItem.cartId)
          .update({'quantity': cartItem.quantity});
    } else {
      _showDeleteConfirmation(cartItem);
    }
  }

  void _removeCartItem(Cart cartItem) {
    setState(() {
      _cartItems.remove(cartItem);
      _totalPrice -= cartItem.priceProduct * cartItem.quantity;
    });

    FirebaseFirestore.instance.collection('cart').doc(cartItem.cartId).delete();
  }

  void _showDeleteConfirmation(Cart cartItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Produk'),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                _removeCartItem(cartItem);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkout() {
    // Implementasi checkout di sini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang Saya (${_cartItems.length})'),
        backgroundColor: const Color(0xFF2D4739),
      ),
      body: _cartItems.isEmpty
          ? Center(child: Text('Keranjang Anda kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      Cart cartItem = _cartItems[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0 ||
                              _cartItems[index - 1].sellerName != cartItem.sellerName)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.store),
                                  SizedBox(width: 8),
                                  Text(cartItem.sellerName),
                                ],
                              ),
                            ),
                          Card(
                            child: ListTile(
                              leading: Image.network(
                                cartItem.imageProduct,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(cartItem.productName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rp. ${cartItem.priceProduct} /ekor'),
                                  Text(cartItem.locationProduct),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () => _decrementQuantity(cartItem),
                                  ),
                                  Text('${cartItem.quantity}'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () => _incrementQuantity(cartItem),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _showDeleteConfirmation(cartItem),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 18)),
                      Text('Rp. $_totalPrice', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _checkout,
                    child: Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4739),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
