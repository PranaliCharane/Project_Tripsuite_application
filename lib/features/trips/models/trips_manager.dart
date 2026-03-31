import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trip.dart';

class TripsManager extends ChangeNotifier {
  final List<Trip> _trips = [];

  List<Trip> get trips => List.unmodifiable(_trips);

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  void removeTrip(String tripId) {
    _trips.removeWhere((trip) => trip.id == tripId);
    notifyListeners();
  }

  bool get hasTrips => _trips.isNotEmpty;
}

