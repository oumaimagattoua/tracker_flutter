import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/features/maintenance/application/maintenance_service.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenancesAsync = ref.watch(maintenancesStreamProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Historique Maintenance')),
      body: maintenancesAsync.when(
        data: (maintenances) => maintenances.isEmpty
            ? const Center(child: Text('Aucune maintenance enregistrée.'))
            : ListView.builder(
                itemCount: maintenances.length,
                itemBuilder: (context, index) {
                  final m = maintenances[index];
                  return ListTile(
                    title: Text(m.title),
                    subtitle: Text('${m.amount.toStringAsFixed(2)} € | ${m.date.toLocal().toString().split(' ')[0]}'),
                    trailing: Text('${m.mileage} km'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
