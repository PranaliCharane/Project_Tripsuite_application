import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/screens/expenses_screen.dart';
import 'package:tripsuite_app_boilerplate/features/homescreen/home_screen.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/profile_screen.dart';
import 'package:tripsuite_app_boilerplate/features/trips/screen/trip_screen.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/features/wishlist/screens/wishlist_screen.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void switchToTripsTab() {
    setState(() {
      _currentIndex = 2; // Trips tab is at index 2
    });
  }

  Widget _buildGradientIcon(IconData icon, bool isSelected) {
    if (isSelected) {
      return ShaderMask(
        shaderCallback: (Rect bounds) {
          return AppGradients.primaryGradient55deg.createShader(bounds);
        },
        child: Icon(icon, color: Colors.white, size: 24),
      );
    } else {
      return Icon(
        icon,
        color: const Color(0xFF999999), // Grey/500
        size: 24,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _buildCurrentScreen(context),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.blue, // Color for selected label
          unselectedItemColor: const Color(
            0xFF999999,
          ), // Grey/500 for unselected label
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          backgroundColor: AppColors.white,
          enableFeedback: false,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildGradientIcon(
                Icons.explore_outlined,
                _currentIndex == 0,
              ),
              activeIcon: _buildGradientIcon(Icons.explore_outlined, true),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: _buildGradientIcon(
                Icons.favorite_border,
                _currentIndex == 1,
              ),
              activeIcon: _buildGradientIcon(Icons.favorite_border, true),
              label: 'Wishlists',
            ),
            BottomNavigationBarItem(
              icon: _buildGradientIcon(
                Icons.card_travel_outlined,
                _currentIndex == 2,
              ),
              activeIcon: _buildGradientIcon(Icons.card_travel_outlined, true),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: _buildGradientIcon(
                Icons.receipt_long_outlined,
                _currentIndex == 3,
              ),
              activeIcon: _buildGradientIcon(Icons.receipt_long_outlined, true),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: _buildGradientIcon(
                Icons.person_outline,
                _currentIndex == 4,
              ),
              activeIcon: _buildGradientIcon(Icons.person_outline, true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(BuildContext context) {
    final wishlistManager = context.watch<WishlistManager>();
    final tripsManager = context.watch<TripsManager>();
    final screens = [
      HomeScreen(
        wishlistManager: wishlistManager,
        tripsManager: tripsManager,
        onNavigateToTrips: switchToTripsTab,
      ),
      WishlistScreen(wishlistManager: wishlistManager),
      TripsScreen(
        onExploreNow: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const ExpensesScreen(),
      const ProfileScreen(),
    ];

    return screens[_currentIndex];
  }
}
