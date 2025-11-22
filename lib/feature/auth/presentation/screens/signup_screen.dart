import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/routes/route_endpoint.dart';
import '../../../../core/utils/extensions/button_extensions.dart';
import '../../../../core/utils/extensions/input_decoration_extensions.dart';
import '../../../../core/common/widgets/app_icons.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons_const.dart';
import '../../domain/requests/signup_request.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _termsAccepted = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _termsAccepted.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    // Get FCM token
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      DPrint.log("Failed to get FCM token: $e");
    }

    final request = SignupRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      fcmToken: fcmToken,
    );

    final result = await ref.read(authProvider.notifier).signup(request);

    if (result && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully! Please verify your email.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to email verification screen or home
      context.pushReplacement(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AppScaffold(
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
                          Gap.h16,

                          Text(
                            'Create Your Account',
                            style: AppTextStyles.text24w700(),
                          ),
                          Gap.h24,

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
                                authState.errorMessage,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                            Gap.h16,
                          ],

                          // Name field
                          "Name"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your Full Name',
                              prefixIcon: AppFormIcon(
                                assetPath: AssetsPath.user,
                              ),
                            ),
                            validator: Validators.required,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_emailFocus),
                          ),

                          Gap.h16,

                          // Email field
                          "Email"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your Email',
                              prefixIcon: const AppFormIcon(
                                assetPath: AssetsPath.email,
                              ),
                            ),
                            validator: Validators.email,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_phoneFocus),
                            autofillHints: const [AutofillHints.email],
                          ),

                          Gap.h16,

                          // Phone number field
                          "Phone (Optional)"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your Phone Number',
                              prefixIcon: const AppFormIcon(
                                assetPath: AssetsPath.phone,
                              ),
                            ),
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocus),
                          ),

                          Gap.h16,

                          // Password field
                          "Password"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                decoration: context.primaryInputDecoration
                                    .copyWith(
                                      hintText: 'Create a Password',
                                      prefixIcon: const AppFormIcon(
                                        assetPath: AssetsPath.lock,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color:
                                              AppColors.textSecondaryHintColor,
                                        ),
                                        onPressed: () =>
                                            _obscurePassword.value = !obscure,
                                      ),
                                    ),
                                // validator: Validators.password,
                                onFieldSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_confirmPasswordFocus),
                              );
                            },
                          ),

                          Gap.h16,

                          // Confirm Password field
                          "Confirm Password"
                              .text14w500(color: AppColors.textAppBlack)
                              .align(Alignment.centerLeft),
                          Gap.h8,
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
                                      hintText: 'Confirm your Password',
                                      prefixIcon: const AppFormIcon(
                                        assetPath: AssetsPath.lock,
                                      ),
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
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              );
                            },
                          ),

                          Gap.h8,

                          // Terms and conditions checkbox
                          ValueListenableBuilder<bool>(
                            valueListenable: _termsAccepted,
                            builder: (context, accepted, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                      color: AppColors.borderColor,
                                    ),
                                    value: accepted,
                                    onChanged: (value) {
                                      _termsAccepted.value = value ?? false;
                                    },
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            'By Registration, You agree to the ',
                                        style: TextStyle(
                                          color: AppColors.textSecondaryColor,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'terms of service ',
                                            style: TextStyle(
                                              color: AppColors.textAppLaurel,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                context.pushNamed(
                                                  RoutePaths
                                                      .appTermsAndConditions,
                                                );
                                              },
                                          ),
                                          const TextSpan(text: 'and '),
                                          TextSpan(
                                            text: 'privacy policy',
                                            style: TextStyle(
                                              color: AppColors.textAppLaurel,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                context.pushNamed(
                                                  RoutePaths.appPrivacyPolicy,
                                                );
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          Gap.h16,

                          // Sign Up button
                          context.primaryButton(
                            isLoading: authState.isLoading,
                            onPressed: _submit,
                            text: "Sign Up",
                          ),

                          Gap.h24,

                          // Login link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In Here',
                                    style: TextStyle(
                                      color: AppColors.textAppLaurel,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pop();
                                      },
                                  ),
                                ],
                              ),
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
