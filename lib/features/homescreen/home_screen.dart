import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/features/auth/services/hotel_service.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/hotels.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/post_details.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/screens/post_details_screen.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/screens/add_hotel_screen.dart';
import 'package:tripsuite_app_boilerplate/features/profile/providers/profile_image_provider.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/features/wishlist/screens/wishlist_screen.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';
import 'package:image_picker/image_picker.dart';

// Main Hotels Screen
class HomeScreen extends StatefulWidget {
  final WishlistManager wishlistManager;
  final TripsManager? tripsManager;
  final VoidCallback? onNavigateToTrips;
  const HomeScreen({
    super.key,
    required this.wishlistManager,
    this.tripsManager,
    this.onNavigateToTrips,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HotelService _hotelService = HotelService();
  List<Hotel> allHotels = [];
  List<Hotel> filteredHotels = [];
  String searchDestination = "";
  DateTimeRange? selectedDates;
  int adultCount = 0;
  int childCount = 0;
  int infantCount = 0;
  int petCount = 0;
  bool isSearching = false;
  bool _isLoadingHotels = true;
  String? _loadError;
  Map<String, List<Hotel>> _hotelSections = {};
  List<String> _sectionOrder = [];
  final ImagePicker _imagePicker = ImagePicker();
  String _displayName = 'Tim';

  Future<void> _pickProfileImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      await context
          .read<ProfileImageProvider>()
          .updateProfileImage(File(picked.path));
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshDisplayName();
    _loadHotelsData();
  }

  Future<void> _loadHotelsData() async {
    setState(() {
      _isLoadingHotels = true;
      _loadError = null;
    });

    try {
      final hotelDocs = await _hotelService.getHotels();
      final fetchedHotels = hotelDocs
          .asMap()
          .entries
          .map((entry) => _mapHotelFromFirestore(entry.value, entry.key + 1))
          .toList();
      final sections = _groupHotelsByLocation(fetchedHotels);

      setState(() {
        allHotels = fetchedHotels;
        filteredHotels = [];
        isSearching = false;
        _hotelSections = sections;
        _sectionOrder = sections.keys.toList();
        _isLoadingHotels = false;
      });
    } catch (error) {
      setState(() {
        _loadError = 'Unable to load hotels. Please try again.';
        _isLoadingHotels = false;
      });
    }
  }

  Hotel _mapHotelFromFirestore(Map<String, dynamic> data, int index) {
    final idValue = data['id'];
    final resolvedId = _resolveHotelId(idValue, index);
    final type = (data['type'] as String?)?.trim() ?? 'Stay';
    final location = (data['location'] as String?)?.trim() ?? 'Unknown';
    final price = _parseDouble(data['price'], 0);
    final nights = _parseInt(data['nights'], 1);
    final rating = _parseDouble(data['rating'], 0);
    final rawImage = (data['image'] as String?)?.trim() ?? '';
    final imageList = _parseImageList(data['images'], rawImage);
    final image = imageList.isNotEmpty ? imageList.first : rawImage;
    final isFavorite = data['isFavorite'] as bool? ?? false;
    final badge = (data['badge'] as String?)?.trim() ?? 'Guest Favourite';
    final title = (data['title'] as String?)?.trim() ?? 'THE ROYAL GETAWAY';
    final description = (data['description'] as String?)?.trim() ??
        '"Welcome to The Royal Getaway – The Sunshine Swing bunk ,is a dreamy upper bunk in our 4-bed dorm. Bathed in golden sunlight from the balcony, it feels playful and nostalgic—just like a childhood swing. The space is shared with three like-minded women, fostering connection and creativity. With free art supplies, an open balcony, and calming natural light, it\'s a place to rest, heal, and express yourself in the heart of Bandra." 🌞✨';
    final bedrooms = _parseInt(data['bedrooms'], 2);
    final beds = _parseInt(data['beds'], 3);
    final hostName = (data['hostName'] as String?)?.trim() ?? 'Pooja Prem';
    final hostAvatar = (data['hostAvatar'] as String?)?.trim() ??
        'assets/images/host_avatar.png';
    final hostIsSuperhost = data['isSuperhost'] as bool? ?? true;
    final hostHostingYears = _parseInt(data['hostingYears'], 9);

    return Hotel(
      id: resolvedId,
      type: type,
      location: location,
      price: price,
      nights: nights,
      rating: rating,
      title: title,
      description: description,
      image: image,
      isFavorite: isFavorite,
      badge: badge,
      images: imageList,
      bedrooms: bedrooms,
      beds: beds,
      hostName: hostName,
      hostAvatar: hostAvatar,
      hostIsSuperhost: hostIsSuperhost,
      hostHostingYears: hostHostingYears,
    );
  }

  int _resolveHotelId(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value) ?? value.hashCode;
    }
    return fallback;
  }

  double _parseDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  int _parseInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  Map<String, List<Hotel>> _groupHotelsByLocation(List<Hotel> hotels) {
    final sections = <String, List<Hotel>>{};

    for (final hotel in hotels) {
      final locationKey = hotel.location.trim().isEmpty
          ? 'Unknown'
          : hotel.location.trim();
      sections.putIfAbsent(locationKey, () => []);
      sections[locationKey]!.add(hotel);
    }

    return sections;
  }

  List<Hotel> _filterHotelsLocally(String locationQuery) {
    final queryTokens = locationQuery
        .split(',')
        .map((token) => token.trim().toLowerCase())
        .where((token) => token.isNotEmpty)
        .toList();

    if (queryTokens.isEmpty) {
      return [];
    }

    return allHotels.where((hotel) {
      final location = hotel.location.toLowerCase();
      return queryTokens.any((token) => location.contains(token));
    }).toList();
  }

  List<String> _parseImageList(Object? value, String fallback) {
    if (value is List) {
      final parsed = value.whereType<String>().map((item) => item.trim()).toList();
      if (parsed.isNotEmpty) return parsed;
    }
    if (fallback.isNotEmpty) return [fallback];
    return [];
  }

  int get guestCount => adultCount + childCount + infantCount + petCount;

  Future<void> _performSearch() async {
    final locationQuery = searchDestination.trim();

    if (locationQuery.isEmpty && selectedDates == null && guestCount == 0) {
      setState(() {
        isSearching = false;
        filteredHotels = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      filteredHotels = [];
      _loadError = null;
    });

    try {
    final hotelDocs = await _hotelService.getHotels(
      location: locationQuery.isEmpty ? null : locationQuery,
    );
    final searchedHotels = hotelDocs
        .asMap()
        .entries
        .map((entry) => _mapHotelFromFirestore(entry.value, entry.key + 1))
        .toList();

    final fallbackHotels = _filterHotelsLocally(locationQuery);
    final finalResults =
        searchedHotels.isNotEmpty ? searchedHotels : fallbackHotels;

    setState(() {
      filteredHotels = finalResults;
    });
    } catch (error) {
      setState(() {
        filteredHotels = [];
        _loadError = 'Unable to search hotels right now.';
      });
    }
  }

  void _refreshDisplayName() {
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _displayName = name;
      });
    }
  }

  String get _timeOfDayGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    }
    return 'Good evening!';
  }

  void _clearAll() {
    setState(() {
      searchDestination = "";
      selectedDates = null;
      adultCount = 1;
      childCount = 0;
      infantCount = 0;
      petCount = 0;
      isSearching = false;
      filteredHotels = [];
    });
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchModalSheet(
        searchDestination: searchDestination,
        selectedDates: selectedDates,
        adultCount: adultCount,
        childCount: childCount,
        infantCount: infantCount,
        petCount: petCount,
        onSearch: (destination, dates, adults, children, infants, pets) {
          setState(() {
            searchDestination = destination;
            selectedDates = dates;
            adultCount = adults;
            childCount = children;
            infantCount = infants;
            petCount = pets;
          });
          _performSearch();
          Navigator.pop(context);
        },
        onClear: () {
          _clearAll();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Grey/100
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoadingHotels
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(
                          child: Text(
                            _loadError!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isSearching && filteredHotels.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Search Results (${filteredHotels.length})',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333), // Grey/800
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildVerticalHotelsList(filteredHotels),
                              ] else if (isSearching &&
                                  filteredHotels.isEmpty) ...[
                                const SizedBox(height: 40),
                                const Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No hotels found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                for (final city in _sectionOrder) ...[
                                  _buildSection(city, _hotelSections[city]!),
                                  const SizedBox(height: 20),
                                ],
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final profileImage = context.watch<ProfileImageProvider>().imageFile;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      margin: const EdgeInsets.only(top: 15),
      color: const Color(0xFFF5F5F5), // Grey/100
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ClipOval(
                    child: profileImage != null
                      ? Image.file(
                          profileImage,
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            );
                          },
                        )
                      : Image.asset(
                          "assets/images/host_avatar.png",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.grey,
                            );
                          },
                        ),
                    ),
                  ),
              ),
              const SizedBox(width: 8),
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                'Hi $_displayName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF808080), // Grey/600
                ),
              ),
              Text(
                _timeOfDayGreeting,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333), // Grey/800
                ),
              ),
                ],
              ),
            ],
          ),
          // Notification Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE5E5E5), // Grey/280
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHotelScreen(),
                  ),
                ).then((result) {
                  // Optionally refresh the hotel list if hotel was added
                  if (result == true) {
                    _loadHotelsData();
                  }
                });
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF5F5F5), // Grey/100
      child: GestureDetector(
        onTap: _showSearchModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFFE5E5E5), // Grey/280
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20,
                color: const Color(0xFF999999), // Grey/500
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search tickets, destination etc.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999), // Grey/500
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Hotel> hotels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333), // Grey/800
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF999999), // Grey/500
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Hotels List
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              return _buildHotelCard(hotels[index], index == hotels.length - 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel, bool isLast) {
    return GestureDetector(
      onTap: () {
        final postDetails = PostDetails.fromHotel(
          id: hotel.id,
          type: hotel.type,
          location: hotel.location,
          price: hotel.price,
          nights: hotel.nights,
          rating: hotel.rating,
          image: hotel.image,
          badge: hotel.badge,
          title: hotel.title,
          description: hotel.description,
          bedrooms: hotel.bedrooms,
          beds: hotel.beds,
          host: Host(
            name: hotel.hostName,
            avatar: hotel.hostAvatar,
            isSuperhost: hotel.hostIsSuperhost,
            hostingYears: hotel.hostHostingYears,
          ),
          images: hotel.images,
          dateRange: selectedDates,
          adultCount: adultCount,
          childCount: childCount,
          infantCount: infantCount,
          petCount: petCount,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PostDetailsScreen(
                  postDetails: postDetails,
                  tripsManager: widget.tripsManager,
                  onNavigateToTrips: widget.onNavigateToTrips,
                ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: EdgeInsets.only(right: isLast ? 0 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildHotelImage(
                    hotel.image,
                    width: 280,
                    height: 220,
                  ),
                ),
                // Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      hotel.badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333), // Grey/800
                      ),
                    ),
                  ),
                ),
                // Heart Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.wishlistManager.toggleWishlist(hotel);
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: widget.wishlistManager,
                        builder: (context, child) {
                          final isWishlisted = widget.wishlistManager
                              .isInWishlist(hotel.id);
                          return isWishlisted
                              ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              )
                              : ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return AppGradients.primaryGradient
                                      .createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              '${hotel.type} in ${hotel.location}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333), // Grey/800
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Price and Rating
            Row(
              children: [
                Text(
                  '₹${hotel.price.toStringAsFixed(0)} for ${hotel.nights} nights',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999), // Grey/500
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.star,
                  size: 14,
                  color: Color(0xFF999999), // Grey/500
                ),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999), // Grey/500
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(
    String image, {
    required double width,
    required double height,
  }) {
    if (image.isEmpty) {
      return _buildImagePlaceholder(width, height);
    }

    final isNetworkImage = image.toLowerCase().startsWith('http');
    if (isNetworkImage) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(width, height),
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildImagePlaceholder(width, height),
    );
  }

  Widget _buildImagePlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.hotel, size: 50),
    );
  }

  Widget _buildVerticalHotelsList(List<Hotel> hotels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return _buildVerticalHotelCard(hotels[index]);
        },
      ),
    );
  }

  Widget _buildVerticalHotelCard(Hotel hotel) {
    return GestureDetector(
      onTap: () {
        final postDetails = PostDetails.fromHotel(
          id: hotel.id,
          type: hotel.type,
          location: hotel.location,
          price: hotel.price,
          nights: hotel.nights,
          rating: hotel.rating,
          image: hotel.image,
          badge: hotel.badge,
          title: hotel.title,
          description: hotel.description,
          bedrooms: hotel.bedrooms,
          beds: hotel.beds,
          host: Host(
            name: hotel.hostName,
            avatar: hotel.hostAvatar,
            isSuperhost: hotel.hostIsSuperhost,
            hostingYears: hotel.hostHostingYears,
          ),
          images: hotel.images,
          dateRange: selectedDates,
          adultCount: adultCount,
          childCount: childCount,
          infantCount: infantCount,
          petCount: petCount,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PostDetailsScreen(
                  postDetails: postDetails,
                  tripsManager: widget.tripsManager,
                  onNavigateToTrips: widget.onNavigateToTrips,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: _buildHotelImage(
                    hotel.image,
                    width: double.infinity,
                    height: 280,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hotel.badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      widget.wishlistManager.toggleWishlist(hotel);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: widget.wishlistManager,
                        builder: (context, child) {
                          final isWishlisted =
                              widget.wishlistManager.isInWishlist(hotel.id);
                          return isWishlisted
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 20,
                                )
                              : ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return AppGradients.primaryGradient
                                        .createShader(bounds);
                                  },
                                  child: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${hotel.type} in ${hotel.location}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text(
                        hotel.rating.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${hotel.price.toStringAsFixed(0)} for ${hotel.nights} nights',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Modal Sheet
class SearchModalSheet extends StatefulWidget {
  final String searchDestination;
  final DateTimeRange? selectedDates;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final int petCount;
  final Function(
    String,
    DateTimeRange?,
    int,
    int,
    int,
    int,
  ) onSearch;
  final VoidCallback onClear;

  const SearchModalSheet({
    super.key,
    required this.searchDestination,
    required this.selectedDates,
    required this.adultCount,
    required this.childCount,
    required this.infantCount,
    required this.petCount,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<SearchModalSheet> createState() => _SearchModalSheetState();
}

class _SearchModalSheetState extends State<SearchModalSheet> {
  late TextEditingController _destinationController;
  late DateTimeRange? _selectedDates;
  late int _adultCount;
  late int _childCount;
  late int _infantCount;
  late int _petCount;
  bool _isGuestPanelOpen = false;
  final List<String> _suggestedDestinations = const [
    'Paris, France',
    'Goa, India',
    'Bali, Indonesia',
    'Lisbon, Portugal',
    'Tokyo, Japan',
    'Santorini, Greece',
  ];
  final List<String> _initialDestinationSuggestions = const [
    'Goa, India',
    'Panjim, Goa',
    'South Goa, India',
    'North Goa, India',
    'Baga, Goa',
    'Anjuna, Goa',
    'Mumbai, India',
    'Pune, India',
    'Bengaluru, India',
    'New Delhi, India',
    'Bali, Indonesia',
  ];
  List<String> _dropdownSuggestions = [];
  bool _showDestinationDropdown = false;

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(
      text: widget.searchDestination,
    );
    _selectedDates = widget.selectedDates;
    _adultCount = widget.adultCount;
    _childCount = widget.childCount;
    _infantCount = widget.infantCount;
    _petCount = widget.petCount;
    _destinationController.addListener(_updateDropdownSuggestions);
  }

  @override
  void dispose() {
    _destinationController.removeListener(_updateDropdownSuggestions);
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDates,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF385C),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDates = picked;
      });
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Add dates';
    return '${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}';
  }

  int get _totalGuests =>
      _adultCount + _childCount + _infantCount + _petCount;

  String get _guestSummaryText {
    if (_totalGuests == 0) return 'Add guests';
    return '$_totalGuests ${_totalGuests == 1 ? 'guest' : 'guests'}';
  }

  void _updateGuestCount(void Function() update) {
    setState(update);
  }

  void _updateDropdownSuggestions() {
    final searchText = _destinationController.text.trim();

    if (searchText.isEmpty) {
      setState(() {
        _dropdownSuggestions = [];
        _showDestinationDropdown = false;
      });
      return;
    }

    final matches = _initialDestinationSuggestions
        .where((option) =>
            option.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    setState(() {
      _dropdownSuggestions = matches;
      _showDestinationDropdown = matches.isNotEmpty;
    });
  }

  Widget _buildDestinationDropdown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _dropdownSuggestions
            .map((suggestion) => ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Color(0xFF379DD3),
                    size: 20,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    suggestion,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    setState(() {
                      _destinationController.text = suggestion;
                      _destinationController.selection =
                          TextSelection.collapsed(
                        offset: suggestion.length,
                      );
                      _showDestinationDropdown = false;
                      _dropdownSuggestions = [];
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGuestRow({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: count > 0 ? onDecrement : null,
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text(
                    'Homes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Where
                  const Text(
                    'Where?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Search destinations',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  if (_showDestinationDropdown) ...[
                    const SizedBox(height: 12),
                    _buildDestinationDropdown(),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Popular destinations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedDestinations
                        .map((suggestion) => ActionChip(
                              label: Text(
                                suggestion,
                                style: TextStyle(
                                  color: _destinationController.text ==
                                          suggestion
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              backgroundColor:
                                  _destinationController.text == suggestion
                                      ? AppColors.blue
                                      : Colors.grey.shade200,
                              onPressed: () {
                                setState(() {
                                  _destinationController.text = suggestion;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // When
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'When',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: _selectDates,
                        child: Text(
                          _formatDateRange(_selectedDates),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Who
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Who',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isGuestPanelOpen = !_isGuestPanelOpen;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _guestSummaryText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _isGuestPanelOpen
                        ? Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildGuestRow(
                                  title: 'Adults',
                                  subtitle: 'Ages 13 and above',
                                  count: _adultCount,
                                  onIncrement: () => _updateGuestCount(
                                      () => _adultCount++),
                                  onDecrement: () => _updateGuestCount(
                                      () {
                                        if (_adultCount == 0) return;
                                        _adultCount--;
                                      }),
                                ),
                                _buildGuestRow(
                                  title: 'Children',
                                  subtitle: 'Ages 0-12',
                                  count: _childCount,
                                  onIncrement: () => _updateGuestCount(
                                      () => _childCount++),
                                  onDecrement: () => _updateGuestCount(
                                      () {
                                        if (_childCount == 0) return;
                                        _childCount--;
                                      }),
                                ),
                                _buildGuestRow(
                                  title: 'Infants',
                                  subtitle: 'Under 2 years old',
                                  count: _infantCount,
                                  onIncrement: () => _updateGuestCount(
                                      () => _infantCount++),
                                  onDecrement: () => _updateGuestCount(
                                      () {
                                        if (_infantCount == 0) return;
                                        _infantCount--;
                                      }),
                                ),
                                _buildGuestRow(
                                  title: 'Pets',
                                  subtitle: 'Bringing pets?',
                                  count: _petCount,
                                  onIncrement: () => _updateGuestCount(
                                      () => _petCount++),
                                  onDecrement: () => _updateGuestCount(
                                      () {
                                        if (_petCount == 0) return;
                                        _petCount--;
                                      }),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: widget.onClear,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    widget.onSearch(
                      _destinationController.text,
                      _selectedDates,
                      _adultCount,
                      _childCount,
                      _infantCount,
                      _petCount,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
