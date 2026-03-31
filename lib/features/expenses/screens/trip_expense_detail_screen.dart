import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/models/trip_expense_record.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/models/trip_expense.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/services/expense_storage.dart';

class TripExpenseDetailScreen extends StatefulWidget {
  final TripExpenseRecord trip;
  final VoidCallback? onTripCompleted;
  final ValueChanged<TripExpenseRecord>? onTripUpdated;

  const TripExpenseDetailScreen({
    super.key,
    required this.trip,
    this.onTripCompleted,
    this.onTripUpdated,
  });

  @override
  State<TripExpenseDetailScreen> createState() =>
      _TripExpenseDetailScreenState();
}

class _TripExpenseDetailScreenState extends State<TripExpenseDetailScreen> {
  // Load expenses from storage on init
  late List<TripExpense> expenses;
  late TripExpenseRecord _currentTrip;

  // Sample member data
  final Map<String, String> members = {
    'current_user': 'Rupesh',
    'member1': 'Ayush',
    'member2': 'Ashish',
  };
  List<String> get _tripMembers =>
      _currentTrip.memberIds.isNotEmpty ? _currentTrip.memberIds : ['current_user'];

  String _memberDisplayName(String id) => members[id] ?? id;

  void _persistExpenses() {
    ExpenseStorage.saveExpenses(_currentTrip.id, expenses);
  }

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
    // Load expenses from storage
    expenses = List.from(ExpenseStorage.getExpenses(_currentTrip.id));
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<PieChartSectionData> get pieChartData {
    // Return empty list if no expenses
    if (expenses.isEmpty || totalExpenses == 0) {
      return [];
    }

    final totals = categoryTotals;

    // Map categories to their specific colors in order
    final categoryColorMap = {
      'Stay expense': const Color(0xFF379DD3), // Blue
      'Food expense': const Color(0xFFE91E63), // Red
      'Travel expense': const Color(0xFF4CAF93), // Light Green
      'Activity expenses': const Color(0xFFFF9800), // Orange
      'Miscellaneous': const Color(0xFF03A9F4), // Light Blue
    };

    // Order categories as per design
    final orderedCategories = [
      'Stay expense',
      'Food expense',
      'Travel expense',
      'Activity expenses',
      'Miscellaneous',
    ];

    return orderedCategories
        .where(
          (category) => totals.containsKey(category) && totals[category]! > 0,
        )
        .map((category) {
          final value = totals[category]!;
          final percentage = (value / totalExpenses) * 100;
          final color = categoryColorMap[category]!;

          return PieChartSectionData(
            value: value,
            title: percentage > 8 ? '${percentage.toStringAsFixed(0)}%' : '',
            color: color,
            radius: 45,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
            showTitle: percentage > 8,
            titlePositionPercentageOffset: 0.6,
          );
        })
        .toList();
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateRange() {
    if (_currentTrip.endDate == null) {
      return _formatDate(_currentTrip.startDate);
    }
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
    return '${months[_currentTrip.startDate.month - 1]} ${_currentTrip.startDate.day}-${_currentTrip.endDate!.day} ${_currentTrip.startDate.year}';
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExpenseForm(
        trip: _currentTrip,
        members: members,
        onExpenseAdded: (newExpense) {
          setState(() {
            expenses.add(newExpense);
            ExpenseStorage.addExpense(_currentTrip.id, newExpense);
          });
        },
      ),
    );
  }

