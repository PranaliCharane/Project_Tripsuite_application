import 'package:flutter/material.dart';
import '../models/trip_expense_record.dart';

/// Manages the state for the expense tab, tracking ongoing and completed trips.
class ExpenseTabProvider extends ChangeNotifier {
  final List<TripExpenseRecord> _ongoingTrips;
  final List<TripExpenseRecord> _completedTrips;

  ExpenseTabProvider({
    List<TripExpenseRecord>? initialOngoing,
    List<TripExpenseRecord>? initialCompleted,
  })  : _ongoingTrips = List.from(initialOngoing ?? []),
        _completedTrips = List.from(initialCompleted ?? []);

  List<TripExpenseRecord> get ongoingTrips => List.unmodifiable(_ongoingTrips);
  List<TripExpenseRecord> get completedTrips => List.unmodifiable(_completedTrips);

  void addTrip(TripExpenseRecord trip) {
    final target = trip.isOngoing ? _ongoingTrips : _completedTrips;
    target.insert(0, trip);
    notifyListeners();
  }

  void markTripAsCompleted(TripExpenseRecord trip) {
    final index = _ongoingTrips.indexWhere((item) => item.id == trip.id);
    if (index == -1) return;
    _ongoingTrips.removeAt(index);
    _completedTrips.insert(0, trip);
    notifyListeners();
  }

  void updateTrip(TripExpenseRecord updated) {
    _ongoingTrips.removeWhere((item) => item.id == updated.id);
    _completedTrips.removeWhere((item) => item.id == updated.id);

    if (updated.isOngoing) {
      _ongoingTrips.insert(0, updated);
    } else {
      _completedTrips.insert(0, updated);
    }

    notifyListeners();
  }
}
