import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jogfarmv1/model/products.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _stockController = TextEditingController();
  final _locationController = TextEditingController();
  final List<File> _newImages = [];
  late List<String> _existingImages;
  String? _selectedUnit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _descriptionController.text = widget.product.description;
    _weightController.text = widget.product.weight.toString();
    _ageController.text = widget.product.age.toString();
    _stockController.text = widget.product.stock.toString();
    _locationController.text = widget.product.location;
    _existingImages = List<String>.from(widget.product.images);
    _selectedUnit = widget.product.typeId == 1 ? 'ekor' : 'kg';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        List<String> imageUrls = List<String>.from(_existingImages);
        for (File image in _newImages) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');
          await storageRef.putFile(image);
          String downloadUrl = await storageRef.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        Product updatedProduct = Product(
          userId: widget.product.userId,
          userName: widget.product.userName,
          productId: widget.product.productId,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          weight: double.parse(_weightController.text),
          age: int.parse(_ageController.text),
          stock: int.parse(_stockController.text),
          location: _locationController.text,
          latitude: widget.product.latitude,
          longitude: widget.product.longitude,
          categoryId: widget.product.categoryId,
          typeId: _selectedUnit == 'ekor' ? 1 : 2,
          isActive: widget.product.isActive,
          createdAt: widget.product.createdAt,
          unitId: widget.product.unitId,
          images: imageUrls,
        );

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product.productId)
            .update(updatedProduct.toMap());

        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sukses'),
              content: Text('Produk berhasil diperbarui.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Go back to the previous screen
                  },
                ),
              ],
            );
          },
        );

      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Iklan'),
        backgroundColor: Color(0xFF2D4739),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    'Foto Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingImages.length + _newImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _existingImages.length) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(_existingImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _existingImages.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (index < _existingImages.length + _newImages.length) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(_newImages[index - _existingImages.length]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _newImages.removeAt(index - _existingImages.length);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              color: Colors.grey[300],
                              child: Icon(Icons.add_a_photo, color: Colors.grey[800]),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nama Produk'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama produk';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    items: ['ekor', 'kg'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Satuan'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Harga hewan per satuan'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan harga produk';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Deskripsi Produk'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan deskripsi produk';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(labelText: 'Berat Produk (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan berat produk';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: 'Usia Hewan (bulan)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan usia hewan';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(labelText: 'Stok (angka)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan stok produk';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Lokasi'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan lokasi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProduct,
                    child: Text('Simpan Perubahan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2D4739),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
