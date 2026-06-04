import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/features/vehicle/application/vehicle_service.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un véhicule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom du véhicule')),
              TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Marque')),
              TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Modèle')),
              TextField(controller: _plateController, decoration: const InputDecoration(labelText: 'Plaque d\'immatriculation')),
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilométrage actuel'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              if (state.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(vehicleControllerProvider.notifier).addVehicle(
                          name: _nameController.text,
                          brand: _brandController.text,
                          model: _modelController.text,
                          plateNumber: _plateController.text,
                          currentMileage: int.tryParse(_mileageController.text) ?? 0,
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
}
