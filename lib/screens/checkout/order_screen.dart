import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jogfarmv1/model/order.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D4739),
        title: Text(
          'Pesanan saya',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxHeight: 150.0),
              child: Material(
                color: Color(0xFF2D4739),
                child: TabBar(
                  labelColor: Colors.white, // Warna teks tab yang dipilih
                  unselectedLabelColor:
                      Colors.white70, // Warna teks tab yang tidak dipilih
                  indicatorColor: Colors.white, // Warna indikator tab
                  tabs: [
                    Tab(text: 'Aktif'),
                    Tab(text: 'Selesai'),
                    Tab(text: 'Dibatalkan'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OrderList(status: 'Aktif', userId: user!.uid),
                  OrderList(status: 'Selesai', userId: user!.uid),
                  OrderList(status: 'Dibatalkan', userId: user!.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final String status;
  final String userId;

  OrderList({required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<OrderModel> orders = snapshot.data!.docs
            .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.sellerName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'tanggal : ${order.orderDate.day} ${order.orderDate.month} ${order.orderDate.year}')
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Image.network(order.productImage,
                    width: 80, height: 80, fit: BoxFit.cover),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${order.price} / ekor'),
                      Text(
                          'Total Pesanan: Rp. ${(double.parse(order.price) * order.quantity).toString()}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: order.status == 'Aktif'
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(order.status,
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2D4739)),
                      child: Text(
                        'Beli lagi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
