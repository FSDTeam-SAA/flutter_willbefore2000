import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreatsapp/core/routes/route_endpoint.dart';
import 'package:smilestreatsapp/core/utils/extensions/button_extensions.dart';
import 'package:smilestreatsapp/core/utils/extensions/input_decoration_extensions.dart';
import 'package:smilestreatsapp/feature/auth/domain/requests/login_request.dart';
import 'package:smilestreatsapp/feature/auth/presentation/providers/auth_provider.dart';

import '../../../../core/common/widgets/app_icons.dart';
import '../../../../core/common/widgets/app_logo.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons_const.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _rememberMe = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = LoginRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final result = await ref.read(authProvider.notifier).login(data);

    if (result && mounted) {
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
                    constraints: BoxConstraints(maxWidth: 600, minWidth: 300),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Gap.h16,
                          // Logo
                          AppLogo(width: 150),

                          Gap.h40,
                          // Welcome text
                          Text(
                            'Log In Your Account',
                            style: AppTextStyles.text24w700(),
                          ),
                          Gap.h24,

                          // Show error message if any
                          if (authState.loginError!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.loginError.toString(),
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  if (authState.loginError!.contains(
                                    'not verified',
                                  )) ...[
                                    Gap.h8,
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(authProvider.notifier)
                                            .sendEmailVerification();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Verification email sent!',
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Resend Verification Email',
                                        style: TextStyle(
                                          color: AppColors.textAppLaurel,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Gap.h16,
                          ],

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: 'Enter your Email',
                              prefixIcon: AppFormIcon(
                                assetPath: AssetsPath.email,
                              ),
                            ),
                            validator: Validators.email,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocus),
                            autofillHints: const [AutofillHints.email],
                          ),

                          Gap.h16,

                          /// [Text field] Password
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                decoration: context.primaryInputDecoration
                                    .copyWith(
                                      hintText: "Enter your Password",
                                      prefixIcon: AppFormIcon(
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
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                              );
                            },
                          ),
                          Gap.h8,
                          // Remember me and forgot password
                          Row(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: _rememberMe,
                                builder: (context, remember, _) {
                                  return Checkbox(
                                    side: BorderSide(
                                      color: AppColors.borderColor,
                                    ),
                                    value: remember,
                                    onChanged: (value) {
                                      _rememberMe.value = value ?? false;
                                    },
                                  );
                                },
                              ),
                              Text(
                                "Remember me",
                                style: TextStyle(
                                  color: AppColors.textSecondaryHintColor,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  context.pushNamed(
                                    RoutePaths.forgotPassword,
                                    extra: _emailController.text.trim(),
                                  );
                                },
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: AppColors.textAppLaurel,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Gap.h16,

                          /// [Button] Sign In
                          context.primaryButton(
                            isLoading: authState.isLoading,
                            onPressed: _submit,
                            text: "Sign In",
                          ),
                          Gap.h24,
                          // Signup link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'New To our Platform? ',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up Here',
                                    style: TextStyle(
                                      color: AppColors.textAppLaurel,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pushNamed(RoutePaths.signup);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Gap.h56,

                          // // Or continue with
                          // const Center(
                          //   child: Text(
                          //     'or continue with',
                          //     style: TextStyle(color: AppColors.mutedGray),
                          //   ),
                          // ),
                          // Gap.h24,
                          // // Social login buttons
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     AppIcon(
                          //       assetPath: AssetsPath.google,
                          //       height: 40,
                          //       width: 40,
                          //     ),
                          //     Gap.w40,
                          //     AppIcon(
                          //       assetPath: AssetsPath.apple,
                          //       height: 40,
                          //       width: 40,
                          //     ),
                          //   ],
                          // ),
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
