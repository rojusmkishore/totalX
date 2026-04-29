import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:total_x/viewmodels/user_viewmodel.dart';

class AddUserBottomSheet extends StatefulWidget {
  const AddUserBottomSheet({super.key});

  @override
  State<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Add A New User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _isPickingImage ? null : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                          border: Border.all(color: Colors.grey[200]!, width: 2),
                        ),
                        child: _imageFile == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildLabel('Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter user name',
                validator: (value) => value!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Age'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageController,
                hint: 'Enter age',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter age' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: userViewModel.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await userViewModel.addUser(
                                name: _nameController.text,
                                phoneNumber: _phoneController.text,
                                age: int.parse(_ageController.text),
                                imageFile: _imageFile,
                              );
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: userViewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
