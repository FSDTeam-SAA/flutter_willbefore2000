import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smilestreatsapp/core/common/widgets/app_cached_image.dart';
import 'package:smilestreatsapp/core/constants/app_colors.dart';
import 'package:smilestreatsapp/core/utils/extensions/button_extensions.dart';
import 'package:smilestreatsapp/feature/auth/presentation/providers/auth_provider.dart';
import 'package:smilestreatsapp/core/common/widgets/app_scaffold.dart';

import '../../../../core/routes/route_endpoint.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppScaffold(
      safeArea: true,
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
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
                  const SizedBox(height: 8),
                  Text(
                    user?.displayName ?? 'Guest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textAppBlack,
                    ),
                  ),
                  if (user?.email != null && user!.email!.isNotEmpty)
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
            // Contact Information
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLaurel,
              ),
            ),
            const SizedBox(height: 16),
            // Conditionally show Phone Number
            if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoRow('Phone Number', user.phoneNumber!),
              ),
            // Conditionally show Email Address
            if (user?.email != null && user!.email!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInfoRow('Email Address', user.email!),
              ),
            // Conditionally show Home Address (if not hardcoded)
            // Assuming Home Address is fetched from user data, not hardcoded
            // Replace with actual data source if available
            // if (user?. != null && user!.homeAddress!.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 8),
            //     child: _buildInfoRow(
            //       'Home Address',
            //       user.homeAddress!, // Replace with actual field
            //     ),
            //   ),
            const SizedBox(height: 24),
            // Personal Details
            Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLaurel,
              ),
            ),
            const SizedBox(height: 16),
            // Conditionally show Date of Birth (if not hardcoded)
            // Assuming Date of Birth is fetched from user data
            // if (user?. != null && user!.dateOfBirth!.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 8),
            //     child: _buildInfoRow(
            //       'Date of Birth',
            //       user.dateOfBirth!, // Replace with actual field
            //     ),
            //   ),
            const SizedBox(height: 24),
            // Edit Button
            SizedBox(
              width: double.infinity,
              child: context.primaryButton(
                onPressed: () {
                  context.pushNamed(RoutePaths.editProfile);
                },
                text: 'Edit Information',
                borderRadius: 8,
                backgroundColor: AppColors.primaryLaurel.withOpacity(0.8),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textAppBlack,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}
