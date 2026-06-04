import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/features/auth/application/auth_service.dart';
import 'package:tracker_flutter/features/fuel/data/fuel_repository.dart';
import 'package:tracker_flutter/features/fuel/domain/fuel_entry.dart';

final fuelRepositoryProvider = Provider<FuelRepository?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;
  return FuelRepository(FirebaseFirestore.instance, user.id);
});

final fuelEntriesStreamProvider = StreamProvider.family<List<FuelEntry>, String?>((ref, vehicleId) {
  final repository = ref.watch(fuelRepositoryProvider);
  if (repository == null) return Stream.value([]);
  return repository.watchFuelEntries(vehicleId: vehicleId);
});

class FuelController extends StateNotifier<AsyncValue<void>> {
  final FuelRepository? _repository;

  FuelController(this._repository) : super(const AsyncData(null));

  Future<void> addFuelEntry({
    required String vehicleId,
    required DateTime date,
    required int mileage,
    required double liters,
    required double amount,
    required double pricePerLiter,
  }) async {
    if (_repository == null) return;
    state = const AsyncLoading();
    final entry = FuelEntry(
      id: '',
      vehicleId: vehicleId,
      date: date,
      mileage: mileage,
      liters: liters,
      amount: amount,
      pricePerLiter: pricePerLiter,
      createdAt: DateTime.now(),
    );
    state = await AsyncValue.guard(() => _repository.addFuelEntry(entry));
  }
}

final fuelControllerProvider = StateNotifierProvider<FuelController, AsyncValue<void>>((ref) {
  return FuelController(ref.watch(fuelRepositoryProvider));
});
