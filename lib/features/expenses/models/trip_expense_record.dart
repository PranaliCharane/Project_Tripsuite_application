class TripExpenseRecord {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final double? budget;
  final DateTime createdAt;
  final String? coverImagePath;
  final List<String> memberIds;

  TripExpenseRecord({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.budget,
    DateTime? createdAt,
    this.coverImagePath,
    List<String>? memberIds,
  }) : createdAt = createdAt ?? DateTime.now(),
       memberIds = memberIds ?? [];

  bool get isOngoing {
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate!);
  }

  String get dateRange {
    if (endDate == null) {
      return _formatDate(startDate);
    }
    return '${_formatDate(startDate)} - ${_formatDate(endDate!)}';
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
}
