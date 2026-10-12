import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/day_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userEntries(String userId) {
    return _firestore.collection('users').doc(userId).collection('entries');
  }

  Future<DayEntry?> getEntry(String userId, String dateKey) async {
    final doc = await _userEntries(userId).doc(dateKey).get();
    if (!doc.exists || doc.data() == null) return null;
    return DayEntry.fromMap(doc.data()!);
  }

  Future<void> saveEntry(String userId, DayEntry entry) async {
    final docRef = _userEntries(userId).doc(entry.dateKey);
    if (entry.isEmpty) {
      await docRef.delete();
    } else {
      await docRef.set(entry.toMap(), SetOptions(merge: true));
    }
  }

  Future<Set<String>> getDatesWithContent(String userId) async {
    final snapshot = await _userEntries(userId).get();
    final dates = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final entry = DayEntry.fromMap(data);
      if (entry.hasContent) {
        dates.add(entry.dateKey);
      }
    }
    return dates;
  }

  Stream<DayEntry?> streamEntry(String userId, String dateKey) {
    return _userEntries(userId).doc(dateKey).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return DayEntry.fromMap(doc.data()!);
    });
  }

  Stream<Set<String>> streamDatesWithContent(String userId) {
    return _userEntries(userId).snapshots().map((snapshot) {
      final dates = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final entry = DayEntry.fromMap(data);
        if (entry.hasContent) {
          dates.add(entry.dateKey);
        }
      }
      return dates;
    });
  }
}
