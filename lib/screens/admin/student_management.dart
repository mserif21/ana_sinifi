import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class StudentManagement extends StatefulWidget {
  @override
  _StudentManagementState createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classIdController = TextEditingController();
  final _parentIdController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _classNameController = TextEditingController();
  final _addressController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = Uuid();
  DateTime? _selectedBirthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğrenci Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Student>>(
        stream: _firebaseService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz öğrenci bulunmuyor'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final student = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(child: Text(student.name[0])),
                title: Text(student.name),
                subtitle: Text('Kan Grubu: ${student.bloodType}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditStudentDialog(student),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(student),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _showAddStudentDialog() {
    _selectedBirthDate = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğrenci Ekle'),
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
                    controller: _classIdController,
                    decoration: InputDecoration(labelText: 'Sınıf ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _parentIdController,
                    decoration: InputDecoration(labelText: 'Veli ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: InputDecoration(labelText: 'Kan Grubu'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: InputDecoration(labelText: 'Alerjiler (virgülle ayırın)'),
                  ),
                  TextFormField(
                    controller: _parentNameController,
                    decoration: InputDecoration(labelText: 'Veli Adı'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _classNameController,
                    decoration: InputDecoration(labelText: 'Sınıf Adı'),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Adres'),
                    maxLines: 2,
                  ),
                  ListTile(
                    title: Text('Doğum Tarihi'),
                    subtitle: Text(_selectedBirthDate?.toString().split(' ')[0] ?? 'Seçilmedi'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
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
            onPressed: _addStudent,
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          id: _uuid.v4(),
          name: _nameController.text,
          parentName: _parentNameController.text,
          className: _classNameController.text,
          classId: _classIdController.text,
          parentId: _parentIdController.text,
          birthDate: _selectedBirthDate ?? DateTime.now(),
          bloodType: _bloodTypeController.text,
          allergies: _allergiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          address: _addressController.text,
        );

        await _firebaseService.addStudent(student);
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğrenci başarıyla eklendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showEditStudentDialog(Student student) {
    _nameController.text = student.name;
    _classIdController.text = student.classId;
    _parentIdController.text = student.parentId;
    _bloodTypeController.text = student.bloodType;
    _allergiesController.text = student.allergies.join(', ');
    _selectedBirthDate = student.birthDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğrenci Düzenle'),
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
                    controller: _classIdController,
                    decoration: InputDecoration(labelText: 'Sınıf ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _parentIdController,
                    decoration: InputDecoration(labelText: 'Veli ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: InputDecoration(labelText: 'Kan Grubu'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _allergiesController,
                    decoration: InputDecoration(labelText: 'Alerjiler (virgülle ayırın)'),
                  ),
                  ListTile(
                    title: Text('Doğum Tarihi'),
                    subtitle: Text(_selectedBirthDate?.toString().split(' ')[0] ?? 'Seçilmedi'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
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
            onPressed: () => _updateStudent(student.id),
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _updateStudent(String studentId) async {
    if (_formKey.currentState!.validate() && _selectedBirthDate != null) {
      try {
        await _firebaseService.updateStudent(studentId, {
          'name': _nameController.text,
          'classId': _classIdController.text,
          'parentId': _parentIdController.text,
          'birthDate': _selectedBirthDate!.toIso8601String(),
          'bloodType': _bloodTypeController.text,
          'allergies': _allergiesController.text.split(',').map((e) => e.trim()).toList(),
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öğrenci başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Öğrenci Sil'),
        content: Text('${student.name} isimli öğrenciyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firebaseService.deleteStudent(student.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Öğrenci başarıyla silindi')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hata: $e')),
                );
              }
            },
            child: Text('Sil'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classIdController.dispose();
    _parentIdController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _parentNameController.dispose();
    _classNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
} 