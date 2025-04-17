import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'admin/admin_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode 
              ? [Color(0xFF28293D), Color(0xFF2E3061)]
              : [Color(0xFFFEE9CE), Color(0xFF555184)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tema değiştirme butonu
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
                      ),
                      onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.1),
                  
                  // Başlık
                  Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
                    ),
                  ),
                  
                  Text(
                    'Devam etmek için giriş yapın',
                    style: TextStyle(
                      fontSize: 16,
                      color: (isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061)).withOpacity(0.7),
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.08),
                  
                  // Giriş formu
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    isDarkMode: isDarkMode,
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Şifre',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isDarkMode: isDarkMode,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Giriş butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
                        foregroundColor: isDarkMode ? Color(0xFF2E3061) : Color(0xFFFEE9CE),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _handleLogin(context),
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF555184).withOpacity(0.5) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Color(0xFFFEE9CE).withOpacity(0.1) : Color(0xFF2E3061).withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF28293D),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: (isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF28293D)).withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      print('Giriş denemesi - Email: $email, Password: $password');

      final userModel = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      
      print('UserModel: $userModel');

      if (userModel != null) {
        print('Kullanıcı rolü: ${userModel.role}');
        
        if (userModel.role == 'admin') {
          print('Admin girişi başarılı');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else if (userModel.role == 'teacher') {
          print('Öğretmen girişi başarılı');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeacherDashboard()),
          );
        } else {
          print('Geçersiz rol: ${userModel.role}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Geçersiz kullanıcı rolü'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Giriş başarısız - UserModel null');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geçersiz kullanıcı adı veya şifre'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Giriş hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 