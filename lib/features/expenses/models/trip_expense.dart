import 'package:flutter/material.dart';

class TripExpense {
  final String id;
  final String tripId;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String paidBy; // member ID who paid
  final List<String> sharedBy; // member IDs who share this expense

  TripExpense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paidBy,
    List<String>? sharedBy,
  }) : sharedBy = sharedBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'paidBy': paidBy,
      'sharedBy': sharedBy,
    };
  }

  factory TripExpense.fromJson(Map<String, dynamic> json) {
    return TripExpense(
      id: json['id'],
      tripId: json['tripId'],
      title: json['title'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      paidBy: json['paidBy'],
      sharedBy: List<String>.from(json['sharedBy'] ?? []),
    );
  }
}

enum ExpenseCategory {
  stay('Stay expense', 0xFF379DD3),
  food('Food expense', 0xFFE91E63),
  travel('Travel expense', 0xFF4CAF93),
  activity('Activity expenses', 0xFFFF9800),
  miscellaneous('Miscellaneous', 0xFF03A9F4);

  final String label;
  final int colorValue;

  const ExpenseCategory(this.label, this.colorValue);

  Color get color => Color(colorValue);
}
