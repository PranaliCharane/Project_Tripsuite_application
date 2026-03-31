import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadHotelImage(
    File file,
    String hotelId, {
    int? index,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final indexSuffix = index != null ? '_$index' : '';
    final fileName = '$hotelId$indexSuffix\_$timestamp.jpg';
    final ref = _storage.ref().child('hotels/$hotelId/$fileName');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> deleteHotelImage(String hotelId) async {
    final ref = _storage.ref().child('hotels/$hotelId.jpg');
    await ref.delete();
  }
}
