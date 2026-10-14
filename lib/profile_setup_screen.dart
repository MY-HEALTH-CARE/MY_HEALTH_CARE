import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'dashboard_screen.dart';

/// First-time profile setup (isEdit = false) and Edit Profile (isEdit = true).
class ProfileSetupScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic> userData;

  const ProfileSetupScreen({
    super.key,
    this.isEdit = false,
    this.userData = const {},
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  static const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  String? bloodGroup;

  Uint8List? _newImageBytes; // freshly picked image
  String _existingImage = ''; // base64 already saved in Firestore

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    final d = widget.userData;
    nameController.text = (d['name'] ?? '').toString();
    phoneController.text = (d['phone'] ?? '').toString();
    addressController.text = (d['address'] ?? '').toString();
    final bg = (d['bloodGroup'] ?? '').toString();
    if (bloodGroups.contains(bg)) bloodGroup = bg;
    _existingImage = (d['profileImage'] ?? '').toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 50,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _newImageBytes = bytes);
    } catch (e) {
      setState(() => errorMessage = 'Could not pick image: $e');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF0077B6)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: Color(0xFF0077B6)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _previewImage() {
    if (_newImageBytes != null) return MemoryImage(_newImageBytes!);
    if (_existingImage.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(
            _existingImage.replaceFirst('data:image/jpeg;base64,', '')));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty || bloodGroup == null) {
      setState(() => errorMessage = 'Please fill in all fields!');
      return;
    }
    if (phone.length < 11) {
      setState(() => errorMessage = 'Please enter a valid phone number!');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'address': address,
        'bloodGroup': bloodGroup,
        'email': user.email,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_newImageBytes != null) {
        data['profileImage'] = base64Encode(_newImageBytes!);
      }

      // Firestore creates the 'users' collection automatically on first write.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      if (!mounted) return;
      if (widget.isEdit) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewImage();

    return PopScope(
      canPop: widget.isEdit,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (widget.isEdit)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        widget.isEdit ? 'Edit Profile' : 'Set Up Your Profile',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 18),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage: preview,
                      child: preview == null
                          ? const Icon(Icons.person,
                              size: 54, color: Color(0xFF0077B6))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageOptions,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF023E8A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25, 28, 25, 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: bloodGroup,
                            decoration: InputDecoration(
                              labelText: 'Blood Group',
                              filled: true,
                              fillColor: const Color(0xFFF5F8FA),
                              prefixIcon: const Icon(Icons.water_drop_outlined,
                                  color: Color(0xFF0077B6)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: bloodGroups
                                .map((g) =>
                                    DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => bloodGroup = v),
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            controller: addressController,
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 14),
                          if (errorMessage.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: Text(errorMessage,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          PrimaryGradientButton(
                            label: widget.isEdit ? 'Save Changes' : 'Continue',
                            isLoading: isLoading,
                            onPressed: _save,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}