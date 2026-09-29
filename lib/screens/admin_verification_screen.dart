import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class AdminVerificationScreen extends StatefulWidget {
  final AppUser user;
  const AdminVerificationScreen({super.key, required this.user});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Verification'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Listings'),
              Tab(text: 'Services'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final item = users[index];
                    final role = item['role'] ?? 'tenant';
                    final isVerified = item['is_verified'] ?? false;
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(item['name'] ?? 'Unknown user'),
                        subtitle: Text('$role • ${isVerified ? 'Verified' : 'Pending'}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'verify', child: Text('Verify')),
                            PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) async {
                            if (value == 'verify') {
                              await firestore.collection('users').doc(item.id).update({'is_verified': true});
                            } else if (value == 'suspend') {
                              await firestore.collection('users').doc(item.id).update({'is_verified': false});
                            } else if (value == 'delete') {
                              await firestore.collection('users').doc(item.id).delete();
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('listings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final listings = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final item = listings[index];
                    final status = item['verification_status'] ?? 'pending';
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(item['title'] ?? 'Untitled listing'),
                        subtitle: Text('Status: $status'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'approve', child: Text('Approve')),
                            PopupMenuItem(value: 'reject', child: Text('Reject')),
                          ],
                          onSelected: (value) async {
                            if (value == 'approve') {
                              await firestore.collection('listings').doc(item.id).update({
                                'verification_status': 'approved',
                                'is_verified': true,
                              });
                            } else {
                              await firestore.collection('listings').doc(item.id).update({
                                'verification_status': 'rejected',
                                'is_verified': false,
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final services = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final item = services[index];
                    final status = item['is_verified'] == true ? 'Verified' : 'Pending';
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(item['title'] ?? 'Untitled service'),
                        subtitle: Text('Status: $status'),
                        trailing: PopupMenuButton(
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'approve', child: Text('Verify')),
                            PopupMenuItem(value: 'reject', child: Text('Reject')),
                          ],
                          onSelected: (value) async {
                            if (value == 'approve') {
                              await firestore.collection('services').doc(item.id).update({'is_verified': true});
                            } else {
                              await firestore.collection('services').doc(item.id).delete();
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
