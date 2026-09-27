import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final String landlordId;
  const AddPropertyScreen({super.key, required this.landlordId});
  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final propertyService = PropertyService();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final amenitiesController = TextEditingController();
  
  List<File> selectedImages = [];
  File? selectedVideo;
  double? gpsLat, gpsLng;
  bool loading = false;

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    setState(() {
      selectedImages.addAll(images.map((i) => File(i.path)));
    });
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => selectedVideo = File(video.path));
  }

  Future<void> getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        gpsLat = position.latitude;
        gpsLng = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS ilisalia')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || priceController.text.isEmpty || selectedImages.isEmpty || selectedVideo == null || gpsLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jaza sehemu zote: Picha 5+, video, na GPS')));
      return;
    }
    if (selectedImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lazima kuwe na picha 5 angalau')));
      return;
    }
    setState(() => loading = true);
    try {
      final listing = PropertyListing(
        id: '',
        ownerId: widget.landlordId,
        title: titleController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        locationName: locationController.text,
        gpsLat: gpsLat!,
        gpsLng: gpsLng!,
        imageUrls: [],
        videoUrl: null,
        amenities: amenitiesController.text.split(',').map((a) => a.trim()).toList(),
        isVerified: false,
        verificationStatus: 'pending',
        createdAt: DateTime.now(),
      );
      final listingId = await propertyService.createListing(listing);
      List<String> imageUrls = [];
      for (final image in selectedImages) {
        final url = await propertyService.uploadImage(listingId, image.path);
        imageUrls.add(url);
      }
      final videoUrl = await propertyService.uploadVideo(listingId, selectedVideo!.path);
      final updatedListing = listing.copyWith(imageUrls: imageUrls, videoUrl: videoUrl);
      await propertyService.updateListing(listingId, updatedListing);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nyumba imeongezwa kwa kusubiri uthibitisho')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
          TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bei (TZS)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Mahali (jina)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: amenitiesController, decoration: const InputDecoration(labelText: 'Huduma (koma-koma)', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: getLocation, child: Text(gpsLat == null ? 'Pata GPS' : 'GPS: $gpsLat, $gpsLng')),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => pickImages(), child: Text('Picha (${selectedImages.length})')),
          if (selectedImages.isNotEmpty)
            SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: selectedImages.length, itemBuilder: (_, i) => Image.file(selectedImages[i], width: 100, height: 100, fit: BoxFit.cover))),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => pickVideo(), child: Text(selectedVideo == null ? 'Video' : 'Video: iliyochaguliwa')),
          const SizedBox(height: 24),
          FilledButton(onPressed: loading ? null : () => submit(), child: loading ? const CircularProgressIndicator() : const Text('Weka nyumba')),
        ],
      ),
    ),
  );
}

extension PropertyListingCopy on PropertyListing {
  PropertyListing copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    double? price,
    String? locationName,
    double? gpsLat,
    double? gpsLng,
    List<String>? imageUrls,
    String? videoUrl,
    List<String>? amenities,
    bool? isVerified,
    String? verificationStatus,
    DateTime? createdAt,
  }) => PropertyListing(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    locationName: locationName ?? this.locationName,
    gpsLat: gpsLat ?? this.gpsLat,
    gpsLng: gpsLng ?? this.gpsLng,
    imageUrls: imageUrls ?? this.imageUrls,
    videoUrl: videoUrl ?? this.videoUrl,
    amenities: amenities ?? this.amenities,
    isVerified: isVerified ?? this.isVerified,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    createdAt: createdAt ?? this.createdAt,
  );
}
