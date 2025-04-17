import 'package:flutter/material.dart';
import 'admin/teacher_management.dart';
import 'admin/student_management.dart';
import 'admin/parent_management.dart';
import 'admin/class_management.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Müdür Paneli'),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode 
                ? Icons.light_mode 
                : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Çıkış işlemi
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          DashboardCard(
            title: 'Öğretmenler',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeacherManagement()),
              );
            },
          ),
          DashboardCard(
            title: 'Öğrenciler',
            icon: Icons.school,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentManagement()),
              );
            },
          ),
          DashboardCard(
            title: 'Veliler',
            icon: Icons.people,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ParentManagement()),
              );
            },
          ),
          DashboardCard(
            title: 'Sınıflar',
            icon: Icons.class_,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClassManagement()),
              );
            },
          ),
          DashboardCard(
            title: 'Duyurular',
            icon: Icons.announcement,
            onTap: () {
              // Duyuru yönetimi
            },
          ),
          DashboardCard(
            title: 'Raporlar',
            icon: Icons.bar_chart,
            onTap: () {
              // Raporlar
            },
          ),
          DashboardCard(
            title: 'Etkinlikler',
            icon: Icons.event,
            onTap: () {
              // Etkinlik yönetimi
            },
          ),
          DashboardCard(
            title: 'Ayarlar',
            icon: Icons.settings,
            onTap: () {
              // Sistem ayarları
            },
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 48, 
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 