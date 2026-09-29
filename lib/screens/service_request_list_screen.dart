import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class ServiceRequestListScreen extends StatelessWidget {
  final AppUser user;
  const ServiceRequestListScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .where('provider_id', isEqualTo: user.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Hakuna service requests'));
          }

          final requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(item['status'] ?? 'pending'),
                  subtitle: Text('Tenant: ${item['tenant_id']}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'accepted', child: Text('Accept')),
                      PopupMenuItem(value: 'rejected', child: Text('Reject')),
                    ],
                    onSelected: (value) {
                      FirebaseFirestore.instance.collection('service_requests').doc(item.id).update({'status': value});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
