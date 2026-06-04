import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/features/fuel/application/fuel_service.dart';
import 'package:tracker_flutter/features/vehicle/application/vehicle_service.dart';

class AddFuelEntryScreen extends ConsumerStatefulWidget {
  const AddFuelEntryScreen({super.key});

  @override
  ConsumerState<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends ConsumerState<AddFuelEntryScreen> {
  String? _selectedVehicleId;
  final _mileageController = TextEditingController();
  final _litersController = TextEditingController();
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _mileageController.dispose();
    _litersController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);
    final fuelState = ref.watch(fuelControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un plein')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              vehiclesAsync.when(
                data: (vehicles) => DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  hint: const Text('Sélectionner un véhicule'),
                  items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (val) => setState(() => _selectedVehicleId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Erreur: $e'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilométrage'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _litersController,
                decoration: const InputDecoration(labelText: 'Litres'),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculatePrice(),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant total'),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculatePrice(),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix au litre'),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              const SizedBox(height: 20),
              if (fuelState.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _selectedVehicleId == null
                      ? null
                      : () async {
                          await ref.read(fuelControllerProvider.notifier).addFuelEntry(
                                vehicleId: _selectedVehicleId!,
                                date: _selectedDate,
                                mileage: int.tryParse(_mileageController.text) ?? 0,
                                liters: double.tryParse(_litersController.text) ?? 0,
                                amount: double.tryParse(_amountController.text) ?? 0,
                                pricePerLiter: double.tryParse(_priceController.text) ?? 0,
                              );
                          if (context.mounted) context.pop();
                        },
                  child: const Text('Enregistrer'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculatePrice() {
    final liters = double.tryParse(_litersController.text) ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (liters > 0) {
      _priceController.text = (amount / liters).toStringAsFixed(2);
    }
  }
}
