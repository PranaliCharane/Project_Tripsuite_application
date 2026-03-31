import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/post_details.dart';
import 'package:tripsuite_app_boilerplate/features/review/screens/review_screen.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class PostDetailsScreen extends StatefulWidget {
  final PostDetails postDetails;
  final TripsManager? tripsManager;
  final VoidCallback? onNavigateToTrips;

  const PostDetailsScreen({
    super.key,
    required this.postDetails,
    this.tripsManager,
    this.onNavigateToTrips,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDates() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _checkInDate != null && _checkOutDate != null
              ? DateTimeRange(start: _checkInDate!, end: _checkOutDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF379DD3), // Primary/500
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333), // Grey/800
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.postDetails;
    final images = post.images;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Grey/100
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel Section
                _buildImageCarousel(images),
                const SizedBox(height: 20),

                // Content Section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5), // Grey/100
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Location
                      _buildTitleSection(post),
                      const SizedBox(height: 20),

                      // Rating and Reviews
                      _buildRatingSection(post),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 20),

                      // Host Section
                      _buildHostSection(post.host),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 20),

                      // Features Section
                      _buildFeaturesSection(post.features),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 20),

                      // Description
                      _buildDescriptionSection(post.description),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 20),

                      // Location Section
                      _buildLocationSection(),
                      const SizedBox(height: 20),

                      // Divider
                      const Divider(color: Color(0xFFE5E5E5), height: 1),
                      const SizedBox(height: 20),

                      // Amenities Section
                      _buildAmenitiesSection(post.amenities),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Navigation Bar
          _buildTopNavigationBar(),

          // Bottom Bar
          _buildBottomBar(post),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return _buildImagePlaceholder(height: 357);
    }

    return SizedBox(
      height: 357,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildImageWidget(
                images[index],
                height: 357,
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333), // Grey/800
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(
    String image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final isNetworkImage = image.toLowerCase().startsWith('http');
    if (isNetworkImage) {
      return Image.network(
        image,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildImagePlaceholder(width: width, height: height),
      );
    }
    return Image.asset(
      image,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) =>
          _buildImagePlaceholder(width: width, height: height),
    );
  }

  Widget _buildImagePlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 50),
    );
  }

  Widget _buildTopNavigationBar() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_outlined, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(PostDetails post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333), // Grey/800
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${post.type} In ${post.location}, ${post.country}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF999999), // Grey/500
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${post.bedrooms} Bedrooms',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999), // Grey/500
              ),
            ),
            Container(
              width: 20,
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFF5F5F5), // Grey/100
            ),
            Text(
              '${post.beds} Beds',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF999999), // Grey/500
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(PostDetails post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rating
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  post.rating.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333), // Grey/800
                  ),
                ),
                const SizedBox(width: 4),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return AppGradients.primaryGradient.createShader(bounds);
                  },
                  child: const Icon(Icons.star, size: 20, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        // Guest Favourite
        Row(
          children: [
            Image.asset(
              'assets/images/guest_favourite_icon1-68add4.png',
              width: 14.29,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 14.29, height: 20);
              },
            ),
            const SizedBox(width: 4),
            const Text(
              'Guest\nFavourite',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333), // Grey/800
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/images/guest_favourite_icon2-68add4.png',
              width: 14.29,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(width: 14.29, height: 20);
              },
            ),
          ],
        ),
        // Reviews
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              post.reviewCount.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333), // Grey/800
              ),
            ),
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333333), // Grey/800
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostSection(Host host) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            host.avatar,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 44,
                height: 44,
                color: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 24),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hosted by ${host.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333), // Grey/800
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (host.isSuperhost) ...[
                    const Text(
                      'Superhost',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF999999), // Grey/500
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: const Color(0xFFF5F5F5), // Grey/100
                    ),
                  ],
                  Text(
                    '${host.hostingYears} years of hosting',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF999999), // Grey/500
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(List<Feature> features) {
    return Column(
      children:
          features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2), // Grey/200
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      feature.icon,
                      size: 24,
                      color: const Color(0xFF333333), // Grey/800
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333), // Grey/800
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF999999), // Grey/500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4C4C4C), // Grey/700
        height: 1.5,
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Where you'll be",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333), // Grey/800
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Exact location will be provided after reservation',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333), // Grey/800
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/map_location.png',
            width: double.infinity,
            height: 319,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 319,
                color: Colors.grey.shade300,
                child: const Icon(Icons.map, size: 50),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(List<Amenity> amenities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What this place offers',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333), // Grey/800
          ),
        ),
        const SizedBox(height: 12),
        ...amenities.take(4).map((amenity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  amenity.icon,
                  size: 24,
                  color: const Color(0xFF4C4C4C), // Grey/700
                ),
                const SizedBox(width: 12),
                Text(
                  amenity.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C4C4C), // Grey/700
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            // Show all amenities
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: Color(0xFF379DD3), // Primary/500
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
          child: const Text(
            'Show all 36 amenities',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF379DD3), // Primary/500
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(PostDetails post) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5), // Grey/100
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E5E5), // Grey/300
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 11,
          bottom: MediaQuery.of(context).padding.bottom + 11,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${post.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333), // Grey/800
                    ),
                  ),
                  if (_checkInDate != null && _checkOutDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${_checkInDate!.day} ${_getMonthAbbr(_checkInDate!.month)}-${_checkOutDate!.day} ${_getMonthAbbr(_checkOutDate!.month)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333).withOpacity(0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFFF5F5F5),
                        ),
                        Expanded(
                          child: Text(
                            '${post.adultCount} Adult${post.adultCount > 1 ? 's' : ''}, ${post.infantCount} Infant${post.infantCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333).withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else if (post.dateRange != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${post.dateRange!.start.day} ${_getMonthAbbr(post.dateRange!.start.month)}-${post.dateRange!.end.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333).withOpacity(0.5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFFF5F5F5),
                        ),
                        Expanded(
                          child: Text(
                            '${post.adultCount} Adult${post.adultCount > 1 ? 's' : ''}, ${post.infantCount} Infant${post.infantCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333).withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed:
                    _checkInDate != null && _checkOutDate != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReviewScreen(
                                          postDetails: post,
                                          checkInDate: _checkInDate!,
                                          checkOutDate: _checkOutDate!,
                                          adultCount: post.adultCount,
                                          childCount: post.childCount,
                                          infantCount: post.infantCount,
                                          petCount: post.petCount,
                                          tripsManager: widget.tripsManager,
                                          onNavigateToTrips: widget.onNavigateToTrips,
                                        ),
                              ),
                            );
                          }
                        : _selectDates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379DD3), // Primary/500
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(0, 40),
                ),
                child: Text(
                  _checkInDate != null && _checkOutDate != null
                      ? 'Reserve Now'
                      : 'Check Availability',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF5F5F5), // Grey/100
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return months[month - 1];
  }
}
