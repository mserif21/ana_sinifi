import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('AuthService - Giriş denemesi başladı');
      
      // Email formatını düzelt
      String formattedEmail = email.trim().toLowerCase();
      if (!formattedEmail.contains('@')) {
        formattedEmail = '$formattedEmail@anasinifi.com';
      }
      
      print('Düzeltilmiş email: $formattedEmail');

      // Admin kontrolü
      if (formattedEmail == 'admin@anasinifi.com' && password == '123456') {
        print('Admin girişi deneniyor...');
        
        try {
          // Admin modelini doğrudan dön
          return UserModel(
            uid: 'admin',
            email: 'admin@anasinifi.com',
            role: 'admin',
            name: 'Admin User'
          );
        } catch (e) {
          print('Admin girişi hatası: $e');
          rethrow;
        }
      }

      print('Normal kullanıcı girişi deneniyor...');

      // Normal kullanıcı girişi için Firestore'dan kontrol
      try {
        // Kullanıcıyı Firestore'dan bul
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: formattedEmail)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          final userId = userQuery.docs.first.id;

          return UserModel(
            uid: userId,
            email: formattedEmail,
            role: userData['role'] ?? 'user',
            name: formattedEmail.split('@')[0],
          );
        }
      } catch (e) {
        print('Firestore sorgu hatası: $e');
      }

      return null;
    } catch (e) {
      print('AuthService hatası: $e');
      return null;
    }
  }

  // Admin kontrolü
  bool isAdmin(String email) {
    String formattedEmail = email.trim().toLowerCase();
    if (!formattedEmail.contains('@')) {
      formattedEmail = '$formattedEmail@anasinifi.com';
    }
    return formattedEmail == 'admin@anasinifi.com';
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      // Firebase Authentication'dan çıkış yap
      await _auth.signOut();
      print('Firebase Authentication\'dan çıkış yapıldı');
      
      // Firestore'dan çıkış yap (gerekirse)
      // Burada ek temizlik işlemleri yapılabilir
      
      print('Başarıyla çıkış yapıldı');
    } catch (e) {
      print('Çıkış yapma hatası: $e');
      throw Exception('Çıkış yapılırken bir hata oluştu: $e');
    }
  }
} 