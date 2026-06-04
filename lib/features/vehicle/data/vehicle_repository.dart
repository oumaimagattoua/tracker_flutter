import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_flutter/features/vehicle/domain/vehicle.dart';

class VehicleRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  VehicleRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('drivers').doc(_uid).collection('vehicles');

  Future<void> addVehicle(Vehicle vehicle) async {
    await _collection.add(vehicle.toMap());
  }

  Stream<List<Vehicle>> watchVehicles() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromMap(doc.id, doc.data())).toList();
    });
  }
}
