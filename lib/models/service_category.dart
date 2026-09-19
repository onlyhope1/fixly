// ---------------------------------------------------------------
// service_category.dart
//
// PURPOSE: Data model for a service category stored in the
// Firestore `services` collection.  Each category has a name,
// an icon identifier (mapped to Material Icons), a description,
// and an optional image URL.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a service category from the Firestore `services` collection.
class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String imageUrl;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.imageUrl,
  });

  // ── Firestore serialization ────────────────────────────────

  /// Creates a [ServiceCategory] from a Firestore document snapshot.
  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ServiceCategory(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String,
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  /// Converts this category to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  // ── Icon mapping ───────────────────────────────────────────

  /// Maps the stored [icon] string to a Material [IconData].
  /// Add more mappings as new categories are introduced.
  IconData get iconData {
    switch (icon) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'painting':
        return Icons.format_paint;
      case 'carpentry':
        return Icons.carpenter;
      default:
        return Icons.home_repair_service;
    }
  }
}
