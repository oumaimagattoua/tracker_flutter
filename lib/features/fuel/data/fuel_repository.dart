import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/features/fuel/domain/fuel_entry.dart';

class FuelRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  FuelRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('drivers').doc(_uid).collection('fuelEntries');

  Future<void> addFuelEntry(FuelEntry entry) async {
    await _collection.add(entry.toMap());
  }

  Stream<List<FuelEntry>> watchFuelEntries({String? vehicleId}) {
    Query<Map<String, dynamic>> query = _collection.orderBy('date', descending: true);
    if (vehicleId != null) {
      query = query.where('vehicleId', isEqualTo: vehicleId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FuelEntry.fromMap(doc.id, doc.data())).toList();
    });
  }
}
