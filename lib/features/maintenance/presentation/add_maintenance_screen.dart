import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/features/maintenance/application/maintenance_service.dart';
import 'package:tracker_flutter/features/vehicle/application/vehicle_service.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  String? _selectedVehicleId;
  String? _selectedCategoryId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);
    final categoriesAsync = ref.watch(maintenanceCategoriesStreamProvider);
    final maintenanceState = ref.watch(maintenanceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Vehicle Selection
              vehiclesAsync.when(
                data: (vehicles) => DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  hint: const Text('Sélectionner un véhicule'),
                  items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (val) => setState(() => _selectedVehicleId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Erreur véhicules: $e'),
              ),
              const SizedBox(height: 10),
              // Category Selection
              Row(
                children: [
                  Expanded(
                    child: categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        hint: const Text('Catégorie'),
                        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (val) => setState(() => _selectedCategoryId = val),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, st) => Text('Erreur catégories: $e'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilométrage'),
                keyboardType: TextInputType.number,
              ),
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
              const SizedBox(height: 20),
              if (maintenanceState.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: (_selectedVehicleId == null || _selectedCategoryId == null)
                      ? null
                      : () async {
                          await ref.read(maintenanceControllerProvider.notifier).addMaintenance(
                                vehicleId: _selectedVehicleId!,
                                categoryId: _selectedCategoryId!,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                amount: double.tryParse(_amountController.text) ?? 0,
                                date: _selectedDate,
                                mileage: int.tryParse(_mileageController.text) ?? 0,
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

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Nom de la catégorie')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final id = await ref.read(maintenanceControllerProvider.notifier).addCategory(controller.text);
                if (id != null) {
                  setState(() => _selectedCategoryId = id);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
