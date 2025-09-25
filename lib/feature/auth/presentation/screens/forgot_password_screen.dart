import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions/button_extensions.dart';
import '../../../../core/utils/extensions/input_decoration_extensions.dart';
import '../../../../core/common/widgets/app_icons.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons_const.dart';
import '../../domain/requests/forgot_password_request.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ForgotPasswordScreen({super.key, this.email = ''});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = ForgotPasswordRequest(email: _emailController.text.trim());

    final result = await ref
        .read(authProvider.notifier)
        .forgotPassword(request);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                          Gap.h32,

                          Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: AppColors.textAppLaurel,
                          ),

                          Gap.h24,

                          Text(
                            'Reset Your Password',
                            style: AppTextStyles.text24w700(),
                          ),

                          Gap.h16,

                          Text(
                            'Enter your email address and we\'ll send you a link to reset your password.',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Gap.h32,

                          // Show error message if any
                          if (authState.errorMessage.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                authState.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            Gap.h16,
                          ],

                          // Email field
                          "Email Address"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your email address',
                              prefixIcon: const AppFormIcon(
                                assetPath: AssetsPath.email,
                              ),
                            ),
                            validator: Validators.email,
                            onFieldSubmitted: (_) => _submit(),
                            autofillHints: const [AutofillHints.email],
                          ),

                          Gap.h24,

                          // Reset Password button
                          context.primaryButton(
                            isLoading: authState.isLoading,
                            onPressed: _submit,
                            text: "Send Reset Link",
                          ),

                          Gap.h24,

                          // Back to login link
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Back to Login',
                              style: TextStyle(color: AppColors.textAppLaurel),
                            ),
                          ),

                          Gap.h40,
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
