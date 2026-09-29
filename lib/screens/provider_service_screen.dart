import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/firebase_service.dart';

class ProviderServiceScreen extends StatefulWidget {
  final AppUser user;
  const ProviderServiceScreen({super.key, required this.user});

  @override
  State<ProviderServiceScreen> createState() => _ProviderServiceScreenState();
}

class _ProviderServiceScreenState extends State<ProviderServiceScreen> {
  final categoryController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceFromController = TextEditingController();
  final priceToController = TextEditingController();
  final locationController = TextEditingController();

  final ServiceService serviceService = ServiceService();
  final ImagePicker picker = ImagePicker();
  List<File> selectedImages = [];
  bool loading = false;

  Future<void> pickImages() async {
    final result = await picker.pickMultiImage();
    if (result.isEmpty) return;
    setState(() => selectedImages = result.map((x) => File(x.path)).toList());
  }

  Future<void> submitService() async {
    if (categoryController.text.isEmpty || titleController.text.isEmpty || descriptionController.text.isEmpty || priceFromController.text.isEmpty || priceToController.text.isEmpty || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jaza sehemu zote za huduma')));
      return;
    }
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Picha moja au zaidi lazima iwepo')));
      return;
    }

    setState(() => loading = true);
    try {
      final service = Service(
        id: '',
        providerId: widget.user.id,
        category: categoryController.text.trim(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priceFrom: double.tryParse(priceFromController.text.trim()) ?? 0,
        priceTo: double.tryParse(priceToController.text.trim()) ?? 0,
        location: locationController.text.trim(),
        imageUrls: [],
        rating: 0,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      final serviceId = await serviceService.createService(service);
      final urls = <String>[];
      for (final image in selectedImages) {
        final url = await serviceService.uploadServiceImage(serviceId, image.path);
        urls.add(url);
      }

      await serviceService.updateService(serviceId, service.copyWith(imageUrls: urls));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Huduma imetumwa kwa admin kuthibitishwa')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ongeza Huduma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Kichwa cha huduma', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'Maelezo', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: priceFromController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bei kutoka (TZS)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: priceToController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bei hadi (TZS)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Eneo la huduma', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: pickImages, icon: const Icon(Icons.photo_library), label: Text('Picha (${selectedImages.length})')),
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
            const SizedBox(height: 24),
            FilledButton(
              onPressed: loading ? null : submitService,
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Tuma huduma kwa admin'),
            ),
          ],
        ),
      ),
    );
  }
}
