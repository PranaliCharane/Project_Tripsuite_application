import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/helper/shared_preferences_helper.dart';

/// Provides the current profile image file and persists the path.
class ProfileImageProvider extends ChangeNotifier {
  File? _imageFile;

  ProfileImageProvider() {
    _loadStoredImage();
  }

  File? get imageFile => _imageFile;

  Future<void> _loadStoredImage() async {
    final storedPath = await SharedPreferencesHelper.getProfileImagePath();
    if (storedPath != null && storedPath.isNotEmpty) {
      final file = File(storedPath);
      if (await file.exists()) {
        _imageFile = file;
        notifyListeners();
        return;
      }
    }
    _imageFile = null;
    notifyListeners();
  }

  Future<void> updateProfileImage(File file) async {
    _imageFile = file;
    notifyListeners();
    await SharedPreferencesHelper.saveProfileImagePath(file.path);
  }

  Future<void> clearProfileImage() async {
    _imageFile = null;
    notifyListeners();
    await SharedPreferencesHelper.saveProfileImagePath('');
  }
}
