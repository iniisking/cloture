import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GenderController extends ChangeNotifier {
  GenderController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? _selectedGender; // 'Men' | 'Women'
  String? get selectedGender => _selectedGender;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> loadUserGender() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _loading = true;
    notifyListeners();

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final genderRaw = userDoc.data()?['gender'];
      if (genderRaw is String) {
        _selectedGender = genderRaw.toLowerCase() == 'men' ? 'Men' : 'Women';
      }
    } catch (_) {
      // ignore
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }
}

