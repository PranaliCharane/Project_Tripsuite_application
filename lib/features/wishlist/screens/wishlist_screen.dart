// wishlist_manager.dart
import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/hotels.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/post_details.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/screens/post_details_screen.dart';

class WishlistManager extends ChangeNotifier {
  final Map<int, Hotel> _wishlistItems = {};

  Map<int, Hotel> get wishlistItems => _wishlistItems;

  bool isInWishlist(int hotelId) {
    return _wishlistItems.containsKey(hotelId);
  }

  void toggleWishlist(Hotel hotel) {
    if (_wishlistItems.containsKey(hotel.id)) {
      _wishlistItems.remove(hotel.id);
    } else {
      _wishlistItems[hotel.id] = hotel;
    }
    notifyListeners();
  }

  void removeFromWishlist(int hotelId) {
    _wishlistItems.remove(hotelId);
    notifyListeners();
  }

  int get wishlistCount => _wishlistItems.length;
}

// wishlist_screen.dart
class WishlistScreen extends StatelessWidget {
  final WishlistManager wishlistManager;

  const WishlistScreen({super.key, required this.wishlistManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Wishlists',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: wishlistManager,
        builder: (context, child) {
          if (wishlistManager.wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No wishlists yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on homes to save them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWishlistCard(
                  context,
                  'My Favorites',
                  wishlistManager.wishlistItems.values.toList(),
                  wishlistManager,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    String title,
    List<Hotel> hotels,
    WishlistManager wishlistManager,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => WishlistDetailScreen(
                  title: title,
                  hotels: hotels,
                  wishlistManager: wishlistManager,
                ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 280,
              child: hotels.length == 1
                  ? HotelGallery(
                      hotel: hotels[0],
                      height: 280,
                      showIndicator: true,
                    )
                  : _buildGridImages(hotels),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${hotels.length} saved',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGridImages(List<Hotel> hotels) {
    final displayHotels = hotels.take(4).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: displayHotels.length,
      itemBuilder: (context, index) {
        return Image.network(
          displayHotels[index].image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.hotel, size: 30),
            );
          },
        );
      },
    );
  }
}

// wishlist_detail_screen.dart
class WishlistDetailScreen extends StatelessWidget {
  final String title;
  final List<Hotel> hotels;
  final WishlistManager wishlistManager;

  const WishlistDetailScreen({
    super.key,
    required this.title,
    required this.hotels,
    required this.wishlistManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: wishlistManager,
        builder: (context, child) {
          final currentHotels = wishlistManager.wishlistItems.values.toList();

          if (currentHotels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved homes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentHotels.length,
            itemBuilder: (context, index) {
              return _buildHotelCard(context, currentHotels[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () => _openHotelDetails(context, hotel),
      child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: HotelGallery(hotel: hotel, height: 280),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    wishlistManager.removeFromWishlist(hotel.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
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

class HotelGallery extends StatefulWidget {
  final Hotel hotel;
  final double height;
  final bool showIndicator;

  const HotelGallery({
    super.key,
    required this.hotel,
    this.height = double.infinity,
    this.showIndicator = true,
  });

  @override
  State<HotelGallery> createState() => _HotelGalleryState();
}

class _HotelGalleryState extends State<HotelGallery> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant HotelGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hotel.id != widget.hotel.id) {
      _currentPage = 0;
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _resolveHotelImageUrls(widget.hotel);

    if (imageUrls.isEmpty) {
      return _hotelGalleryPlaceholder(height: widget.height);
    }

    final needsIndicator = widget.showIndicator && imageUrls.length > 1;

    return SizedBox(
      height: widget.height == double.infinity ? null : widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: imageUrls.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _hotelGalleryPlaceholder(height: widget.height);
                },
              );
            },
          ),
          if (needsIndicator)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 10 : 6,
                    height: isActive ? 10 : 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isActive ? 0.9 : 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

List<String> _resolveHotelImageUrls(Hotel hotel) {
  final images = hotel.images
      .map((url) => url.trim())
      .where((url) => url.isNotEmpty)
      .toList();

  if (images.isNotEmpty) {
    return images;
  }

  final fallbackImage = hotel.image.trim();
  return fallbackImage.isNotEmpty ? [fallbackImage] : [];
}

Widget _hotelGalleryPlaceholder({double height = double.infinity}) {
  return Container(
    height: height == double.infinity ? null : height,
    width: double.infinity,
    color: Colors.grey.shade300,
    child: const Icon(Icons.hotel, size: 50),
  );
}

void _openHotelDetails(BuildContext context, Hotel hotel) {
  final postDetails = _mapHotelToPostDetails(hotel);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostDetailsScreen(
        postDetails: postDetails,
      ),
    ),
  );
}

PostDetails _mapHotelToPostDetails(Hotel hotel) {
  return PostDetails.fromHotel(
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
  );
}
