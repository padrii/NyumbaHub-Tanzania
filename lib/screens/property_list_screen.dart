import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class PropertyListScreen extends StatefulWidget {
  final AppUser user;
  const PropertyListScreen({super.key, required this.user});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nyumba Zinazopatikana')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('listings')
            .where('is_verified', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Hakuna nyumba zilizo verified kwa sasa'));
          }

          final listings = snapshot.data!.docs
              .map((doc) => PropertyListing.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: listing.imageUrls.isNotEmpty
                      ? Image.network(listing.imageUrls.first, width: 80, height: 90, fit: BoxFit.cover)
                      : const Icon(Icons.home, size: 42),
                  title: Text(listing.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${listing.locationName}'),
                      Text('${listing.price.toStringAsFixed(0)} TZS/month'),
                      const SizedBox(height: 6),
                      Text(listing.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(listing: listing, user: widget.user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PropertyDetailScreen extends StatelessWidget {
  final AppUser user;
  final PropertyListing listing;

  const PropertyDetailScreen({super.key, required this.user, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.imageUrls.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView(
                  children: listing.imageUrls
                      .map((url) => Image.network(url, fit: BoxFit.cover))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${listing.price.toStringAsFixed(0)} TZS', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (listing.isVerified) const Icon(Icons.verified, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Text(listing.locationName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(listing.description),
            const SizedBox(height: 16),
            const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: listing.amenities.map((item) => Chip(label: Text(item))).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request imetumwa kwa landlord')),
                  );
                },
                child: const Text('Book Viewing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
