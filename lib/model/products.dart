class Product {
  final String userId;
  final String userName; // Tambahkan ini
  final String productId;
  final String name;
  final String description;
  final double price;
  final double weight;
  final int age;
  final int stock;
  final String location;
  final double latitude;
  final double longitude;
  final int categoryId;
  final int typeId;
  final bool isActive;
  final DateTime createdAt;
  final int unitId;
  final String? unit;
  final List<String> images;

  Product({
    required this.userId,
    required this.userName, // Tambahkan ini
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.weight,
    required this.age,
    required this.stock,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.typeId,
    required this.isActive,
    required this.createdAt,
    required this.unitId,
    required this.unit,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName, // Tambahkan ini
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'weight': weight,
      'age': age,
      'stock': stock,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category_id': categoryId,
      'type_id': typeId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'unit_id': unitId,
      'unit': unit,
      'images': images,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      userId: map['user_id'],
      userName: map['user_name'], // Tambahkan ini
      productId: map['product_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      weight: map['weight'],
      age: map['age'],
      stock: map['stock'],
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      categoryId: map['category_id'],
      typeId: map['type_id'],
      isActive: map['is_active'],
      createdAt: DateTime.parse(map['created_at']),
      unitId: map['unit_id'],
      unit: map['unit'],
      images: List<String>.from(map['images']),
    );
  }
}
