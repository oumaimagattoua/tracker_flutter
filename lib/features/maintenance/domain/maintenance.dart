import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String id;
  final String vehicleId;
  final String categoryId;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final int mileage;
  final DateTime createdAt;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.mileage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'categoryId': categoryId,
      'title': title,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'mileage': mileage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Maintenance.fromMap(String id, Map<String, dynamic> map) {
    return Maintenance(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      mileage: map['mileage'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
