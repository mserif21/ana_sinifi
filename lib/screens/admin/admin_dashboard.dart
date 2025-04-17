import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';
import 'teacher_management.dart';
import 'student_management.dart';
import 'parent_management.dart';
import 'class_management.dart';

class AdminDashboard extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Paneli'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildDashboardItem(
            context,
            'Öğretmen Yönetimi',
            Icons.school,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TeacherManagement()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Öğrenci Yönetimi',
            Icons.person,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentManagement()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Veli Yönetimi',
            Icons.people,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParentManagement()),
            ),
          ),
          _buildDashboardItem(
            context,
            'Sınıf Yönetimi',
            Icons.class_,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClassManagement()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Color(0xFF28293D), Color(0xFF2E3061)]
                  : [Color(0xFFFEE9CE), Color(0xFF555184)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
              ),
              SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Color(0xFFFEE9CE) : Color(0xFF2E3061),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Çıkış işlemi
  void _handleSignOut(BuildContext context) async {
    try {
      // Çıkış onayı dialog'u göster
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Çıkış Yap'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _authService.signOut();
        
        // Login ekranına yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );

        // Başarılı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Başarıyla çıkış yapıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Çıkış yapma hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 