import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/features/auth/application/auth_service.dart';
import 'package:tracker_flutter/features/vehicle/application/vehicle_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Véhicules'),
        actions: [
          IconButton(
            onPressed: () => context.push('/fuel'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) => vehicles.isEmpty
                  ? const Center(child: Text('Aucun véhicule enregistré.'))
                  : ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return ListTile(
                          title: Text(vehicle.name),
                          subtitle: Text('${vehicle.brand} ${vehicle.model} - ${vehicle.plateNumber}'),
                          trailing: Text('${vehicle.currentMileage} km'),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Erreur: $e')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/fuel/add'),
              icon: const Icon(Icons.local_gas_station),
              label: const Text('Enregistrer un plein'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vehicles/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
