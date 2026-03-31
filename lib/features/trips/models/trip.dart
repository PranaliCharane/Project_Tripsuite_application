import 'package:tripsuite_app_boilerplate/features/homescreen/models/post_details.dart';

class Trip {
  final String id;
  final PostDetails postDetails;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adultCount;
  final int infantCount;
  final double totalAmount;
  final DateTime bookingDate;

  Trip({
    required this.id,
    required this.postDetails,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adultCount,
    required this.infantCount,
    required this.totalAmount,
    DateTime? bookingDate,
  }) : bookingDate = bookingDate ?? DateTime.now();

  int get nights {
    return checkOutDate.difference(checkInDate).inDays;
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
    return '${date.day} ${months[date.month - 1]}';
  }

  String get dateRange {
    return '${_formatDate(checkInDate)} - ${_formatDate(checkOutDate)}';
  }

  String get guestCount {
    final parts = <String>[];
    if (adultCount > 0) {
      parts.add('$adultCount Adult${adultCount > 1 ? 's' : ''}');
    }
    if (infantCount > 0) {
      parts.add('$infantCount Infant${infantCount > 1 ? 's' : ''}');
    }
    return parts.join(', ');
  }
}
