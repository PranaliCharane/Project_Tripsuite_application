import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/auth/login_screen.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class OnboardingScreenOverview extends StatefulWidget {
  const OnboardingScreenOverview({super.key});

  @override
  _OnboardingScreenOverviewState createState() =>
      _OnboardingScreenOverviewState();
}

class _OnboardingScreenOverviewState extends State<OnboardingScreenOverview> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Define all onboarding pages data
  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Explore without limits",
      subtitle:
          "Discover endless destinations and seamless booking experiences with TravelSuite",
      imagePath: "assets/images/onboarding_screen_icon1.png",
    ),
    OnboardingData(
      title: "Unforgettable Adventures",
      subtitle: "Begin your journey with curated experiences across the globe.",
      imagePath: "assets/images/onboarding_screen_icon2.png",
    ),
    OnboardingData(
      title: "Travel Made Easy",
      subtitle: "Seamless bookings, personalized travel packages, and more.",
      imagePath: "assets/images/onboarding_screen_icon3.png",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 54, 20, 0),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    minimumSize: const Size(91, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C4C4C), // Grey/700
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: const Color(0xFF4C4C4C), // Grey/700
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main content area with PageView - Now with Flexible
            Flexible(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingContent(_pages[index]);
                },
              ),
            ),

            // Bottom area with dots and next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Next/Get Started button with gradient border
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient55deg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        margin: const EdgeInsets.all(1), // Border width
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _nextPage,
                            borderRadius: BorderRadius.circular(6),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return AppGradients.primaryGradient55deg
                                      .createShader(bounds);
                                },
                                child: Text(
                                  _currentPage == _pages.length - 1
                                      ? "Get Started"
                                      : "Next",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildOnboardingContent(OnboardingData data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 264, maxHeight: 350),
              child: Image.asset(data.imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0x80000000),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = _currentPage == index;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 1,
      ), // 2px gap total (1px each side)
      width: 8,
      height: 4,
      decoration: BoxDecoration(
        gradient: isActive ? AppGradients.primaryGradient55deg : null,
        color: isActive ? null : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}
