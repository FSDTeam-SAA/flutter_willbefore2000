// import 'package:flutter/material.dart';
// import 'package:flutx_core/core/routes/services/go_next_navigation.dart';
// import 'package:flutx_core/flutx_core.dart';
// import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
// import 'package:smilestreats/core/utils/extensions/input_decoration_extensions.dart';
// import 'package:smilestreats/feature/auth/presentation/screens/verify_otp_screen.dart';

// import '../../../../core/common/widgets/app_icons.dart';
// import '../../../../core/common/widgets/app_logo.dart';
// import '../../../../core/common/widgets/app_scaffold.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_icons_const.dart';
// import '../controller/auth_controller.dart';

// class SendOptScreen extends StatefulWidget {
//   const SendOptScreen({super.key});

//   @override
//   State<SendOptScreen> createState() => _SendOptScreenState();
// }

// class _SendOptScreenState extends State<SendOptScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final FocusNode _emailFocus = FocusNode();
//   // final FocusNode _passwordFocus = FocusNode();

//   final TextEditingController _emailController = TextEditingController();
//   // final TextEditingController _passwordController = TextEditingController();

//   // final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
//   // final ValueNotifier<bool> _rememberMe = ValueNotifier<bool>(false);

//   /// [controller]
//   final AuthController _authController = AuthController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     // _passwordController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     // if (!_formKey.currentState!.validate()) return;

//     Go.sailTo(VerifyOTPScreen(email: _emailController.text), transition: TransitionType.slideLeft);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SafeArea(
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(maxWidth: 600, minWidth: 300),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           Gap.h16,
//                           // Logo
//                           AppLogo(width: 150),

//                           Gap.bottomBarGap,
//                           // Welcome text
//                           Text(
//                             'Log In Your Account',
//                             style: AppTextStyles.text24w700(),
//                           ),
//                           Gap.h24,

//                           // Email field
//                           TextFormField(
//                             controller: _emailController,
//                             focusNode: _emailFocus,
//                             keyboardType: TextInputType.emailAddress,
//                             style: TextStyle(
//                               color: AppColors.textSecondaryColor,
//                             ),
//                             decoration: context.primaryInputDecoration.copyWith(
//                               hintText: 'Enter your Email',
//                               prefixIcon: AppFormIcon(
//                                 assetPath: AssetsPath.email,
//                               ),
//                             ),
//                             validator: Validators.email,
//                             onFieldSubmitted: (_) => _submit(),
//                             autofillHints: const [AutofillHints.email],
//                           ),

//                           Gap.h16,

//                           /// [Button] Sign In
//                           ListenableBuilder(
//                             listenable: _authController,
//                             builder: (context, _) {
//                               return context.primaryButton(
//                                 isLoading: _authController.isLoading,
//                                 onPressed: _submit,
//                                 text: "Send OTP",
//                               );
//                             },
//                           ),

//                           // // Or continue with
//                           // const Center(
//                           //   child: Text(
//                           //     'or continue with',
//                           //     style: TextStyle(color: AppColors.mutedGray),
//                           //   ),
//                           // ),
//                           // Gap.h24,
//                           // // Social login buttons
//                           // Row(
//                           //   mainAxisAlignment: MainAxisAlignment.center,
//                           //   children: [
//                           //     AppIcon(
//                           //       assetPath: AssetsPath.google,
//                           //       height: 40,
//                           //       width: 40,
//                           //     ),
//                           //     Gap.w40,
//                           //     AppIcon(
//                           //       assetPath: AssetsPath.apple,
//                           //       height: 40,
//                           //       width: 40,
//                           //     ),
//                           //   ],
//                           // ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
