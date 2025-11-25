import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/common/widgets/app_scaffold.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import 'package:smilestreats/core/utils/extensions/input_decoration_extensions.dart';
import 'package:smilestreats/feature/auth/domain/requests/change_password_request.dart';
import 'package:smilestreats/feature/auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> _obscureCurrentPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureNewPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if new password and confirm password match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      // Show error - you might want to handle this differently
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = ChangePasswordRequest(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    final result = await ref
        .read(authProvider.notifier)
        .changePassword(request);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Account Security',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        children: [
                          Gap.h24,

                          // Change Password title
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Change Password',
                              style: AppTextStyles.text24w700(),
                            ),
                          ),
                          Gap.h32,

                          // Show error message if any
                          if (authState.loginError!.isNotEmpty) ...[
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

                          // Current Password field
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureCurrentPassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _currentPasswordController,
                                focusNode: _currentPasswordFocus,
                                obscureText: obscure,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                decoration: context.primaryInputDecoration
                                    .copyWith(
                                      hintText: 'Current Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color:
                                              AppColors.textSecondaryHintColor,
                                        ),
                                        onPressed: () =>
                                            _obscureCurrentPassword.value =
                                                !obscure,
                                      ),
                                    ),
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_newPasswordFocus),
                                autofillHints: const [AutofillHints.password],
                              );
                            },
                          ),

                          Gap.h16,

                          // New Password field
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureNewPassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _newPasswordController,
                                focusNode: _newPasswordFocus,
                                obscureText: obscure,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                decoration: context.primaryInputDecoration
                                    .copyWith(
                                      hintText: 'New Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color:
                                              AppColors.textSecondaryHintColor,
                                        ),
                                        onPressed: () =>
                                            _obscureNewPassword.value =
                                                !obscure,
                                      ),
                                    ),
                                validator: _validatePassword,
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_confirmPasswordFocus),
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                              );
                            },
                          ),

                          Gap.h16,

                          // Confirm New Password field
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureConfirmPassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                decoration: context.primaryInputDecoration
                                    .copyWith(
                                      hintText: 'Confirm New Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color:
                                              AppColors.textSecondaryHintColor,
                                        ),
                                        onPressed: () =>
                                            _obscureConfirmPassword.value =
                                                !obscure,
                                      ),
                                    ),
                                validator: _validateConfirmPassword,
                                onFieldSubmitted: (_) => _submit(),
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                              );
                            },
                          ),

                          Gap.h32,

                          // Update Password button
                          context.primaryButton(
                            isLoading: authState.isLoading,
                            onPressed: _submit,
                            text: "Update Password",
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
}
