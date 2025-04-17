import 'package:flutter/material.dart';
import '../../models/parent_model.dart';
import '../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class ParentManagement extends StatefulWidget {
  @override
  _ParentManagementState createState() => _ParentManagementState();
}

class _ParentManagementState extends State<ParentManagement> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veli Yönetimi'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParentDialog(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Parent>>(
        stream: _firebaseService.getParents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz veli bulunmuyor'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final parent = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(child: Text(parent.name[0])),
                title: Text(parent.name),
                subtitle: Text('${parent.relation} - ${parent.phone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditParentDialog(parent),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(parent),
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

  void _showAddParentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veli Ekle'),
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
                    controller: _relationController,
                    decoration: InputDecoration(labelText: 'Yakınlık (Anne/Baba/Vasi)'),
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
            onPressed: _addParent,
            child: Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _addParent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final parent = Parent(
          id: _uuid.v4(),
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          studentIds: [], // Yeni veli için boş liste
          relation: _relationController.text,
        );

        await _firebaseService.addParent(parent);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veli başarıyla eklendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showEditParentDialog(Parent parent) {
    _nameController.text = parent.name;
    _emailController.text = parent.email;
    _phoneController.text = parent.phone;
    _relationController.text = parent.relation;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veli Düzenle'),
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
                    controller: _relationController,
                    decoration: InputDecoration(labelText: 'Yakınlık (Anne/Baba/Vasi)'),
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
            onPressed: () => _updateParent(parent.id),
            child: Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _updateParent(String parentId) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseService.updateParent(parentId, {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'relation': _relationController.text,
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veli başarıyla güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(Parent parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veli Sil'),
        content: Text('${parent.name} isimli veliyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firebaseService.deleteParent(parent.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veli başarıyla silindi')),
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
    _emailController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }
} 