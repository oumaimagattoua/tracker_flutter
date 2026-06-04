import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceCategory {
  final String id;
  final String name;
  final DateTime createdAt;

  MaintenanceCategory({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MaintenanceCategory.fromMap(String id, Map<String, dynamic> map) {
    return MaintenanceCategory(
      id: id,
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
