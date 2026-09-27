import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { tenant, landlord, provider, admin }

class AppUser {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final bool isVerified;
  final String? profileImage;
  final String? location;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isVerified,
    this.profileImage,
    this.location,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: _roleFromString(data['role']),
      isVerified: data['is_verified'] ?? false,
      profileImage: data['profile_image'],
      location: data['location'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static UserRole _roleFromString(String? role) {
    switch (role) {
      case 'landlord':
        return UserRole.landlord;
      case 'provider':
        return UserRole.provider;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.tenant;
    }
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'phone': phone,
    'role': role.name,
    'is_verified': isVerified,
    'profile_image': profileImage,
    'location': location,
    'created_at': FieldValue.serverTimestamp(),
  };
}

class PropertyListing {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String locationName;
  final double gpsLat;
  final double gpsLng;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> amenities;
  final bool isVerified;
  final String verificationStatus;
  final DateTime createdAt;

  PropertyListing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.locationName,
    required this.gpsLat,
    required this.gpsLng,
    required this.imageUrls,
    this.videoUrl,
    required this.amenities,
    required this.isVerified,
    required this.verificationStatus,
    required this.createdAt,
  });

  factory PropertyListing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PropertyListing(
      id: doc.id,
      ownerId: data['owner_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      locationName: data['location_name'] ?? '',
      gpsLat: (data['gps_lat'] ?? 0).toDouble(),
      gpsLng: (data['gps_lng'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['images'] ?? []),
      videoUrl: data['video_url'],
      amenities: List<String>.from(data['amenities'] ?? []),
      isVerified: data['is_verified'] ?? false,
      verificationStatus: data['verification_status'] ?? 'pending',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'owner_id': ownerId,
    'title': title,
    'description': description,
    'price': price,
    'location_name': locationName,
    'gps_lat': gpsLat,
    'gps_lng': gpsLng,
    'images': imageUrls,
    'video_url': videoUrl,
    'amenities': amenities,
    'is_verified': isVerified,
    'verification_status': verificationStatus,
    'created_at': FieldValue.serverTimestamp(),
  };
}

class Service {
  final String id;
  final String providerId;
  final String category;
  final String title;
  final String description;
  final double priceFrom;
  final double priceTo;
  final String location;
  final List<String> imageUrls;
  final double rating;
  final bool isVerified;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.providerId,
    required this.category,
    required this.title,
    required this.description,
    required this.priceFrom,
    required this.priceTo,
    required this.location,
    required this.imageUrls,
    required this.rating,
    required this.isVerified,
    required this.createdAt,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      providerId: data['provider_id'] ?? '',
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priceFrom: (data['price_from'] ?? 0).toDouble(),
      priceTo: (data['price_to'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      imageUrls: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      isVerified: data['is_verified'] ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'provider_id': providerId,
    'category': category,
    'title': title,
    'description': description,
    'price_from': priceFrom,
    'price_to': priceTo,
    'location': location,
    'images': imageUrls,
    'rating': rating,
    'is_verified': isVerified,
    'created_at': FieldValue.serverTimestamp(),
  };
}

class ServiceRequest {
  final String id;
  final String tenantId;
  final String providerId;
  final String serviceId;
  final String status;
  final DateTime timestamp;

  ServiceRequest({
    required this.id,
    required this.tenantId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.timestamp,
  });

  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      tenantId: data['tenant_id'] ?? '',
      providerId: data['provider_id'] ?? '',
      serviceId: data['service_id'] ?? '',
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'tenant_id': tenantId,
    'provider_id': providerId,
    'service_id': serviceId,
    'status': status,
    'timestamp': FieldValue.serverTimestamp(),
  };
}
