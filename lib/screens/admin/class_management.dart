import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class ClassManagement extends StatefulWidget {
  @override
  _ClassManagementState createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherIdController = TextEditingController();
  final _capacityController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sınıf Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<ClassRoom>>(
        stream: _firebaseService.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz sınıf bulunmuyor'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final classroom = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(classroom.name[0]),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(classroom.name),
                  subtitle: Text('Kapasite: ${classroom.capacity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showEditClassDialog(classroom),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _showDeleteConfirmation(classroom),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınıf Ekle'),
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
                    decoration: InputDecoration(labelText: 'Sınıf Adı'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _teacherIdController,
                    decoration: InputDecoration(labelText: 'Öğretmen ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _capacityController,
                    decoration: InputDecoration(labelText: 'Kapasite'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(value) == null) return 'Geçerli bir sayı giriniz';
                      return null;
                    },
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
            onPressed: _addClass,
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addClass() async {
    if (_formKey.currentState!.validate()) {
      try {
        final classroom = ClassRoom(
          id: _uuid.v4(),
          name: _nameController.text,
          teacherId: _teacherIdController.text,
          capacity: int.parse(_capacityController.text),
          studentIds: [], // Yeni sınıf için boş liste
        );

        await _firebaseService.addClass(classroom);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sınıf başarıyla eklendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showEditClassDialog(ClassRoom classroom) {
    _nameController.text = classroom.name;
    _teacherIdController.text = classroom.teacherId;
    _capacityController.text = classroom.capacity.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınıf Düzenle'),
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
                    decoration: InputDecoration(labelText: 'Sınıf Adı'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _teacherIdController,
                    decoration: InputDecoration(labelText: 'Öğretmen ID'),
                    validator: (value) =>
                        value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
                  ),
                  TextFormField(
                    controller: _capacityController,
                    decoration: InputDecoration(labelText: 'Kapasite'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Bu alan boş bırakılamaz';
                      if (int.tryParse(value) == null) return 'Geçerli bir sayı giriniz';
                      return null;
                    },
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
            onPressed: () => _updateClass(classroom.id),
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _updateClass(String classId) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseService.updateClass(classId, {
          'name': _nameController.text,
          'teacherId': _teacherIdController.text,
          'capacity': int.parse(_capacityController.text),
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sınıf başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(ClassRoom classroom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınıf Sil'),
        content: Text('${classroom.name} sınıfını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firebaseService.deleteClass(classroom.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sınıf başarıyla silindi')),
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
    _teacherIdController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
} 