import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import '../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class TeacherManagement extends StatefulWidget {
  @override
  _TeacherManagementState createState() => _TeacherManagementState();
}

class _TeacherManagementState extends State<TeacherManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _branchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğretmen Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTeacherDialog();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Teacher>>(
        stream: _firebaseService.getTeachers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz öğretmen bulunmuyor'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final teacher = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(teacher.name[0]),
                ),
                title: Text(teacher.name),
                subtitle: Text(teacher.branch),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditTeacherDialog(teacher),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(teacher),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğretmen Ekle'),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Ad Soyad'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'E-posta'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Telefon'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _branchController,
                    decoration: InputDecoration(labelText: 'Branş'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _addTeacher,
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addTeacher() async {
    if (_formKey.currentState!.validate()) {
      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text;

        // Şifre kontrolü
        if (password.length < 6) {
          throw Exception('Şifre en az 6 karakter olmalıdır');
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Öğretmen hesabı oluşturuluyor...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        // Firebase Authentication hesabı oluştur
        final userId = await _firebaseService.createTeacherAccount(email, password);

        if (userId != null) {
          // Öğretmen bilgilerini Firestore'a kaydet
          final teacher = Teacher(
            id: userId,
            name: _nameController.text,
            email: email.contains('@') ? email : '$email@anasinifi.com',
            phone: _phoneController.text,
            branch: _branchController.text,
            classIds: [],
            role: 'teacher',
          );

          await _firebaseService.addTeacher(teacher);

          // Dialogları kapat
          Navigator.of(context).pop(); // Loading dialog
          Navigator.of(context).pop(); // Add teacher dialog

          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Öğretmen başarıyla eklendi'),
                  Text('Email: ${teacher.email}'),
                  Text('Şifre: $password'),
                ],
              ),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.green,
            ),
          );

          // Formları temizle
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _phoneController.clear();
          _branchController.clear();
        }
      } catch (e) {
        // Loading dialogu kapat
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showEditTeacherDialog(Teacher teacher) {
    _nameController.text = teacher.name;
    _emailController.text = teacher.email;
    _phoneController.text = teacher.phone;
    _branchController.text = teacher.branch;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğretmen Düzenle'),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Ad Soyad'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'E-posta'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Telefon'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _branchController,
                    decoration: InputDecoration(labelText: 'Branş'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _updateTeacher(teacher.id),
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _updateTeacher(String teacherId) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseService.updateTeacher(teacherId, {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'branch': _branchController.text,
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğretmen başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğretmen Sil'),
        content: Text('${teacher.name} isimli öğretmeni silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firebaseService.deleteTeacher(teacher.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Öğretmen başarıyla silindi')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _branchController.dispose();
    super.dispose();
  }
} 