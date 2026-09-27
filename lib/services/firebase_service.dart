import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = AppUser(
      id: credential.user!.uid,
      email: email.trim(),
      name: name.trim(),
      phone: phone.trim(),
      role: role,
      isVerified: false,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();
}

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<PropertyListing>> getVerifiedListings() {
    return _firestore
        .collection('listings')
        .where('is_verified', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(PropertyListing.fromFirestore).toList());
  }

  Stream<List<PropertyListing>> getUserListings(String userId) {
    return _firestore
        .collection('listings')
        .where('owner_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(PropertyListing.fromFirestore).toList());
  }

  Future<String> createListing(PropertyListing listing) async {
    final doc = await _firestore.collection('listings').add(listing.toMap());
    return doc.id;
  }

  Future<void> updateListing(String id, PropertyListing listing) async {
    await _firestore.collection('listings').doc(id).update(listing.toMap());
  }

  Future<String> uploadImage(String listingId, String filePath) async {
    final file = File(filePath);
    final ref = _storage.ref('listings/$listingId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadVideo(String listingId, String filePath) async {
    final file = File(filePath);
    final ref = _storage.ref('listings/$listingId/video_${DateTime.now().millisecondsSinceEpoch}.mp4');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Service>> getVerifiedServices() {
    return _firestore
        .collection('services')
        .where('is_verified', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(Service.fromFirestore).toList());
  }

  Stream<List<Service>> getUserServices(String userId) {
    return _firestore
        .collection('services')
        .where('provider_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(Service.fromFirestore).toList());
  }

  Future<String> createService(Service service) async {
    final doc = await _firestore.collection('services').add(service.toMap());
    return doc.id;
  }

  Future<String> uploadServiceImage(String serviceId, String filePath) async {
    final file = File(filePath);
    final ref = _storage.ref('services/$serviceId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createRequest(ServiceRequest request) async {
    await _firestore.collection('service_requests').add(request.toMap());
  }

  Stream<List<ServiceRequest>> getTenantRequests(String tenantId) {
    return _firestore
        .collection('service_requests')
        .where('tenant_id', isEqualTo: tenantId)
        .snapshots()
        .map((snap) => snap.docs.map(ServiceRequest.fromFirestore).toList());
  }

  Stream<List<ServiceRequest>> getProviderRequests(String providerId) {
    return _firestore
        .collection('service_requests')
        .where('provider_id', isEqualTo: providerId)
        .snapshots()
        .map((snap) => snap.docs.map(ServiceRequest.fromFirestore).toList());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore
        .collection('service_requests')
        .doc(requestId)
        .update({'status': status});
  }
}

import 'dart:io';
