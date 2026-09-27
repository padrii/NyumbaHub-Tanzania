import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class TenantHomeScreen extends StatefulWidget {
  final AppUser user;
  const TenantHomeScreen({super.key, required this.user});
  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final propertyService = PropertyService();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tafuta Nyumba')),
    body: StreamBuilder<List<PropertyListing>>(
      stream: propertyService.getVerifiedListings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Hakuna nyumba zilizothibitishwa'));
        }
        final listings = snapshot.data!;
        return ListView.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: listing.imageUrls.isNotEmpty
                    ? Image.network(listing.imageUrls.first, width: 80, height: 80, fit: BoxFit.cover)
                    : const Icon(Icons.home),
                title: Text(listing.title),
                subtitle: Text('${listing.price.toStringAsFixed(0)} TZS'),
                trailing: listing.isVerified ? const Icon(Icons.verified, color: Colors.green) : null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(listing: listing))),
              ),
            );
          },
        );
      },
    ),
  );
}

class PropertyDetailScreen extends StatelessWidget {
  final PropertyListing listing;
  const PropertyDetailScreen({super.key, required this.listing});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(listing.title)),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listing.imageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView(
                children: listing.imageUrls.map((url) => Image.network(url, fit: BoxFit.cover)).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${listing.price.toStringAsFixed(0)} TZS', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    if (listing.isVerified) const Chip(label: Text('✓ Imethithitishwa'), backgroundColor: Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Mahali: ${listing.locationName}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Maelezo: ${listing.description}'),
                const SizedBox(height: 16),
                if (listing.amenities.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Huduma:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: listing.amenities.map((a) => Chip(label: Text(a))).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: () {}, child: const Text('Book Viewing')),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
