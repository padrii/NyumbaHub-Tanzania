import 'package:flutter/material.dart';

import '../models/models.dart';

class PropertyCard extends StatelessWidget {
  final PropertyListing listing;
  const PropertyCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (listing.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(listing.imageUrls.first, width: 90, height: 90, fit: BoxFit.cover),
              )
            else
              const SizedBox(width: 90, height: 90, child: Icon(Icons.home, size: 40)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(listing.locationName),
                  const SizedBox(height: 8),
                  Text('${listing.price.toStringAsFixed(0)} TZS'),
                  if (listing.isVerified)
                    const Text('✓ Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
