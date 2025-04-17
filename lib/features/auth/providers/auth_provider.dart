import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firebase auth işlemleri burada yapılacak
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon için
      _user = UserModel(
        id: '1',
        name: 'Test User',
        email: email,
        role: UserRole.teacher,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
} 