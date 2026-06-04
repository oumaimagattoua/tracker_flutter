import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/features/fuel/application/fuel_service.dart';

class FuelEntryListScreen extends ConsumerWidget {
  const FuelEntryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelEntriesAsync = ref.watch(fuelEntriesStreamProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Historique Carburant')),
      body: fuelEntriesAsync.when(
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('Aucun plein enregistré.'))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text('${entry.amount.toStringAsFixed(2)} € - ${entry.liters.toStringAsFixed(2)} L'),
                    subtitle: Text('Date: ${entry.date.toLocal().toString().split(' ')[0]} | ${entry.mileage} km'),
                    trailing: Text('${entry.pricePerLiter.toStringAsFixed(2)} €/L'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
