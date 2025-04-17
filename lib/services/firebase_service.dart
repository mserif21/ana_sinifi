import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import '../models/parent_model.dart';
import '../models/class_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Öğretmen hesabı oluşturma
  Future<String?> createTeacherAccount(String email, String password) async {
    try {
      // Email formatını kontrol et
      String formattedEmail = email.trim();
      if (!formattedEmail.contains('@')) {
        formattedEmail = '$formattedEmail@anasinifi.com';
      }

      print('Öğretmen hesabı oluşturuluyor: $formattedEmail');

      // Yeni öğretmen hesabı oluştur
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: formattedEmail,
        password: password,
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        print('Firebase Auth hesabı oluşturuldu: $userId');

        // Firestore'a öğretmen kaydı ekle
        await _firestore.collection('users').doc(userId).set({
          'role': 'teacher',
          'email': formattedEmail,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('Firestore kaydı oluşturuldu');
        return userId;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth hatası: ${e.code} - ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Beklenmeyen hata: $e');
      throw Exception('Öğretmen hesabı oluşturulamadı');
    }
  }

  // Giriş kontrolü
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'];
      }
      return null;
    } catch (e) {
      print('Rol kontrolü hatası: $e');
      return null;
    }
  }

  // Öğretmen işlemleri
  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _firestore.collection('teachers').doc(teacher.id).set({
        'name': teacher.name,
        'email': teacher.email,
        'phone': teacher.phone,
        'branch': teacher.branch,
        'classIds': teacher.classIds,
        'role': 'teacher',
      });
    } catch (e) {
      print('Öğretmen ekleme hatası: $e');
      throw Exception('Öğretmen eklenirken bir hata oluştu');
    }
  }

  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    await _firestore.collection('teachers').doc(id).update(data);
  }

  Future<void> deleteTeacher(String id) async {
    await _firestore.collection('teachers').doc(id).delete();
  }

  Stream<List<Teacher>> getTeachers() {
    return _firestore.collection('teachers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Teacher.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Öğrenci işlemleri
  Future<void> addStudent(Student student) async {
    await _firestore.collection('students').doc(student.id).set(student.toMap());
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await _firestore.collection('students').doc(id).update(data);
  }

  Future<void> deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }

  Stream<List<Student>> getStudents() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Veli işlemleri
  Future<void> addParent(Parent parent) async {
    await _firestore.collection('parents').doc(parent.id).set(parent.toMap());
  }

  Future<void> updateParent(String id, Map<String, dynamic> data) async {
    await _firestore.collection('parents').doc(id).update(data);
  }

  Future<void> deleteParent(String id) async {
    await _firestore.collection('parents').doc(id).delete();
  }

  Stream<List<Parent>> getParents() {
    return _firestore.collection('parents').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Parent.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Sınıf işlemleri
  Future<void> addClass(ClassRoom classroom) async {
    await _firestore.collection('classrooms').doc(classroom.id).set(classroom.toMap());
  }

  Future<void> updateClass(String id, Map<String, dynamic> data) async {
    await _firestore.collection('classrooms').doc(id).update(data);
  }

  Future<void> deleteClass(String id) async {
    await _firestore.collection('classrooms').doc(id).delete();
  }

  Stream<List<ClassRoom>> getClasses() {
    return _firestore.collection('classrooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassRoom.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Koleksiyonları kontrol et ve oluştur
  Future<void> initializeCollections() async {
    try {
      // teachers koleksiyonunu kontrol et
      final teachersRef = _firestore.collection('teachers');
      final teachersDoc = await teachersRef.limit(1).get();
      if (teachersDoc.docs.isEmpty) {
        print('teachers koleksiyonu oluşturuluyor...');
        // Boş bir doküman oluştur ve hemen sil (koleksiyonu oluşturmak için)
        final tempDoc = await teachersRef.add({
          'temp': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await tempDoc.delete();
        print('teachers koleksiyonu oluşturuldu');
      }

      // users koleksiyonunu kontrol et
      final usersRef = _firestore.collection('users');
      final usersDoc = await usersRef.limit(1).get();
      if (usersDoc.docs.isEmpty) {
        print('users koleksiyonu oluşturuluyor...');
        final tempDoc = await usersRef.add({
          'temp': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await tempDoc.delete();
        print('users koleksiyonu oluşturuldu');
      }

      print('Koleksiyonlar başarıyla kontrol edildi ve oluşturuldu');
    } catch (e) {
      print('Koleksiyon oluşturma hatası: $e');
      throw Exception('Veritabanı koleksiyonları oluşturulamadı');
    }
  }
} 