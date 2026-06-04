import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/features/auth/application/auth_service.dart';
import 'package:tracker_flutter/features/maintenance/data/maintenance_repository.dart';
import 'package:tracker_flutter/features/maintenance/domain/maintenance.dart';
import 'package:tracker_flutter/features/maintenance/domain/maintenance_category.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;
  return MaintenanceRepository(FirebaseFirestore.instance, user.id);
});

final maintenanceCategoriesStreamProvider =
    StreamProvider<List<MaintenanceCategory>>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  if (repository == null) return Stream.value([]);
  return repository.watchCategories();
});

final maintenancesStreamProvider =
    StreamProvider.family<List<Maintenance>, String?>((ref, vehicleId) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  if (repository == null) return Stream.value([]);
  return repository.watchMaintenances(vehicleId: vehicleId);
});

class MaintenanceController extends StateNotifier<AsyncValue<void>> {
  final MaintenanceRepository? _repository;

  MaintenanceController(this._repository) : super(const AsyncData(null));

  Future<String?> addCategory(String name) async {
    if (_repository == null) return null;
    final category = MaintenanceCategory(
      id: '',
      name: name,
      createdAt: DateTime.now(),
    );
    return await _repository.addCategory(category);
  }

  Future<void> addMaintenance({
    required String vehicleId,
    required String categoryId,
    required String title,
    required String description,
    required double amount,
    required DateTime date,
    required int mileage,
  }) async {
    if (_repository == null) return;
    state = const AsyncLoading();
    final maintenance = Maintenance(
      id: '',
      vehicleId: vehicleId,
      categoryId: categoryId,
      title: title,
      description: description,
      amount: amount,
      date: date,
      mileage: mileage,
      createdAt: DateTime.now(),
    );
    state = await AsyncValue.guard(() => _repository.addMaintenance(maintenance));
  }
}

final maintenanceControllerProvider =
    StateNotifierProvider<MaintenanceController, AsyncValue<void>>((ref) {
  return MaintenanceController(ref.watch(maintenanceRepositoryProvider));
});
