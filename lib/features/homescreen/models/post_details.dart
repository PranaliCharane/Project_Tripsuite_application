import 'package:flutter/material.dart';

class PostDetails {
  final int id;
  final String title;
  final String type;
  final String location;
  final String country;
  final int bedrooms;
  final int beds;
  final double rating;
  final int reviewCount;
  final String badge;
  final List<String> images;
  final Host host;
  final List<Feature> features;
  final String description;
  final List<Amenity> amenities;
  final double price;
  final int nights;
  final DateTimeRange? dateRange;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final int petCount;

  PostDetails({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.country,
    required this.bedrooms,
    required this.beds,
    required this.rating,
    required this.reviewCount,
    required this.badge,
    required this.images,
    required this.host,
    required this.features,
    required this.description,
    required this.amenities,
    required this.price,
    required this.nights,
    this.dateRange,
    required this.adultCount,
    this.childCount = 0,
    required this.infantCount,
    this.petCount = 0,
  });

  factory PostDetails.fromHotel({
    required int id,
    required String type,
    required String location,
    required double price,
    required int nights,
    required double rating,
    required String image,
    required String badge,
    String? title,
    int bedrooms = 2,
    int beds = 3,
    int reviewCount = 322,
    String country = 'India',
    List<String>? images,
    Host? host,
    List<Feature>? features,
    String? description,
    List<Amenity>? amenities,
    DateTimeRange? dateRange,
    int adultCount = 2,
    int childCount = 0,
    int infantCount = 1,
    int petCount = 0,
  }) {
    return PostDetails(
      id: id,
      title: title ?? 'THE ROYAL GETAWAY',
      type: type,
      location: location,
      country: country,
      bedrooms: bedrooms,
      beds: beds,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      images: images ?? [image],
      host:
          host ??
          Host(
            name: 'Pooja Prem',
            avatar: 'assets/images/host_avatar.png',
            isSuperhost: true,
            hostingYears: 9,
          ),
      features:
          features ??
          [
            Feature(
              icon: Icons.lock_outline,
              title: 'Check yourself in with the lockbox.',
              description: 'Check yourself in with the lockbox.',
            ),
            Feature(
              icon: Icons.home_outlined,
              title: 'Room in a rental unit',
              description:
                  'Your own room in a home, plus access to shared spaces.',
            ),
            Feature(
              icon: Icons.cancel_outlined,
              title: 'Free cancellation before 30 December',
              description: 'Get a full refund if you change your mind.',
            ),
          ],
      description:
          description ??
          '"Welcome to The Royal Getaway – The Sunshine Swing bunk ,is a dreamy upper bunk in our 4-bed dorm. Bathed in golden sunlight from the balcony, it feels playful and nostalgic—just like a childhood swing. The space is shared with three like-minded women, fostering connection and creativity. With free art supplies, an open balcony, and calming natural light, it\'s a place to rest, heal, and express yourself in the heart of Bandra." 🌞✨',
      amenities:
          amenities ??
          [
            Amenity(icon: Icons.lock, name: 'Lock on bedroom door'),
            Amenity(icon: Icons.wifi, name: 'Wifi'),
            Amenity(icon: Icons.local_parking, name: 'Free on-street parking'),
            Amenity(icon: Icons.tv, name: 'TV'),
          ],
      price: price,
      nights: nights,
      dateRange: dateRange,
      adultCount: adultCount,
      childCount: childCount,
      infantCount: infantCount,
      petCount: petCount,
    );
  }
}

class Host {
  final String name;
  final String avatar;
  final bool isSuperhost;
  final int hostingYears;

  Host({
    required this.name,
    required this.avatar,
    required this.isSuperhost,
    required this.hostingYears,
  });
}

class Feature {
  final IconData icon;
  final String title;
  final String description;

  Feature({required this.icon, required this.title, required this.description});
}

class Amenity {
  final IconData icon;
  final String name;

  Amenity({required this.icon, required this.name});
}

