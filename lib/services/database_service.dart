import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogfarmv1/model/products.dart';
import 'package:jogfarmv1/model/users.dart';
import 'package:jogfarmv1/model/cart.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print(e);
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.productId).set(product.toMap());
  }

  Future<Product?> getProduct(String productId) async {
    DocumentSnapshot doc = await _db.collection('products').doc(productId).get();
    if (doc.exists) {
      return Product.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // Tambahkan ke keranjang
  Future<void> addToCart(Cart cart) async {
    try {
      await _firestore.collection('cart').add(cart.toMap());
    } catch (e) {
      print(e);
    }
  }

  // Perbarui jumlah item di keranjang
  Future<void> updateCartItemQuantity(String cartId, int quantity) async {
    try {
      await _firestore.collection('cart').doc(cartId).update({
        'quantity': quantity,
      });
    } catch (e) {
      print(e);
    }
  }

  // Hapus item dari keranjang
  Future<void> removeCartItem(String cartId) async {
    try {
      await _firestore.collection('cart').doc(cartId).delete();
    } catch (e) {
      print(e);
    }
  }
}
