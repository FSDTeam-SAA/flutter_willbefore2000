// import 'package:flutter/material.dart';
// import 'package:flutx_core/flutx_core.dart';
// import 'package:pinput/pinput.dart';
// import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
// import '../../../../core/common/widgets/app_logo.dart';
// import '../../../../core/common/widgets/app_scaffold.dart';
// import '../../../../core/constants/app_colors.dart';

// import '../controller/auth_controller.dart';

// class VerifyOTPScreen extends StatefulWidget {
//   final String email;
//   const VerifyOTPScreen({super.key, required this.email});

//   @override
//   State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
// }

// class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
//   final TextEditingController pinController = TextEditingController();
//   final FocusNode focusNode = FocusNode();

//   /// [Controller]
//   final AuthController _authController = AuthController();

//   @override
//   void dispose() {
//     pinController.dispose();
//     focusNode.dispose();
//     super.dispose();
//   }

//   void _submit(String otp) {
//     try {
//       // Handle OTP verification
//       DPrint.log("OTP entered: $otp for email: ${widget.email}");
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => SecurityQuestionsScreen()),
//       // );
//     } catch (e) {
//       DPrint.error(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final focusedBorderColor = AppColors.primaryLaurel;
//     final fillColor = AppColors.white;
//     final borderColor = AppColors.borderColor;

//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: TextStyle(
//         fontSize: 22,
//         color: AppColors.textAppLaurel,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: borderColor),
//         color: Colors.white,
//       ),
//     );

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
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Gap.h16,
//                         // Logo
//                         AppLogo(width: 150),
//                         Gap.h56,
//                         // Title
//                         Text('Enter OTP', style: AppTextStyles.text20w700()),
//                         Gap.h8,
//                         // Subtitle
//                         Text(
//                           'Enter your receive OTP',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: AppColors.textPrimaryHintColor,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         Gap.h40,
//                         // OTP Input using Pinput
//                         Pinput(
//                           length: 4,
//                           controller: pinController,
//                           focusNode: focusNode,
//                           defaultPinTheme: defaultPinTheme,
//                           hapticFeedbackType: HapticFeedbackType.lightImpact,
//                           onCompleted: (pin) => _submit(pin),
//                           onChanged: (value) {
//                             debugPrint('Changed: $value');
//                           },
//                           focusedPinTheme: defaultPinTheme.copyWith(
//                             decoration: defaultPinTheme.decoration!.copyWith(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: focusedBorderColor),
//                             ),
//                           ),

//                           submittedPinTheme: defaultPinTheme.copyWith(
//                             decoration: defaultPinTheme.decoration!.copyWith(
//                               color: fillColor,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: focusedBorderColor),
//                             ),
//                           ),
//                           errorPinTheme: defaultPinTheme.copyBorderWith(
//                             border: Border.all(color: Colors.red),
//                           ),
//                         ),
//                         Gap.h24,

//                         // Resend code
//                         Center(
//                           child: RichText(
//                             text: TextSpan(
//                               text: "Didn't get a code? ",
//                               style: TextStyle(
//                                 color: AppColors.textPrimaryHintColor,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: 'Resend',
//                                   style: TextStyle(
//                                     color: AppColors.textAppLaurel,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         Gap.h12,

//                         // Verify button
//                         ListenableBuilder(
//                           listenable: _authController,
//                           builder: (context, _) {
//                             return context.primaryButton(
//                               isLoading: _authController.isLoading,
//                               onPressed: () {
//                                 final otp = pinController.text;
//                                 if (otp.length == 6) {
//                                   _submit(otp);
//                                 } else {
//                                   // Show error message
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         'Please enter a valid 6-digit code.',
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               text: "Verify",
//                             );
//                           },
//                         ),
//                       ],
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
