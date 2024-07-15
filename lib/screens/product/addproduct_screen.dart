import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jogfarmv1/model/products.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  final int categoryId;
  final int typeId;

  const AddProductScreen({
    required this.categoryId,
    required this.typeId,
    Key? key,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _stockController = TextEditingController();
  final _locationController = TextEditingController();
  final List<File> _images = [];
  bool _isLoading = false;
  String? _selectedUnit;
  String sellerUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchSellerUsername();
  }

  Future<void> _fetchSellerUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        sellerUsername = userDoc['username'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not logged in';

        List<String> imageUrls = [];
        for (File image in _images) {
          String fileName = Uuid().v4();
          Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName');
          await storageRef.putFile(image);
          String downloadUrl = await storageRef.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        Product product = Product(
          userId: user.uid,
          userName: sellerUsername,
          productId: Uuid().v4(),
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          weight: double.parse(_weightController.text),
          age: int.parse(_ageController.text),
          stock: int.parse(_stockController.text),
          location: _locationController.text,
          latitude: 0.0,
          longitude: 0.0,
          categoryId: widget.categoryId,
          typeId: widget.typeId,
          isActive: true,
          createdAt: DateTime.now(),
          unitId: _selectedUnit == 'ekor' ? 1 : 2,
          unit: _selectedUnit, // Save the selected unit
          images: imageUrls,
        );

        await FirebaseFirestore.instance.collection('products').doc(product.productId).set(product.toMap());

        setState(() {
          _isLoading = false;
        });

        _showSuccessModal(context);

      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        _showFailureModal(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please complete the form and select images')));
    }
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/success.json', height: 150),
                Text(
                  'Product Uploaded Successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailureModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/failure.json', height: 150),
                Text(
                  'Failed to Upload Product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unggah Produk'),
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
                      itemCount: _images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _images.length) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              color: Colors.grey[300],
                              child: Icon(Icons.add_a_photo, color: Colors.grey[800]),
                            ),
                          );
                        } else {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(_images[index]),
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
                                      _images.removeAt(index);
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
                    decoration: InputDecoration(
                      labelText: 'Lokasi',
                      hintText: 'kecamatan-kabupaten',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan lokasi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadProduct,
                    child: Text('Unggah Produk'),
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
