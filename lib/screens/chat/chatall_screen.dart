import 'package:flutter/material.dart';

class ChatAllScreen extends StatelessWidget {
  const ChatAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D4739),
          
         title: const Text(
          'CHAT',
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold), // Ubah warna judul menjadi putih
        ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18.0,
                child: const Icon(Icons.person, color: Color.fromARGB(255, 23, 92, 28)),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'SEMUA'),
              Tab(text: 'MEMBELI'),
              Tab(text: 'MENJUAL'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChatList(),
            Center(child: Text('MEMBELI')),
            Center(child: Text('MENJUAL')),
          ],
        ),
        
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ChatItem(name: 'UTY FARM', message: 'Lok mana gan??', time: '00:53', count: 1),
        ChatItem(name: 'Pardi', message: 'sapi metal ready mboten??', time: '01:45', count: 2),
        ChatItem(name: 'Jono', message: 'sapi metal ready mboten??', time: '06:30', count: 2),
        ChatItem(name: 'Lala', message: 'sapi metal ready mboten??', time: '09:00', count: 1),
        ChatItem(name: 'Ola', message: 'sapi metal ready mboten??', time: '12:13', count: 2),
        ChatItem(name: 'Kaka', message: 'sapi metal ready mboten??', time: '12:50', count: 1),
        ChatItem(name: 'Tono', message: 'sapi metal ready mboten??', time: '14:40', count: 3),
        ChatItem(name: 'Zaki', message: 'sapi metal ready mboten??', time: '15:33', count: 1),
      ],
    );
  }
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final int count;

  const ChatItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(name),
          subtitle: Text(message),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(time, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 23, 92, 28),
                radius: 10,
                child: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          onTap: () {
            // Handle chat item tap
          },
        ),
        const Divider(),
      ],
    );
  }
}

