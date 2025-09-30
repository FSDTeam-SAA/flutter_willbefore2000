import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import 'package:smilestreats/feature/auth/presentation/providers/auth_provider.dart';
import 'package:smilestreats/core/common/widgets/app_scaffold.dart';

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
                    style: GoogleFonts.notoSansKr(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textAppBlack,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email available',
                    style: GoogleFonts.notoSansKr(
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
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLaurel,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Phone Number',
              user?.phoneNumber ?? '(555) 123-4567',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Email Address',
              user?.email ?? 'alexjohnson@example.com',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Home Address',
              '123 Main Street San Francisco, CA 94105',
            ),
            const SizedBox(height: 24),
            // Personal Details
            Text(
              'Personal Details',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLaurel,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date of Birth', '1985-06-15'),
            const SizedBox(height: 24),
            // Edit Button
            SizedBox(
              width: double.infinity,
              child: context.primaryButton(
                onPressed: () {
                  // Navigate to edit screen or show edit dialog
                  // context.pushNamed(RoutePaths.editProfile);
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textAppBlack,
            ),
          ),
        ),
      ],
    );
  }
}
