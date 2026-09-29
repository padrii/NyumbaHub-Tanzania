import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../models/models.dart';
import '../services/firebase_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final AppUser user;
  const AddPropertyScreen({super.key, required this.user});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationNameController = TextEditingController();
  final amenitiesController = TextEditingController();

  final PropertyService propertyService = PropertyService();
  final ImagePicker picker = ImagePicker();

  List<File> selectedImages = [];
  File? selectedVideo;
  double? gpsLat;
  double? gpsLng;
  bool loading = false;

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      selectedImages = picked.map((x) => File(x.path)).toList();
    });
  }

  Future<void> pickVideo() async {
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    setState(() => selectedVideo = File(video.path));
  }

  Future<void> captureLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tafadhali wezesha GPS')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruhusa ya GPS imekataliwa')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruhusa ya GPS inahitaji kuanzishwa kwenye setting')));
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      gpsLat = pos.latitude;
      gpsLng = pos.longitude;
    });
  }

  Future<void> submitListing() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || priceController.text.isEmpty || locationNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jaza taarifa zote za nyumba')));
      return;
    }
    if (selectedImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lazima uwe na picha 5 angalau')));
      return;
    }
    if (selectedVideo == null || gpsLat == null || gpsLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS na video ni lazima')));
      return;
    }

    setState(() => loading = true);

    try {
      final listing = PropertyListing(
        id: '',
        ownerId: widget.user.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0,
        locationName: locationNameController.text.trim(),
        gpsLat: gpsLat!,
        gpsLng: gpsLng!,
        imageUrls: [],
        videoUrl: null,
        amenities: amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        isVerified: false,
        verificationStatus: 'pending',
        createdAt: DateTime.now(),
      );

      final listingId = await propertyService.createListing(listing);

      final uploadedImages = <String>[];
      for (final image in selectedImages) {
        final url = await propertyService.uploadImage(listingId, image.path);
        uploadedImages.add(url);
      }

      final videoUrl = await propertyService.uploadVideo(listingId, selectedVideo!.path);

      final updated = listing.copyWith(
        id: listingId,
        imageUrls: uploadedImages,
        videoUrl: videoUrl,
      );

      await propertyService.updateListing(listingId, updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nyumba imetumwa kwa admin kuthibitishwa')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ongeza Nyumba')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Jina la nyumba', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'Maelezo', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bei (Tsh)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: locationNameController, decoration: const InputDecoration(labelText: 'Jina la eneo', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: amenitiesController, decoration: const InputDecoration(labelText: 'Amenities (kama: WiFi, Parking, Water)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: captureLocation, icon: const Icon(Icons.location_on), label: Text(gpsLat == null ? 'Pata GPS' : 'GPS: ${gpsLat!.toStringAsFixed(4)}, ${gpsLng!.toStringAsFixed(4)}')),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: pickImages, icon: const Icon(Icons.photo_library), label: Text('Picha (${selectedImages.length})')),
            const SizedBox(height: 12),
            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: pickVideo, icon: const Icon(Icons.video_library), label: Text(selectedVideo == null ? 'Pakia Video' : 'Video imechaguliwa')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: loading ? null : submitListing,
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Tuma kwa Admin kuthibitisha'),
            ),
          ],
        ),
      ),
    );
  }
}
