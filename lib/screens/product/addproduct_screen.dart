import 'package:flutter/material.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: const [
          CategoryItem(title: 'Terdekat'),
          CategoryItem(title: 'Big Deals'),
          CategoryItem(title: 'Populer'),
          CategoryItem(title: 'Unggas'),
          CategoryItem(title: 'Mamalia'),
          CategoryItem(title: 'Reptil'),
          CategoryItem(title: 'Ikan'),
          CategoryItem(title: 'Pakan'),
          CategoryItem(title: 'Kandang'),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;

  const CategoryItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 92, 28),
            ),
          ),
          onTap: () {
            // Handle tap action here if needed
          },
        ),
        const Divider(),
      ],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AddProductScreen(),
    );
  }
}
