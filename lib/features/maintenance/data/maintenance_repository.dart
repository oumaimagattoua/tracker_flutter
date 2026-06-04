import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/features/maintenance/domain/maintenance.dart';
import 'package:tracker_flutter/features/maintenance/domain/maintenance_category.dart';

class MaintenanceRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  MaintenanceRepository(this._firestore, this._uid);

  DocumentReference get _driverDoc => _firestore.collection('drivers').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _maintenancesCollection =>
      _driverDoc.collection('maintenances');

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _driverDoc.collection('maintenanceCategories');

  // Categories
  Future<String> addCategory(MaintenanceCategory category) async {
    final doc = await _categoriesCollection.add(category.toMap());
    return doc.id;
  }

  Stream<List<MaintenanceCategory>> watchCategories() {
    return _categoriesCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MaintenanceCategory.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Maintenances
  Future<void> addMaintenance(Maintenance maintenance) async {
    await _maintenancesCollection.add(maintenance.toMap());
  }

  Stream<List<Maintenance>> watchMaintenances({String? vehicleId}) {
    Query<Map<String, dynamic>> query =
        _maintenancesCollection.orderBy('date', descending: true);
    if (vehicleId != null) {
      query = query.where('vehicleId', isEqualTo: vehicleId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Maintenance.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
