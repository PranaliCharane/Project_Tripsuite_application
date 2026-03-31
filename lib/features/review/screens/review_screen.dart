import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/review/screens/payment_screen.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/models/post_details.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trip.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class ReviewScreen extends StatelessWidget {
  final PostDetails postDetails;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final int petCount;
  final TripsManager? tripsManager;
  final VoidCallback? onNavigateToTrips;

  const ReviewScreen({
    Key? key,
    required this.postDetails,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adultCount,
    this.childCount = 0,
    required this.infantCount,
    this.petCount = 0,
    this.tripsManager,
    this.onNavigateToTrips,
  }) : super(key: key);

  int get nights {
    return checkOutDate.difference(checkInDate).inDays;
  }

  String _getMonthAbbreviation(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  String get dateRange {
    return '${checkInDate.day}-${checkOutDate.day} ${_getMonthAbbreviation(checkOutDate)} ${checkOutDate.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthAbbreviation(date)} ${date.year}';
  }

  String get guestSummary {
    final parts = <String>[];
    if (adultCount > 0) {
      parts.add('$adultCount Adult${adultCount > 1 ? 's' : ''}');
    }
    if (childCount > 0) {
      parts.add('$childCount Child${childCount > 1 ? 'ren' : ''}');
    }
    if (infantCount > 0) {
      parts.add('$infantCount Infant${infantCount > 1 ? 's' : ''}');
    }
    if (petCount > 0) {
      parts.add('$petCount Pet${petCount > 1 ? 's' : ''}');
    }
    if (parts.isEmpty) {
      return '1 Adult';
    }
    return parts.join(', ');
  }

  int get totalGuests => adultCount + childCount + infantCount + petCount;

  double get basePrice => postDetails.price * nights;
  double get serviceFee => basePrice * 0.05;
  double get taxAmount => basePrice * 0.12;
  double get cleaningFee => 150;

  double get totalPrice => basePrice + serviceFee + taxAmount + cleaningFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Grey/100
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color(0xFF333333), // Grey/800
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review and Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333), // Grey/800
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                    child: _buildPropertyImage(
                      postDetails.images.isNotEmpty
                          ? postDetails.images[0]
                          : 'assets/images/hotel_pic1.jpeg',
                    ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postDetails.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333), // Grey/800
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'in ${postDetails.location}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF666666), // Grey/600
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    postDetails.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Image.asset(
                                    'assets/images/guest_favourite_icon1-68add4.png',
                                    width: 16,
                                    height: 16,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Guest favourite',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dates Section
                    _buildEditableSection(
                      title: 'Dates',
                      value: dateRange,
                      onEdit: () {
                        // TODO: Navigate to date picker
                      },
                    ),
                    const SizedBox(height: 20),

                    // Guests Section
                    _buildEditableSection(
                      title: 'Guests',
                      value: guestSummary,
                      onEdit: () {
                        // TODO: Navigate to guest selector
                      },
                    ),
                    const SizedBox(height: 20),

                    // Total Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333), // Grey/800
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹ ${totalPrice.toStringAsFixed(0)} · Includes taxes & fees',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333), // Grey/800
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showPriceBreakdown(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF379DD3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Free Cancellation Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Free Cancellation',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333), // Grey/800
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cancel before ${_formatDate(checkInDate.subtract(const Duration(days: 5)))} for a full refund',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666), // Grey/600
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            // TODO: Show cancellation policy
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View Policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF379DD3),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Continue Button (Fixed at bottom)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Create trip object
                      final trip = Trip(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        postDetails: postDetails,
                        checkInDate: checkInDate,
                        checkOutDate: checkOutDate,
                        adultCount: adultCount,
                        infantCount: infantCount,
                        totalAmount: totalPrice,
                      );

                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => PaymentScreen(
                                amount: totalPrice,
                                trip: trip,
                                tripsManager: tripsManager,
                                onNavigateToTrips: onNavigateToTrips,
                              ),
                        ),
                      );

                      // If payment was successful, navigate to trips tab
                      if (result == true) {
                        // Pop back to main screen
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                        // Navigate to trips tab
                        if (onNavigateToTrips != null) {
                          onNavigateToTrips!();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(String image) {
    final placeholder = Container(
      width: 100,
      height: 100,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 40),
    );

    if (image.toLowerCase().startsWith('http')) {
      return Image.network(
        image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.asset(
      image,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _buildEditableSection({
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333), // Grey/800
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666), // Grey/600
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF379DD3)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _showPriceBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              _buildBreakdownRow(
                '${postDetails.price.toStringAsFixed(0)} × $nights nights',
                basePrice,
              ),
              _buildBreakdownRow('Cleaning fee', cleaningFee),
              _buildBreakdownRow('Service fee (5%)', serviceFee),
              _buildBreakdownRow('Taxes (12%)', taxAmount),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total payable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '₹ ${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF379DD3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Text(
            '₹ ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
