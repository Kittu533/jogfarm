class OrderModel {
  final String orderId;
  final String sellerName;
  final String productName;
  final String productImage;
  final String price;
  final int quantity;
  final String status;
  final DateTime orderDate;
  final String buyerId;
  final String sellerId;
  final String address; // Tambahkan alamat

  OrderModel({
    required this.orderId,
    required this.sellerName,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.status,
    required this.orderDate,
    required this.buyerId,
    required this.sellerId,
    required this.address, // Tambahkan alamat
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'sellerName': sellerName,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'buyerId': buyerId,
      'sellerId': sellerId,
      'address': address, // Tambahkan alamat
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      sellerName: map['sellerName'],
      productName: map['productName'],
      productImage: map['productImage'],
      price: map['price'],
      quantity: map['quantity'],
      status: map['status'],
      orderDate: DateTime.parse(map['orderDate']),
      buyerId: map['buyerId'],
      sellerId: map['sellerId'] ?? '',
      address: map['address'] ?? '', // Tambahkan alamat dan pengecekan null
    );
  }
}
