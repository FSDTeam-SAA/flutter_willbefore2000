import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/constants/app_icons_const.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import 'package:smilestreats/core/styles/decorations.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import 'package:smilestreats/feature/auth/presentation/providers/auth_provider.dart';

import '../../../../core/common/widgets/app_scaffold.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _logout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(RoutePaths.home);
      }
    } catch (e) {
      DPrint.error("Logout nav error : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action is permanent and all your data (orders, cart, etc.) will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authProvider.notifier).deleteAccount();
        if (mounted) {
          context.go(RoutePaths.home);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        DPrint.error("Delete account nav error : $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete account failed: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppScaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile avatar placeholder
            SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: AppDecorations.cardDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLaurel.withAlpha(
                          (0.1 * 255).toInt(),
                        ),
                        border: Border.all(color: AppColors.primaryLaurel),
                      ),
                      child: ClipOval(
                        child:
                            user?.photoURL != null && user!.photoURL!.isNotEmpty
                            ? AppCachedImage(
                                imageUrl: user.photoURL!,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primaryLaurel,
                              ),
                      ),
                    ),

                    Gap.w20,

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User name
                        (user?.displayName ?? "").text18w500(
                          color: AppColors.textAppLaurel,
                        ),

                        Gap.h4,
                        // Email
                        (user?.email ?? "").text12w400(),

                        Gap.h4,
                        // SS number
                        (user?.phoneNumber ?? "").text12w400(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Gap.h24,

            Container(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: AppDecorations.cardDecoration,
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () {
                      context.pushNamed(RoutePaths.personalInfoName);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.security_outlined,
                    title: 'Account Security',
                    onTap: () {
                      context.pushNamed(RoutePaths.changePassword);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: () {
                      context.pushNamed(RoutePaths.appPrivacyPolicy);
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      context.pushNamed(RoutePaths.appTermsAndConditions);
                    },
                  ),
                ],
              ),
            ),

            Gap.h24,

            // Logout button
            context.secondaryButton(
              onPressed: () => _logout(),
              isLoading: authState.isLoading,
              borderRadius: 30,
              height: 48,
              borderColor: AppColors.errorRed,
              textColor: AppColors.errorRed,
              prefixIconPath: AssetsPath.logout,
              text: "Log Out",
            ),

            Gap.h16,

            // Delete account button
            context.secondaryButton(
              onPressed: () => _deleteAccount(),
              isLoading: authState.isLoading,
              borderRadius: 30,
              height: 48,
              borderColor: AppColors.errorRed,
              textColor: AppColors.errorRed,
              // Reuse logout icon or person_remove if available
              prefixIconPath: AssetsPath.deleteAccount,
              text: "Delete Account",
            ),
            Gap.h24,
          ],
        ),
      ),

      // Menu items
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(title, style: TextStyle(color: AppColors.textAppBlack)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
