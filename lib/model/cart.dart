class Cart {
  final String cartId;
  final String userId;
  final double priceProduct;
  final String locationProduct;
  final String sellerName;
  final String productName;
  final String imageProduct;
  int quantity;
  final DateTime addedAt;
  final String productId;
  final String sellerId;  // Tambahkan sellerId

  Cart({
    required this.cartId,
    required this.userId,
    required this.priceProduct,
    required this.locationProduct,
    required this.sellerName,
    required this.productName,
    required this.imageProduct,
    required this.quantity,
    required this.addedAt,
    required this.productId,
    required this.sellerId,  // Tambahkan sellerId
  });

  Map<String, dynamic> toMap() {
    return {
      'cart_id': cartId,
      'user_id': userId,
      'price_product': priceProduct,
      'location_product': locationProduct,
      'seller_name': sellerName,
      'product_name': productName,
      'image_product': imageProduct,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
      'product_id': productId,
      'seller_id': sellerId,  // Tambahkan sellerId
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      cartId: map['cart_id'],
      userId: map['user_id'],
      priceProduct: map['price_product'],
      locationProduct: map['location_product'],
      sellerName: map['seller_name'],
      productName: map['product_name'],
      imageProduct: map['image_product'],
      quantity: map['quantity'],
      addedAt: DateTime.parse(map['added_at']),
      productId: map['product_id'],
      sellerId: map['seller_id'],  // Tambahkan sellerId
    );
  }
}
