// ---------------------------------------------------------------
// seed_data.dart
//
// PURPOSE: Seeds Firestore with sample data — 5 service categories
// and 15 providers (3 per category).  Call `seedFirestore()` once
// from main.dart after Firebase.initializeApp(), then remove the
// call.
//
// USAGE:
//   1. In main.dart, add:  await seedFirestore();
//      (after Firebase.initializeApp)
//   2. Run the app once on an emulator.
//   3. Remove the seedFirestore() call.
// ---------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Seeds Firestore with 5 categories and 15 providers.
/// Skips seeding if data already exists (idempotent).
Future<void> seedFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // ── Check if already seeded ──────────────────────────────
  final existing = await firestore.collection('services').limit(1).get();
  if (existing.docs.isNotEmpty) {
    debugPrint('\u2714 Firestore already seeded. Skipping.');
    return;
  }

  debugPrint('\u23F3 Seeding Firestore...');

  // ── Seed categories ──────────────────────────────────────
  final categories = {
    'plumbing': {
      'name': 'Plumbing',
      'icon': 'plumbing',
      'description': 'Fix leaks, install pipes, repair taps and drainage systems.',
      'imageUrl': '',
    },
    'electrical': {
      'name': 'Electrical',
      'icon': 'electrical',
      'description': 'Wiring, switch repair, fan installation, and electrical fixes.',
      'imageUrl': '',
    },
    'cleaning': {
      'name': 'Cleaning',
      'icon': 'cleaning',
      'description': 'Home deep cleaning, kitchen cleaning, bathroom sanitization.',
      'imageUrl': '',
    },
    'painting': {
      'name': 'Painting',
      'icon': 'painting',
      'description': 'Interior and exterior wall painting, texture work, and polishing.',
      'imageUrl': '',
    },
    'carpentry': {
      'name': 'Carpentry',
      'icon': 'carpentry',
      'description': 'Furniture repair, door fixing, wood work, and custom shelves.',
      'imageUrl': '',
    },
  };

  for (final entry in categories.entries) {
    await firestore
        .collection('services')
        .doc(entry.key)
        .set(entry.value);
  }

  debugPrint('  \u2714 5 categories seeded.');

  // ── Seed providers (3 per category) ──────────────────────
  final providers = [
    // ── Plumbing ──
    {
      'name': 'Rajesh Kumar',
      'categoryId': 'plumbing',
      'rating': 4.8,
      'totalReviews': 124,
      'hourlyRate': 500,
      'location': const GeoPoint(28.6139, 77.2090),
      'city': 'New Delhi',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Rajesh+Kumar&background=6C63FF&color=fff&size=128',
      'about': 'Experienced plumber with 10+ years in residential and commercial plumbing. Specializing in leak repairs and pipe installations.',
    },
    {
      'name': 'Suresh Yadav',
      'categoryId': 'plumbing',
      'rating': 4.5,
      'totalReviews': 89,
      'hourlyRate': 400,
      'location': const GeoPoint(28.5355, 77.3910),
      'city': 'Noida',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Suresh+Yadav&background=6C63FF&color=fff&size=128',
      'about': 'Reliable plumber known for quick turnaround. Expert in bathroom fittings and water heater installations.',
    },
    {
      'name': 'Manoj Singh',
      'categoryId': 'plumbing',
      'rating': 4.2,
      'totalReviews': 56,
      'hourlyRate': 350,
      'location': const GeoPoint(28.4595, 77.0266),
      'city': 'Gurgaon',
      'available': false,
      'photoUrl': 'https://ui-avatars.com/api/?name=Manoj+Singh&background=6C63FF&color=fff&size=128',
      'about': 'Affordable plumbing solutions for homes and offices. Free estimates on major repairs.',
    },

    // ── Electrical ──
    {
      'name': 'Vikram Sharma',
      'categoryId': 'electrical',
      'rating': 4.9,
      'totalReviews': 203,
      'hourlyRate': 600,
      'location': const GeoPoint(28.6280, 77.2197),
      'city': 'New Delhi',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Vikram+Sharma&background=6C63FF&color=fff&size=128',
      'about': 'Certified electrician with expertise in home wiring, inverter setup, and smart home installations.',
    },
    {
      'name': 'Deepak Verma',
      'categoryId': 'electrical',
      'rating': 4.6,
      'totalReviews': 145,
      'hourlyRate': 550,
      'location': const GeoPoint(28.5672, 77.3215),
      'city': 'Noida',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Deepak+Verma&background=6C63FF&color=fff&size=128',
      'about': 'Specializing in fan installations, MCB repairs, and full house rewiring. Safety-first approach.',
    },
    {
      'name': 'Arun Gupta',
      'categoryId': 'electrical',
      'rating': 4.3,
      'totalReviews': 78,
      'hourlyRate': 450,
      'location': const GeoPoint(28.4698, 77.0380),
      'city': 'Gurgaon',
      'available': false,
      'photoUrl': 'https://ui-avatars.com/api/?name=Arun+Gupta&background=6C63FF&color=fff&size=128',
      'about': 'Experienced in commercial and residential electrical work. Available for emergency repairs.',
    },

    // ── Cleaning ──
    {
      'name': 'Priya Nair',
      'categoryId': 'cleaning',
      'rating': 4.7,
      'totalReviews': 167,
      'hourlyRate': 400,
      'location': const GeoPoint(28.6353, 77.2250),
      'city': 'New Delhi',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Priya+Nair&background=6C63FF&color=fff&size=128',
      'about': 'Professional cleaning services for homes and offices. Eco-friendly products used.',
    },
    {
      'name': 'Sunita Devi',
      'categoryId': 'cleaning',
      'rating': 4.4,
      'totalReviews': 92,
      'hourlyRate': 350,
      'location': const GeoPoint(28.5500, 77.3500),
      'city': 'Noida',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Sunita+Devi&background=6C63FF&color=fff&size=128',
      'about': 'Deep cleaning specialist. Kitchen, bathroom, and full-house cleaning packages available.',
    },
    {
      'name': 'Kavita Joshi',
      'categoryId': 'cleaning',
      'rating': 4.1,
      'totalReviews': 45,
      'hourlyRate': 300,
      'location': const GeoPoint(28.4500, 77.0200),
      'city': 'Gurgaon',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Kavita+Joshi&background=6C63FF&color=fff&size=128',
      'about': 'Affordable and thorough cleaning services. Flexible scheduling for your convenience.',
    },

    // ── Painting ──
    {
      'name': 'Ramesh Painter',
      'categoryId': 'painting',
      'rating': 4.6,
      'totalReviews': 134,
      'hourlyRate': 550,
      'location': const GeoPoint(28.6100, 77.2300),
      'city': 'New Delhi',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Ramesh+Painter&background=6C63FF&color=fff&size=128',
      'about': 'Professional painter with 15 years experience. Interior, exterior, and texture specialist.',
    },
    {
      'name': 'Sanjay Mishra',
      'categoryId': 'painting',
      'rating': 4.3,
      'totalReviews': 67,
      'hourlyRate': 450,
      'location': const GeoPoint(28.5800, 77.3300),
      'city': 'Noida',
      'available': false,
      'photoUrl': 'https://ui-avatars.com/api/?name=Sanjay+Mishra&background=6C63FF&color=fff&size=128',
      'about': 'Creative wall designs and texture work. Free colour consultation included.',
    },
    {
      'name': 'Dinesh Rao',
      'categoryId': 'painting',
      'rating': 4.0,
      'totalReviews': 38,
      'hourlyRate': 400,
      'location': const GeoPoint(28.4400, 77.0500),
      'city': 'Gurgaon',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Dinesh+Rao&background=6C63FF&color=fff&size=128',
      'about': 'Budget-friendly painting services. Quality Asian Paints and Berger products used.',
    },

    // ── Carpentry ──
    {
      'name': 'Gopal Carpenter',
      'categoryId': 'carpentry',
      'rating': 4.8,
      'totalReviews': 189,
      'hourlyRate': 600,
      'location': const GeoPoint(28.6200, 77.2100),
      'city': 'New Delhi',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Gopal+Carpenter&background=6C63FF&color=fff&size=128',
      'about': 'Master carpenter specializing in custom furniture, modular kitchens, and wardrobes.',
    },
    {
      'name': 'Ravi Tiwari',
      'categoryId': 'carpentry',
      'rating': 4.4,
      'totalReviews': 98,
      'hourlyRate': 500,
      'location': const GeoPoint(28.5600, 77.3400),
      'city': 'Noida',
      'available': true,
      'photoUrl': 'https://ui-avatars.com/api/?name=Ravi+Tiwari&background=6C63FF&color=fff&size=128',
      'about': 'Furniture repair and assembly expert. Door and window fitting specialist.',
    },
    {
      'name': 'Pankaj Jha',
      'categoryId': 'carpentry',
      'rating': 4.1,
      'totalReviews': 52,
      'hourlyRate': 400,
      'location': const GeoPoint(28.4700, 77.0400),
      'city': 'Gurgaon',
      'available': false,
      'photoUrl': 'https://ui-avatars.com/api/?name=Pankaj+Jha&background=6C63FF&color=fff&size=128',
      'about': 'Custom shelving, TV unit design, and general wood repairs. Free site visit for estimates.',
    },
  ];

  for (final provider in providers) {
    await firestore.collection('providers').add(provider);
  }

  debugPrint('  \u2714 15 providers seeded.');
  debugPrint('\u2714 Firestore seeding complete!');
}
