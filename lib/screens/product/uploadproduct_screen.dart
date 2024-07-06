import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/product/addproduct_screen.dart';

class UploadProductScreen extends StatefulWidget {
  @override
  _UploadProductScreenState createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _type;

  static const Map<String, List<String>> _categories = {
    'UNGGAS': [
      'Ayam',
      'Bebek',
      'Angsa',
      'Puyuh',
      'Kalkun',
      'Merpati',
      'Lainnya'
    ],
    'MAMALIA': [
      'Sapi',
      'Kambing',
      'Domba',
      'Kelinci',
      'Babi',
      'Kerbau',
      'Kuda',
      'Lainnya'
    ],
    'HEWAN AKUATIK': [
      'Ikan Lele',
      'Ikan Nila',
      'Ikan Gurame',
      'Ikan Patin',
      'Ikan Mas',
      'Ikan Bawal',
      'Udang',
      'Lobster',
      'Lainnya'
    ],
    'PERLENGKAPAN': [
      'Pakan Ternak',
      'Kandang',
      'Alat Peternakan',
      'Vitamin dan Obat-obatan',
      'Lainnya'
    ],
  };

  List<String> _types = [];

  Map<String, int> _categoryIds = {
    'UNGGAS': 1,
    'MAMALIA': 2,
    'HEWAN AKUATIK': 3,
    'PERLENGKAPAN': 4,
  };

  Map<String, int> _typeIds = {
    'Ayam': 1,
    'Bebek': 2,
    'Angsa': 3,
    'Puyuh': 4,
    'Kalkun': 5,
    'Merpati': 6,
    'Lainnya': 7,
    'Sapi': 8,
    'Kambing': 9,
    'Domba': 10,
    'Kelinci': 11,
    'Babi': 12,
    'Kerbau': 13,
    'Kuda': 14,
    'Lainnya': 15,
    'Ikan Lele': 16,
    'Ikan Nila': 17,
    'Ikan Gurame': 18,
    'Ikan Patin': 19,
    'Ikan Mas': 20,
    'Ikan Bawal': 21,
    'Udang': 22,
    'Lobster': 23,
    'Lainnya': 24,
    'Pakan Ternak': 25,
    'Kandang': 26,
    'Alat Peternakan': 27,
    'Vitamin dan Obat-obatan': 28,
    'Lainnya': 29,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload produk',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D4739),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                    _types = _categories[value]!;
                    _type = null; // Reset the type when category changes
                  });
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                  hintText: 'Pilih',
                ),
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Jenis',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: _types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                  hintText: 'Pilih',
                ),
                validator: (value) => value == null ? 'Pilih jenis' : null,
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(
                            categoryId: _categoryIds[_category]!,
                            typeId: _typeIds[_type]!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4739),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
