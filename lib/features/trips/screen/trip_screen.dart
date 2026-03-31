import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/features/trips/widgets/trip_card.dart';

class TripsScreen extends StatelessWidget {
  final VoidCallback? onExploreNow;

  const TripsScreen({super.key, this.onExploreNow});

  @override
  Widget build(BuildContext context) {
    final tripsManager = context.watch<TripsManager>();
    final hasTrips = tripsManager.hasTrips;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 19, top: 20, right: 19),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trips',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333), // Grey/800
                    fontFamily: 'Inter',
                    height: 1.67, // line-height: 1.6666666666666667em
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: hasTrips
                  ? _buildTripsList(context)
                  : _buildEmptyState(context),
            ),
            // Explore Now Button (only show when empty)
            if (!hasTrips)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Container(
                  width: 335,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient55deg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home screen via callback
                      if (onExploreNow != null) {
                        onExploreNow!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Explore Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF5F5F5), // Grey/100
                        fontFamily: 'Inter',
                        height: 1.43, // line-height: 1.4285714285714286em
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(BuildContext context) {
    final tripsManager = context.watch<TripsManager>();
    final currentTrips = tripsManager.trips;

    if (currentTrips.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: currentTrips.length,
      itemBuilder: (context, index) {
        return TripCard(trip: currentTrips[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            'assets/images/journey_bro.png',
            width: 246,
            height: 246,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          // Text container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                // "No trips yet ✈️"
                Text(
                  'No trips yet ✈️',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333), // Grey/800
                    fontFamily: 'Inter',
                    height: 1.5, // line-height: 1.5em
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  'Looks like you haven\'t planned a trip yet.\nStart exploring destinations and plan your journey with ease.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C4C4C), // Grey/700
                    fontFamily: 'Inter',
                    height: 1.67, // line-height: 1.6666666666666667em
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
