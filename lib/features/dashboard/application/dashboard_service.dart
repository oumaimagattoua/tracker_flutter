import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/features/fuel/application/fuel_service.dart';
import 'package:tracker_flutter/features/fuel/domain/fuel_entry.dart';
import 'package:tracker_flutter/features/maintenance/application/maintenance_service.dart';
import 'package:tracker_flutter/features/maintenance/domain/maintenance.dart';
import 'package:tracker_flutter/features/vehicle/application/vehicle_service.dart';
import 'package:tracker_flutter/features/vehicle/domain/vehicle.dart';

class DashboardStats {
  final List<Vehicle> vehicles;
  final List<FuelEntry> fuelEntries;
  final List<Maintenance> maintenances;

  DashboardStats({
    required this.vehicles,
    required this.fuelEntries,
    required this.maintenances,
  });

  double get totalFuelExpense =>
      fuelEntries.fold(0, (sum, item) => sum + item.amount);

  double get totalMaintenanceExpense =>
      maintenances.fold(0, (sum, item) => sum + item.amount);

  double get totalExpense => totalFuelExpense + totalMaintenanceExpense;

  Map<String, double> get fuelByVehicle {
    final Map<String, double> map = {};
    for (var entry in fuelEntries) {
      map[entry.vehicleId] = (map[entry.vehicleId] ?? 0) + entry.amount;
    }
    return map;
  }

  Map<String, double> get litersByVehicle {
    final Map<String, double> map = {};
    for (var entry in fuelEntries) {
      map[entry.vehicleId] = (map[entry.vehicleId] ?? 0) + entry.liters;
    }
    return map;
  }
}

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final vehiclesAsync = ref.watch(vehiclesStreamProvider);
  final fuelAsync = ref.watch(fuelEntriesStreamProvider(null));
  final maintenanceAsync = ref.watch(maintenancesStreamProvider(null));

  if (vehiclesAsync is AsyncData &&
      fuelAsync is AsyncData &&
      maintenanceAsync is AsyncData) {
    return AsyncData(DashboardStats(
      vehicles: vehiclesAsync.value!,
      fuelEntries: fuelAsync.value!,
      maintenances: maintenanceAsync.value!,
    ));
  }

  if (vehiclesAsync is AsyncError) return AsyncError(vehiclesAsync.error!, vehiclesAsync.stackTrace!);
  if (fuelAsync is AsyncError) return AsyncError(fuelAsync.error!, fuelAsync.stackTrace!);
  if (maintenanceAsync is AsyncError) return AsyncError(maintenanceAsync.error!, maintenanceAsync.stackTrace!);

  return const AsyncLoading();
});
