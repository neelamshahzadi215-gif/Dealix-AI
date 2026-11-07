import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user/user_profile.dart';
import '../../services/mock/mock_data_service.dart';
import '../../widgets/common/dealix_main_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _pagePadding = EdgeInsets.fromLTRB(
    20,
    AppTheme.spacingMedium,
    20,
    AppTheme.spacingLarge,
  );
  static const _errorPadding = EdgeInsets.all(AppTheme.spacingLarge);
  static const _cardPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: AppTheme.spacingSmall,
  );
  static const double _logoutSpacing = 20;

  final MockDataService _mockDataService = MockDataService();

  UserProfile? _profile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _mockDataService.getUserProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "We couldn't load your profile. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryTeal),
            )
          : _errorMessage != null
          ? _buildErrorState()
          : _buildProfileContent(_profile!),
      bottomNavigationBar: DealixMainBottomNav(
        selectedItem: DealixMainNavItem.profile,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: _errorPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              color: AppColors.textSecondary,
              size: 44,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            OutlinedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryTeal,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildPersonalInformation(profile),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildAccountRows(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildNotificationsRow(),
          const SizedBox(height: _logoutSpacing),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return _card(
      child: InkWell(
        onTap: () => _showMessage('Profile editing is not available yet.'),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightMint,
              child: Text(
                _initials(profile.name),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondaryTeal,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformation(UserProfile profile) {
    return _card(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_city_outlined,
            label: 'City',
            value: profile.city,
          ),
          const Divider(height: 18, color: AppColors.border),
          _buildInfoRow(
            icon: Icons.payments_outlined,
            label: 'Currency',
            value: profile.currency,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        _rowIcon(icon),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAccountRows() {
    return _card(
      child: Column(
        children: [
          _buildNavigationRow(
            icon: Icons.history_rounded,
            label: 'Previous Searches',
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.search,
              arguments: {'fromProfile': true},
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildNavigationRow(
            icon: Icons.bookmark_border_rounded,
            label: 'Saved Products',
            onTap: () => _showMessage('Saved products are not available yet.'),
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildNavigationRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Send Feedback',
            onTap: _showFeedbackDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            _rowIcon(icon),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsRow() {
    return _card(
      child: Row(
        children: [
          _rowIcon(Icons.notifications_none_rounded),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            key: const ValueKey('notifications_switch'),
            value: _notificationsEnabled,
            activeTrackColor: AppColors.secondaryTeal,
            onChanged: (enabled) {
              setState(() {
                _notificationsEnabled = enabled;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Log out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      child: Padding(padding: _cardPadding, child: child),
    );
  }

  Widget _rowIcon(IconData icon) {
    return Icon(icon, color: AppColors.secondaryTeal, size: 21);
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';

    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  Future<void> _showFeedbackDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text(
          'Feedback submission is not available yet. Thanks for helping us improve Dealix-AI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          "Authentication is not connected yet, so your guest session can't be ended. Would you like to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldLogOut == true && mounted) {
      _showMessage(
        "You're using Dealix-AI as a guest. There is no account to log out yet.",
      );
    }
  }

  void _handleNavigation(DealixMainNavItem item) {
    switch (item) {
      case DealixMainNavItem.home:
        _returnToHome();
      case DealixMainNavItem.alerts:
        _showMessage('Alerts section coming soon.');
      case DealixMainNavItem.scan:
        if (Navigator.canPop(context)) {
          Navigator.pop(context, DealixMainNavItem.scan);
        } else {
          Navigator.pushNamed(context, AppRouter.aiScan);
        }
      case DealixMainNavItem.saved:
        _showMessage('Saved section coming soon.');
      case DealixMainNavItem.profile:
        break;
    }
  }

  void _returnToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.deepGreen,
        ),
      );
  }
}
