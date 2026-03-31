import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsuite_app_boilerplate/features/auth/services/storage_service.dart';


class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<void> createHotel({
    required Map<String, dynamic> data,
    required List<File> imageFiles,
  }) async {
    final docRef = _firestore.collection('hotels').doc();

    final uploadFutures = imageFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      return _storageService.uploadHotelImage(file, docRef.id, index: index);
    });
    final results = await Future.wait(uploadFutures);
    final imageUrls = results.where((url) => url.isNotEmpty).toList();

    final payload = {
      ...data,
      if (imageUrls.isNotEmpty) 'image': imageUrls.first,
      'images': imageUrls,
    };

    await docRef.set(payload);
  }

  /// Retrieves all hotel documents from Firestore and includes their IDs.
  /// Fetches all hotels or only those whose `location` contains [locationQuery].
  Future<List<Map<String, dynamic>>> getHotels({String? location}) async {
    final snapshot = await _firestore.collection('hotels').get();

    final queryTokens = <String>{};
    final cleanedLocation = location?.trim() ?? '';
    if (cleanedLocation.isNotEmpty) {
      queryTokens.add(cleanedLocation.toLowerCase());
      for (final part in cleanedLocation.split(',')) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty) {
          queryTokens.add(trimmed.toLowerCase());
        }
      }
    }

    final docs = queryTokens.isEmpty
        ? snapshot.docs
        : snapshot.docs.where((doc) {
            final locationField = ((doc.data()['location'] as String?) ?? '')
                .toLowerCase();
            return queryTokens
                .any((token) => locationField.contains(token));
          }).toList();

    return docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }
}
