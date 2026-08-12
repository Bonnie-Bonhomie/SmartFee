import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// Manages the optional local user/student profile.
/// Registration here is purely local -- no account or server is created.
class UserProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isRegistered => _profile != null;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    _profile = await _storage.loadProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String fullName,
    required String studentName,
    required String className,
    String? email,
    String? phone,
  }) async {
    _profile = UserProfile(
      fullName: fullName,
      studentName: studentName,
      className: className,
      email: email,
      phone: phone,
    );
    await _storage.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> clearProfile() async {
    _profile = null;
    await _storage.clearProfile();
    notifyListeners();
  }
}
