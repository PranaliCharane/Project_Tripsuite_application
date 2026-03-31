class Hotel {
  final int id;
  final String type;
  final String location;
  final double price;
  final int nights;
  final double rating;
  final String title;
  final String description;
  final String image;
  final List<String> images;
  final bool isFavorite;
  final String badge;
  final int bedrooms;
  final int beds;
  final String hostName;
  final String hostAvatar;
  final bool hostIsSuperhost;
  final int hostHostingYears;

  Hotel({
    required this.id,
    required this.type,
    required this.location,
    required this.price,
    required this.nights,
    required this.rating,
    required this.title,
    required this.description,
    required this.image,
    required this.images,
    required this.isFavorite,
    required this.badge,
    required this.bedrooms,
    required this.beds,
    required this.hostName,
    required this.hostAvatar,
    required this.hostIsSuperhost,
    required this.hostHostingYears,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final List<String> rawGallery = (json['images'] as List<dynamic>?)
            ?.whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];
    final fallbackImage = (json['image'] as String?)?.trim() ?? '';
    final List<String> images = rawGallery.isNotEmpty
        ? rawGallery
        : fallbackImage.isNotEmpty
            ? [fallbackImage]
            : const <String>[];

    final title = (json['title'] as String?)?.trim() ?? 'THE ROYAL GETAWAY';
    final description = (json['description'] as String?)?.trim() ??
        '"Welcome to The Royal Getaway – The Sunshine Swing bunk ,is a dreamy upper bunk in our 4-bed dorm. '
            'Bathed in golden sunlight from the balcony, it feels playful and nostalgic—just like a childhood swing. '
            'The space is shared with three like-minded women, fostering connection and creativity. With free art supplies, '
            'an open balcony, and calming natural light, it\'s a place to rest, heal, and express yourself in the heart of Bandra." 🌞✨';
    final bedrooms = (json['bedrooms'] as num?)?.toInt() ?? 2;
    final beds = (json['beds'] as num?)?.toInt() ?? 3;
    final hostName = (json['hostName'] as String?)?.trim() ?? 'Pooja Prem';
    final hostAvatar = (json['hostAvatar'] as String?)?.trim() ??
        'assets/images/host_avatar.png';
    final hostIsSuperhost = json['isSuperhost'] as bool? ?? true;
    final hostHostingYears = (json['hostingYears'] as num?)?.toInt() ?? 9;

    return Hotel(
      id: json['id'],
      type: json['type'],
      location: json['location'],
      price: json['price'].toDouble(),
      nights: json['nights'],
      rating: json['rating'].toDouble(),
      title: title,
      description: description,
      image: images.isNotEmpty ? images.first : fallbackImage,
      images: images,
      isFavorite: json['isFavorite'],
      badge: json['badge'],
      bedrooms: bedrooms,
      beds: beds,
      hostName: hostName,
      hostAvatar: hostAvatar,
      hostIsSuperhost: hostIsSuperhost,
      hostHostingYears: hostHostingYears,
    );
  }

  Hotel copyWith({
    int? id,
    String? type,
    String? location,
    double? price,
    int? nights,
    double? rating,
    String? title,
    String? description,
    String? image,
    bool? isFavorite,
    String? badge,
    List<String>? images,
    int? bedrooms,
    int? beds,
    String? hostName,
    String? hostAvatar,
    bool? hostIsSuperhost,
    int? hostHostingYears,
  }) {
    return Hotel(
      id: id ?? this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      price: price ?? this.price,
      nights: nights ?? this.nights,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
      badge: badge ?? this.badge,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      hostIsSuperhost: hostIsSuperhost ?? this.hostIsSuperhost,
      hostHostingYears: hostHostingYears ?? this.hostHostingYears,
    );
  }
}
