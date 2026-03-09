import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';
import 'package:smilestreatsapp/feature/auth/presentation/providers/auth_provider.dart';
import 'package:smilestreatsapp/core/common/widgets/app_scaffold.dart';
import 'package:smilestreatsapp/core/constants/app_colors.dart';
import 'package:smilestreatsapp/core/utils/extensions/button_extensions.dart';
import 'package:smilestreatsapp/core/utils/extensions/input_decoration_extensions.dart';

import '../../../../core/common/widgets/app_cached_image.dart';

class EditPersonalInfoScreen extends ConsumerStatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  ConsumerState<EditPersonalInfoScreen> createState() =>
      _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState
    extends ConsumerState<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      _phoneNumberController.text = user.phoneNumber ?? '';
      // For demo purposes, setting default values as shown in image
      _streetAddressController.text = user.streetAddress ?? "";
      _cityController.text = user.city ?? "";
      _stateController.text = user.state ?? "";
      _zipCodeController.text = user.zipCode ?? "";
      _dateOfBirthController.text = user.dateOfBirth ?? "";
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  XFile? _pickedImage;
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
      await _uploadImageAndUpdateProfile(picked);
    }
  }

  Future<void> _uploadImageAndUpdateProfile(XFile image) async {
    setState(() => _isUploadingImage = true);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${user.uid}.jpg',
      );
      await storageRef.putData(await image.readAsBytes());
      final photoURL = await storageRef.getDownloadURL();

      final updatedUser = user.copyWith(
        photoURL: photoURL,
        updatedAt: DateTime.now(),
      );
      await ref.read(authProvider.notifier).updateProfile(updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = ref
        .read(authProvider)
        .user!
        .copyWith(
          displayName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          streetAddress: _streetAddressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipCodeController.text.trim(),
          dateOfBirth: _dateOfBirthController.text.trim(),
          updatedAt: DateTime.now(),
        );

    final result = await ref
        .read(authProvider.notifier)
        .updateProfile(updatedUser);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Edit Personal Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textAppBlack,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 600,
                      minWidth: 300,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show error message if any
                          if (authState.errorMessage.isNotEmpty == true) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                authState.errorMessage,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            Gap.h16,
                          ],

                          Center(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryLaurel,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: _pickedImage != null
                                            ? Image.file(
                                                File(_pickedImage!.path),
                                                fit: BoxFit.cover,
                                              )
                                            : (user?.photoURL != null &&
                                                      user!.photoURL!.isNotEmpty
                                                  ? AppCachedImage(
                                                      imageUrl: user.photoURL!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: AppColors
                                                          .primaryLaurel,
                                                    )),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: _isUploadingImage
                                            ? null
                                            : _pickImage,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              AppColors.primaryLaurel,
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (_isUploadingImage)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black26,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user?.displayName ?? 'Guest',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textAppBlack,
                                  ),
                                ),
                                if (user?.email != null &&
                                    user!.email!.isNotEmpty)
                                  Text(
                                    user.email!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Personal Information Section
                          // _buildSectionHeader('Personal Information'),
                          Gap.h16,

                          // /// [tile]
                          // Text(
                          //   "Email",
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //     color: AppColors.textAppBlack,
                          //   ),
                          // ),
                          // Gap.h4,
                          // // Email field (read-only as shown in image)
                          // TextFormField(
                          //   controller: TextEditingController(
                          //     text: 'john.smith@example.com',
                          //   ),
                          //   readOnly: true,
                          //   style: TextStyle(
                          //     color: AppColors.textSecondaryColor.withOpacity(
                          //       0.6,
                          //     ),
                          //   ),
                          //   decoration: context.primaryInputDecoration.copyWith(
                          //     hintText: 'Enter your email',
                          //     filled: true,
                          //     fillColor: Colors.grey.shade100,
                          //   ),
                          // ),
                          // Gap.h16,

                          // Contact Information Section
                          _buildSectionHeader('Contact Information'),
                          Gap.h16,

                          /// [tile]
                          Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          Gap.h4,
                          // Full Name field
                          TextFormField(
                            controller: _fullNameController,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your full name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full Name is required';
                              }
                              return null;
                            },
                          ),
                          Gap.h16,

                          /// [tile]
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          Gap.h4,
                          // Phone Number field
                          TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your phone number',
                            ),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(
                                    value.replaceAll(RegExp(r'[^\d+]'), ''),
                                  )) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          Gap.h16,

                          /// [tile]
                          Text(
                            "Street Address",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          Gap.h4,
                          // Street Address field
                          TextFormField(
                            controller: _streetAddressController,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your street address',
                            ),
                          ),
                          Gap.h16,

                          // City and State row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// [tile]
                                    Text(
                                      "City",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textAppBlack,
                                      ),
                                    ),
                                    Gap.h4,
                                    TextFormField(
                                      controller: _cityController,
                                      style: TextStyle(
                                        color: AppColors.textSecondaryColor,
                                      ),
                                      decoration: context.primaryInputDecoration
                                          .copyWith(hintText: 'Enter city'),
                                    ),
                                  ],
                                ),
                              ),
                              Gap.w16,
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// [tile]
                                    Text(
                                      "State",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textAppBlack,
                                      ),
                                    ),
                                    Gap.h4,
                                    TextFormField(
                                      controller: _stateController,
                                      style: TextStyle(
                                        color: AppColors.textSecondaryColor,
                                      ),
                                      decoration: context.primaryInputDecoration
                                          .copyWith(hintText: 'State'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Gap.h16,

                          /// [tile]
                          Text(
                            "Zip Code",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          Gap.h4,
                          // Zip Code field
                          TextFormField(
                            controller: _zipCodeController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter zip code',
                            ),
                          ),
                          Gap.h24,

                          // Personal Details Section
                          _buildSectionHeader('Personal Details'),
                          Gap.h16,

                          /// [tile]
                          Text(
                            "Date of Birth",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          Gap.h4,
                          // Date of Birth field
                          TextFormField(
                            controller: _dateOfBirthController,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Select your date of birth',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(1985, 6, 15),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _dateOfBirthController.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                          Gap.h40,

                          // Buttons row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.textAppLaurel,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppColors.textAppLaurel,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Gap.w16,
                              Expanded(
                                child: context.primaryButton(
                                  isLoading: authState.isLoading,
                                  onPressed: _submit,
                                  text: 'Save Changes',
                                ),
                              ),
                            ],
                          ),

                          Gap.h24,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textAppBlack,
      ),
    );
  }
}