  void _showEditTripDialog() {
    final nameController = TextEditingController(text: _currentTrip.name);
    DateTime editStart = _currentTrip.startDate;
    DateTime? editEnd = _currentTrip.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickStartDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: editStart,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setModalState(() {
                editStart = picked;
                if (editEnd != null && editEnd!.isBefore(editStart)) {
                  editEnd = editStart;
                }
              });
            }
          }

          Future<void> pickEndDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: editEnd ?? editStart,
              firstDate: editStart,
              lastDate: editStart.add(const Duration(days: 365)),
            );
            if (picked != null) {
              setModalState(() {
                editEnd = picked;
              });
            }
          }

          void saveChanges() {
            final updatedName = nameController.text.trim();
            if (updatedName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trip name cannot be empty'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final updatedTrip = TripExpenseRecord(
              id: _currentTrip.id,
              name: updatedName,
              startDate: editStart,
              endDate: editEnd,
              budget: _currentTrip.budget,
              createdAt: _currentTrip.createdAt,
              coverImagePath: _currentTrip.coverImagePath,
              memberIds: List.from(_currentTrip.memberIds),
            );

            _handleTripUpdated(updatedTrip);
            Navigator.pop(context);
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                          fontFamily: 'Inter',
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF999999),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Trip name',
                      hintText: 'Nepal Adventure',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF379DD3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(editStart),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const Text(
                                'Start date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF999999),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                editEnd == null
                                    ? 'Add end date'
                                    : _formatDate(editEnd!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const Text(
                                'End date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF999999),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient55deg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() => nameController.dispose());
  }

  void _handleTripUpdated(TripExpenseRecord updated) {
    setState(() {
      _currentTrip = updated;
    });
    widget.onTripUpdated?.call(updated);
  }

  void _showExpenseEditDialog(TripExpense expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController =
        TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Expense Title',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.trim(),
                );
                if (titleController.text.trim().isEmpty || amount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid title and amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  final index =
                      expenses.indexWhere((item) => item.id == expense.id);
                  if (index >= 0) {
                    expenses[index] = TripExpense(
                      id: expense.id,
                      tripId: expense.tripId,
                      title: titleController.text.trim(),
                      category: expense.category,
                      amount: amount,
                      date: expense.date,
                      paidBy: expense.paidBy,
                      sharedBy: expense.sharedBy,
                    );
                    _persistExpenses();
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense updated'),
                    backgroundColor: Color(0xFF4CAF93),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _markTripCompleted() {
    widget.onTripCompleted?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
        ),
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Trip Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient55deg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF379DD3).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Trip Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              image: _currentTrip.coverImagePath != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        File(_currentTrip.coverImagePath!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          child: _currentTrip.coverImagePath == null
                              ? const Icon(
                                  Icons.image_outlined,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                _currentTrip.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateRange(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _showEditTripDialog,
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price Breakdown Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Break down',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                            fontFamily: 'Inter',
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Navigate to detailed breakdown
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF999999),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Donut Chart with Center Text
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5E5E5),
                          width: 1,
                        ),
                      ),
                      child:
                          expenses.isEmpty || totalExpenses == 0
                              ? Column(
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(
                                    Icons.pie_chart_outline,
                                    size: 64,
                                    color: const Color(
                                      0xFF999999,
                                    ).withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No expenses yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF999999),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Add expenses to see the chart',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF999999),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              )
                              : Column(
                                children: [
                                  // Chart with center text
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: ClipRect(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Center(
                                            child: PieChart(
                                              PieChartData(
                                                sections: pieChartData,
                                                centerSpaceRadius: 35,
                                                sectionsSpace: 2,
                                                pieTouchData: PieTouchData(
                                                  touchCallback: (
                                                    FlTouchEvent event,
                                                    pieTouchResponse,
                                                  ) {
                                                    // Handle touch if needed
                                                  },
                                                ),
                                              ),
                                              key: ValueKey(
                                                '${expenses.length}_${totalExpenses}',
                                              ), // Force rebuild on data change
                                            ),
                                          ),
                                          // Center text
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF999999),
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '₹${totalExpenses.toStringAsFixed(0)}',
                                                key: ValueKey(
                                                  totalExpenses,
                                                ), // Force rebuild on total change
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF333333),
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Legend below chart
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      _buildLegendItem(
                                        'Stay expense',
                                        const Color(0xFF379DD3),
                                      ),
                                      _buildLegendItem(
                                        'Food expense',
                                        const Color(0xFFE91E63),
                                      ),
                                      _buildLegendItem(
                                        'Travel expense',
                                        const Color(0xFF4CAF93),
                                      ),
                                      _buildLegendItem(
                                        'Activity expenses',
                                        const Color(0xFFFF9800),
                                      ),
                                      _buildLegendItem(
                                        'Miscellaneous',
                                        const Color(0xFF03A9F4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                    ),
                    const SizedBox(height: 24),

                    // Total Members and Share Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total members and share',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                            fontFamily: 'Inter',
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Navigate to member details
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF999999),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Member Cards
                    ..._buildMemberCards(),
                    if (expenses.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSettlementsSection(),
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 24),

                    // Expense History Section
                    const Text(
                      'Expense history',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Group expenses by date
                    ..._buildExpenseHistory(),
                    if (widget.onTripCompleted != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _markTripCompleted,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4CAF93)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: const Color(0xFF4CAF93),
                            ),
                            child: const Text(
                              'Mark trip as completed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient55deg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMemberCards() {
    final Map<String, double> memberShares = {};
    final Map<String, double> memberPaid = {};

    for (var expense in expenses) {
      final sharePerPerson = expense.amount / expense.sharedBy.length;
      for (var memberId in expense.sharedBy) {
        memberShares[memberId] =
            (memberShares[memberId] ?? 0) + sharePerPerson;
      }
      memberPaid[expense.paidBy] =
          (memberPaid[expense.paidBy] ?? 0) + expense.amount;
    }

    final memberIds = _tripMembers;

    return memberIds.map((memberId) {
      final share = memberShares[memberId] ?? 0;
      final paid = memberPaid[memberId] ?? 0;
      final balance = paid - share;
      final isPositive = balance >= 0;
      final name = _memberDisplayName(memberId);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paid ₹${paid.toStringAsFixed(0)} • Share ₹${share.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isPositive
                    ? const Color(0xFF4CAF93).withOpacity(0.15)
                    : const Color(0xFFE91E63).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isPositive ? '+' : ''}₹${balance.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive
                      ? const Color(0xFF4CAF93)
                      : const Color(0xFFE91E63),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<_Settlement> _computeSettlements() {
    final balances = <String, double>{};
    for (final memberId in _tripMembers) {
      balances[memberId] = 0.0;
    }

    for (final expense in expenses) {
      final sharedBy = expense.sharedBy.isNotEmpty
          ? expense.sharedBy
          : [expense.paidBy];
      final sharePerPerson = sharedBy.isNotEmpty
          ? expense.amount / sharedBy.length
          : 0.0;

      for (final memberId in sharedBy) {
        balances[memberId] = (balances[memberId] ?? 0) - sharePerPerson;
      }

      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;
    }

    final debtors = balances.entries
        .where((entry) => entry.value < -0.01)
        .map((entry) => _PersonBalance(entry.key, -entry.value))
        .toList();

    final creditors = balances.entries
        .where((entry) => entry.value > 0.01)
        .map((entry) => _PersonBalance(entry.key, entry.value))
        .toList();

    final settlements = <_Settlement>[];
    int debtorIndex = 0;
    int creditorIndex = 0;

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];
      final creditor = creditors[creditorIndex];
      final amount = min(debtor.amount, creditor.amount);

      settlements.add(_Settlement(
        from: debtor.id,
        to: creditor.id,
        amount: amount,
      ));

      debtor.amount -= amount;
      creditor.amount -= amount;

      if (debtor.amount <= 0.01) {
        debtorIndex++;
      }
      if (creditor.amount <= 0.01) {
        creditorIndex++;
      }
    }

    return settlements;
  }

  Widget _buildSettlementsSection() {
    final settlements = _computeSettlements();
    final totalAmount = settlements.fold<double>(
      0,
      (prev, item) => prev + item.amount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settle up',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        if (settlements.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Everyone is all settled.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          )
        else ...[
          _buildSettlementStats(settlements.length, totalAmount),
          const SizedBox(height: 12),
          ...settlements.map((settlement) => _buildSettlementRow(settlement)),
        ],
      ],
    );
  }

  Widget _buildSettlementStats(int count, double totalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Members to settle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF999999),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total share',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF999999),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementRow(_Settlement settlement) {
    final amountColor = Colors.grey.shade800;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_memberDisplayName(settlement.from)} pays ${_memberDisplayName(settlement.to)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_memberDisplayName(settlement.from)} ➜ ${_memberDisplayName(settlement.to)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '₹${settlement.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseHistory() {
    // If no expenses, show empty state
    if (expenses.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: const Color(0xFF999999).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No expenses yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // Group expenses by date
    final Map<String, List<TripExpense>> groupedExpenses = {};
    for (var expense in expenses) {
      final dateKey = _formatDate(expense.date);
      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    final sortedDates =
        groupedExpenses.keys.toList()..sort((a, b) {
          final dateA = groupedExpenses[a]!.first.date;
          final dateB = groupedExpenses[b]!.first.date;
          return dateB.compareTo(dateA);
        });

    return sortedDates.map((dateKey) {
      final dateExpenses = groupedExpenses[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF999999),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            ...dateExpenses.map(
              (expense) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF999999),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${expense.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                            fontFamily: 'Inter',
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showExpenseEditDialog(expense),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF379DD3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList();
  }
}

class _Settlement {
  final String from;
  final String to;
  final double amount;

  _Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class _PersonBalance {
  final String id;
  double amount;

  _PersonBalance(this.id, this.amount);
}

class _AddExpenseForm extends StatefulWidget {
  final TripExpenseRecord trip;
  final Map<String, String> members;
  final void Function(TripExpense newExpense) onExpenseAdded;

  const _AddExpenseForm({
    required this.trip,
    required this.members,
    required this.onExpenseAdded,
  });

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late final List<String> _initialMemberIds;
  late String _selectedCategory;
  late String _selectedPaidBy;
  late DateTime _selectedDate;
  late Set<String> _selectedMembers;

  @override
  void initState() {
    super.initState();
    _initialMemberIds = widget.trip.memberIds.isNotEmpty
        ? widget.trip.memberIds
        : ['current_user'];
    _selectedPaidBy = _initialMemberIds.first;
    _selectedCategory = 'Stay expense';
    _selectedDate = DateTime.now();
    _selectedMembers = Set.from(_initialMemberIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final firstDate = widget.trip.startDate;
    final proposedLastDate = widget.trip.endDate ??
        DateTime.now().add(
          const Duration(days: 365),
        );
    final lastDate = proposedLastDate.isBefore(firstDate)
        ? firstDate
        : proposedLastDate;
    var initialDate = _selectedDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an expense title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newExpense = TripExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tripId: widget.trip.id,
      title: title,
      category: _selectedCategory,
      amount: amount,
      date: _selectedDate,
      paidBy: _selectedPaidBy,
      sharedBy: _selectedMembers.toList(),
    );

    widget.onExpenseAdded(newExpense);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: Color(0xFF4CAF93),
      ),
    );

    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                      fontFamily: 'Inter',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF999999),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Expense Title',
                  hintText: 'e.g., Hotel booking',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF379DD3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF379DD3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF379DD3),
                      width: 2,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Stay expense',
                    child: Text('Stay expense'),
                  ),
                  DropdownMenuItem(
                    value: 'Food expense',
                    child: Text('Food expense'),
                  ),
                  DropdownMenuItem(
                    value: 'Travel expense',
                    child: Text('Travel expense'),
                  ),
                  DropdownMenuItem(
                    value: 'Activity expenses',
                    child: Text('Activity expenses'),
                  ),
                  DropdownMenuItem(
                    value: 'Miscellaneous',
                    child: Text('Miscellaneous'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF333333),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF999999),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedPaidBy,
                decoration: InputDecoration(
                  labelText: 'Paid By',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF379DD3),
                      width: 2,
                    ),
                  ),
                ),
                items: _initialMemberIds.map((memberId) {
                      return DropdownMenuItem(
                        value: memberId,
                        child: Text(widget.members[memberId] ?? memberId),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaidBy = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Shared By',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _initialMemberIds.map((memberId) {
                  final isSelected = _selectedMembers.contains(memberId);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(widget.members[memberId] ?? memberId),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMembers.add(memberId);
                        } else {
                          _selectedMembers.remove(memberId);
                        }
                      });
                    },
                    selectedColor: const Color(
                      0xFF379DD3,
                    ).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF379DD3),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF379DD3)
                          : const Color(0xFF666666),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient55deg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
