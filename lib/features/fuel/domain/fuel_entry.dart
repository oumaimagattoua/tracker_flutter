import 'package:cloud_firestore/cloud_firestore.dart';

class FuelEntry {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int mileage;
  final double liters;
  final double amount;
  final double pricePerLiter;
  final DateTime createdAt;

  FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mileage,
    required this.liters,
    required this.amount,
    required this.pricePerLiter,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'date': Timestamp.fromDate(date),
      'mileage': mileage,
      'liters': liters,
      'amount': amount,
      'pricePerLiter': pricePerLiter,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FuelEntry.fromMap(String id, Map<String, dynamic> map) {
    return FuelEntry(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      mileage: map['mileage'] ?? 0,
      liters: (map['liters'] as num).toDouble(),
      amount: (map['amount'] as num).toDouble(),
      pricePerLiter: (map['pricePerLiter'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
