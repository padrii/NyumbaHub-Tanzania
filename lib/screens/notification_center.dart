import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationCenter extends StatelessWidget {
  final String userId;
  const NotificationCenter({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!.docs;
          if (items.isEmpty) return const Center(child: Text('No notifications yet'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item['message'] ?? 'Notification'),
                  subtitle: Text((item['created_at'] as Timestamp?)?.toDate().toIso8601String() ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
