import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48.0 : 24.0,
            vertical: 32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isTablet ? 96.0 : 64.0,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 32),
              Text(
                'Page Not Found',
                style: isTablet
                    ? theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textAppBlack,
                      )
                    : theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textAppBlack,
                      ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The page you are looking for doesn\'t exist or has been moved.',
                style: isTablet
                    ? theme.textTheme.bodyLarge
                    : theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: isTablet ? 300 : double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryLaurel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.goNamed(RoutePaths.home),
                  child: Text(
                    'Return to Home',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isTablet) const SizedBox(height: 24),
              if (isTablet)
                SizedBox(
                  width: 300,
                  child: TextButton(
                    onPressed: () => context.goNamed(RoutePaths.login),
                    child: Text(
                      'Switch Accounts',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryLaurel,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
