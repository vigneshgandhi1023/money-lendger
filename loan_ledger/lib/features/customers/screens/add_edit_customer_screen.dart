import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/customer_avatar.dart';
import '../../../models/customer.dart';
import '../providers/customer_providers.dart';

/// Add/Edit customer form screen.
///
/// Pre-fills fields when editing an existing customer.
/// Validates all inputs before saving.
class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const AddEditCustomerScreen({super.key, this.customerId});

  bool get isEditing => customerId != null;

  @override
  ConsumerState<AddEditCustomerScreen> createState() =>
      _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState
    extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final customer = StorageService.getCustomer(widget.customerId!);
      if (customer != null) {
        _nameController.text = customer.fullName;
        _phoneController.text = customer.phoneNumber;
        _addressController.text = customer.address ?? '';
        _notesController.text = customer.notes ?? '';
        _photoPath = customer.photoPath;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      if (widget.isEditing) {
        final existing = StorageService.getCustomer(widget.customerId!);
        if (existing != null) {
          final updated = existing.copyWith(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
            photoPath: _photoPath,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );
          await StorageService.saveCustomer(updated);
        }
      } else {
        final customer = Customer.create(
          id: const Uuid().v4(),
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          photoPath: _photoPath,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        await StorageService.saveCustomer(customer);
      }

      refreshCustomers(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Customer updated'
                : 'Customer added'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Customer' : 'New Customer'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo picker
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CustomerAvatar(
                        name: _nameController.text.isNotEmpty
                            ? _nameController.text
                            : '?',
                        photoPath: _photoPath,
                        size: 80,
                        fontSize: 28,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to add photo',
                  style: theme.textTheme.bodySmall,
                ),
              ),

              const SizedBox(height: 28),

              // Full Name
              TextFormField(
                controller: _nameController,
                validator: Validators.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address (Optional)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing ? 'Save Changes' : 'Add Customer'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
