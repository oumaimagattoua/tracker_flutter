import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/features/auth/application/auth_service.dart';
import 'package:tracker_flutter/features/dashboard/application/dashboard_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Gasoil & Maintenance'),
        actions: [
          IconButton(
            onPressed: () => context.push('/fuel'),
            icon: const Icon(Icons.local_gas_station),
          ),
          IconButton(
            onPressed: () => context.push('/maintenance'),
            icon: const Icon(Icons.build),
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'Total Dépenses',
                    '${stats.totalExpense.toStringAsFixed(2)} €',
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'Carburant',
                    '${stats.totalFuelExpense.toStringAsFixed(2)} €',
                    Colors.orange,
                  ),
                  _buildSummaryCard(
                    context,
                    'Maintenance',
                    '${stats.totalMaintenanceExpense.toStringAsFixed(2)} €',
                    Colors.green,
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Consommation par véhicule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (stats.vehicles.isEmpty)
                const Text('Aucun véhicule enregistré.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = stats.vehicles[index];
                    final fuelAmount = stats.fuelByVehicle[vehicle.id] ?? 0;
                    final liters = stats.litersByVehicle[vehicle.id] ?? 0;
                    return Card(
                      child: ListTile(
                        title: Text(vehicle.name),
                        subtitle: Text(
                          '${vehicle.brand} ${vehicle.model} - ${vehicle.plateNumber}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${fuelAmount.toStringAsFixed(2)} €'),
                            Text('${liters.toStringAsFixed(1)} L'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('/fuel/add'),
                    icon: const Icon(Icons.local_gas_station),
                    label: const Text('Plein'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/maintenance/add'),
                    icon: const Icon(Icons.build),
                    label: const Text('Maintenance'),
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vehicles/add'),
        tooltip: 'Ajouter un véhicule',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
