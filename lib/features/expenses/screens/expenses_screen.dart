import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/models/trip_expense_record.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/providers/expense_tab_provider.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/screens/create_trip_expense_record_screen.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/screens/trip_expense_detail_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseTabProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 19, top: 20, right: 19),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expenses',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontFamily: 'Inter',
                      height: 1.67,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Add filter functionality
                    },
                    icon: Icon(
                      Icons.filter_list,
                      color: Color(0xFF333333),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: AppGradients.primaryGradient55deg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.grey800,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                  tabs: const [Tab(text: 'Ongoing'), Tab(text: 'Completed')],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Ongoing Tab - Show trips or empty state
                  provider.ongoingTrips.isEmpty
                      ? _buildOngoingEmptyState(context, provider)
                      : _buildOngoingTripsList(context, provider),
                  // Completed Tab - Show completed trip list
                  _buildCompletedTripsList(context, provider),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Add Button
    );
  }

  Widget _buildOngoingEmptyState(
      BuildContext context, ExpenseTabProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Empty Icon
            Image.asset(
              'assets/images/journey_bro.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32),
            // Title Text
            const Text(
              'No ongoing trip expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Start a trip or add expenses to track spending in real time and split costs easily.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey500,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Create Trip Expense Record Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient55deg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                    builder: (context) => CreateTripExpenseRecordScreen(
                      onTripCreated: provider.addTrip,
                    ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                  ),
                  child: const Text(
                    'Create Trip Expense Record',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey100,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTripsList(
      BuildContext context, ExpenseTabProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...provider.ongoingTrips
              .map((trip) => _buildTripCard(context, trip))
              .toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompletedTripsList(
      BuildContext context, ExpenseTabProvider provider) {
    if (provider.completedTrips.isEmpty) {
      return _buildCompletedEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Completed trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          ...provider.completedTrips
              .map((trip) => _buildTripCard(context, trip, isCompleted: true))
              .toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompletedEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(
              Icons.check_circle_outline,
              size: 120,
              color: AppColors.grey500,
            ),
            const SizedBox(height: 24),
            const Text(
              'No completed trips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Mark an ongoing trip as completed to see it here.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.grey500,
                fontFamily: 'Inter',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _markTripAsCompleted(
      BuildContext context, TripExpenseRecord trip) {
    context.read<ExpenseTabProvider>().markTripAsCompleted(trip);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${trip.name} marked as completed'),
        backgroundColor: const Color(0xFF4CAF93),
      ),
    );
  }

  void _handleTripUpdated(
      BuildContext context, TripExpenseRecord updated) {
    context.read<ExpenseTabProvider>().updateTrip(updated);
  }

  Widget _buildTripCard(BuildContext context, TripExpenseRecord trip,
      {bool isCompleted = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripExpenseDetailScreen(
              trip: trip,
              onTripCompleted: isCompleted
                  ? null
                  : () => _markTripAsCompleted(context, trip),
              onTripUpdated: (updated) =>
                  _handleTripUpdated(context, updated),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.dateRange,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF999999),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (trip.budget != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${trip.budget!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
              ],
            ),
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF93).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF93),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

