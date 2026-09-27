import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AppUser user;
  const AdminDashboardScreen({super.key, required this.user});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: const TabBar(tabs: [
          Tab(text: 'Users'),
          Tab(text: 'Listings'),
          Tab(text: 'Services'),
          Tab(text: 'Requests'),
        ]),
      ),
      body: TabBarView(
        children: [
          _UsersTab(firestore: firestore),
          _ListingsTab(firestore: firestore),
          _ServicesTab(firestore: firestore),
          _RequestsTab(firestore: firestore),
        ],
      ),
    ),
  );
}

class _UsersTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  const _UsersTab({required this.firestore});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: firestore.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final users = snapshot.data!.docs;
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text('${user['role']} • ${user['is_verified'] ? 'Verified' : 'Pending'}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Verify'),
                  onTap: () => firestore.collection('users').doc(user.id).update({'is_verified': true}),
                ),
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () => firestore.collection('users').doc(user.id).delete(),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ListingsTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  const _ListingsTab({required this.firestore});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: firestore.collection('listings').where('verification_status', isEqualTo: 'pending').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final listings = snapshot.data!.docs;
      return ListView.builder(
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return ListTile(
            title: Text(listing['title'] ?? 'Unknown'),
            subtitle: Text(listing['location_name'] ?? 'No location'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Approve'),
                  onTap: () => firestore.collection('listings').doc(listing.id).update({'is_verified': true, 'verification_status': 'approved'}),
                ),
                PopupMenuItem(
                  child: const Text('Reject'),
                  onTap: () => firestore.collection('listings').doc(listing.id).update({'verification_status': 'rejected'}),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ServicesTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  const _ServicesTab({required this.firestore});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: firestore.collection('services').where('is_verified', isEqualTo: false).snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final services = snapshot.data!.docs;
      return ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            title: Text(service['title'] ?? 'Unknown'),
            subtitle: Text(service['category'] ?? 'No category'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Verify'),
                  onTap: () => firestore.collection('services').doc(service.id).update({'is_verified': true}),
                ),
                PopupMenuItem(
                  child: const Text('Reject'),
                  onTap: () => firestore.collection('services').doc(service.id).delete(),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _RequestsTab extends StatelessWidget {
  final FirebaseFirestore firestore;
  const _RequestsTab({required this.firestore});
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: firestore.collection('service_requests').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final requests = snapshot.data!.docs;
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return ListTile(
            title: Text('Request #${request.id.substring(0, 6)}'),
            subtitle: Text('Status: ${request['status']}'),
          );
        },
      );
    },
  );
}
