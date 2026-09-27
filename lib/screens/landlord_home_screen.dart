import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import 'add_property_screen.dart';

class LandlordHomeScreen extends StatefulWidget {
  final AppUser user;
  const LandlordHomeScreen({super.key, required this.user});
  @override
  State<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends State<LandlordHomeScreen> {
  final propertyService = PropertyService();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nyumba Zangu')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddPropertyScreen(landlordId: widget.user.id))),
      child: const Icon(Icons.add),
    ),
    body: StreamBuilder(
      stream: propertyService.getUserListings(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Haina nyumba zilizowekwa'));
        }
        final listings = snapshot.data!;
        return ListView.builder(
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(listing.title),
                subtitle: Text('${listing.verificationStatus} • ${listing.price} TZS'),
                trailing: listing.isVerified ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending),
              ),
            );
          },
        );
      },
    ),
  );
}
