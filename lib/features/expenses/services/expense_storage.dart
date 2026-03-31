import 'package:tripsuite_app_boilerplate/features/expenses/models/trip_expense.dart';

class ExpenseStorage {
  ExpenseStorage._();

  static final Map<String, List<TripExpense>> _expensesByTripId = {};

  static List<TripExpense> getExpenses(String tripId) {
    return List.unmodifiable(_expensesByTripId[tripId] ?? []);
  }

  static void addExpense(String tripId, TripExpense expense) {
    final expenses = _expensesByTripId[tripId];
    if (expenses == null) {
      _expensesByTripId[tripId] = [expense];
    } else {
      expenses.add(expense);
    }
  }

  static void saveExpenses(String tripId, List<TripExpense> expenses) {
    _expensesByTripId[tripId] = List.from(expenses);
  }
}
