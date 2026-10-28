import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/guest_usage_session.dart';
import '../../widgets/common/secondary_button.dart';

class FreeUsageScreen extends StatefulWidget {
  static const int _searchLimit = GuestUsageSession.searchLimit;

  final int usedSearches;

  const FreeUsageScreen({super.key, this.usedSearches = 0})
    : assert(usedSearches >= 0 && usedSearches <= _searchLimit);

  @override
  State<FreeUsageScreen> createState() => _FreeUsageScreenState();
}

class _FreeUsageScreenState extends State<FreeUsageScreen> {
  final GuestUsageSession _guestSession = GuestUsageSession.instance;

  @override
  void initState() {
    super.initState();
    _guestSession.addListener(_onUsageChanged);
  }

  @override
  void dispose() {
    _guestSession.removeListener(_onUsageChanged);
    super.dispose();
  }

  void _onUsageChanged() {
    if (mounted) setState(() {});
  }

  int get _usedSearches =>
      _guestSession.isGuest ? _guestSession.usedSearches : widget.usedSearches;

  int get _remainingSearches => FreeUsageScreen._searchLimit - _usedSearches;

  bool get _isLimitReached => _remainingSearches == 0;

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Widget _buildUsageCard(
    BuildContext context, {
    required bool compact,
    required bool tight,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(
        tight
            ? 8
            : compact
            ? 10
            : 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreenTeal.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_remainingSearches of ${FreeUsageScreen._searchLimit} free searches remaining',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.secondaryTeal,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        fontSize: compact ? 14 : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                ),
                child: Text(
                  'DEMO',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryTeal,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: tight
                ? 6
                : compact
                ? 8
                : 20,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            child: LinearProgressIndicator(
              value: _usedSearches / FreeUsageScreen._searchLimit,
              minHeight: tight
                  ? 6
                  : compact
                  ? 8
                  : 10,
              backgroundColor: AppColors.softMint,
              color: _isLimitReached
                  ? AppColors.error
                  : AppColors.secondaryTeal,
            ),
          ),
          SizedBox(
            height: tight
                ? 6
                : compact
                ? 8
                : 18,
          ),
          Row(
            children: [
              Expanded(
                child: _UsageCount(
                  label: 'Used',
                  count: _usedSearches,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              Container(
                width: 1,
                height: tight
                    ? 28
                    : compact
                    ? 32
                    : 38,
                color: AppColors.border,
              ),
              Expanded(
                child: _UsageCount(
                  label: 'Remaining',
                  count: _remainingSearches,
                  icon: Icons.hourglass_bottom_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard(
    BuildContext context, {
    required bool compact,
    required bool tight,
  }) {
    return Container(
      padding: EdgeInsets.all(
        tight
            ? 8
            : compact
            ? 12
            : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: tight
                ? 32
                : compact
                ? 36
                : 42,
            height: tight
                ? 32
                : compact
                ? 36
                : 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.secondaryTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make more of Dealix',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: tight
                      ? 2
                      : compact
                      ? 3
                      : 5,
                ),
                Text(
                  'Create an account to keep your product discoveries organized and unlock more powerful features.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: tight ? 1.2 : 1.45,
                    color: AppColors.textPrimary,
                    fontSize: tight ? 11 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: const Text('Free Usage'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 680;
            final tight = constraints.maxHeight < 520;
            final sectionGap = tight
                ? 2.0
                : compact
                ? 6.0
                : 14.0;
            final iconCircleSize = tight
                ? 76.0
                : compact
                ? 88.0
                : 94.0;
            final showDemoNotice = constraints.maxHeight >= 700;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: tight ? 16 : 20,
                    vertical: compact ? 0 : 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: iconCircleSize,
                            height: iconCircleSize,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: AppColors.softMint,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.card_giftcard_rounded,
                                  color: AppColors.secondaryTeal,
                                  size: tight
                                      ? 44
                                      : compact
                                      ? 48
                                      : 52,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: tight
                                ? 6
                                : compact
                                ? 10
                                : 18,
                          ),
                          Text(
                            'Free Plan',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            height: tight
                                ? 2
                                : compact
                                ? 3
                                : 8,
                          ),
                          Text(
                            "Try two searches as a guest. It's a quick way to explore Dealix AI and discover great products.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  height: compact ? 1.25 : 1.5,
                                  fontSize: tight
                                      ? 11
                                      : compact
                                      ? 12
                                      : null,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionGap),
                      _buildUsageCard(context, compact: compact, tight: tight),
                      SizedBox(height: sectionGap),
                      if (_isLimitReached)
                        _LimitReachedMessage(compact: compact, tight: tight)
                      else
                        _buildBenefitsCard(
                          context,
                          compact: compact,
                          tight: tight,
                        ),
                      SizedBox(height: sectionGap),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLimitReached) ...[
                            SizedBox(
                              height: tight
                                  ? 40
                                  : compact
                                  ? 46
                                  : 50,
                              child: SecondaryButton(
                                text: 'Create Account',
                                onPressed: () =>
                                    _openRoute(context, AppRouter.signup),
                              ),
                            ),
                            SizedBox(
                              height: tight
                                  ? 0
                                  : compact
                                  ? 2
                                  : 8,
                            ),
                            SizedBox(
                              height: tight
                                  ? 36
                                  : compact
                                  ? 40
                                  : 48,
                              child: TextButton(
                                onPressed: () =>
                                    _openRoute(context, AppRouter.login),
                                child: const Text('Log In'),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              height: tight
                                  ? 42
                                  : compact
                                  ? 48
                                  : 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRouter.search,
                                    ModalRoute.withName(AppRouter.home),
                                    arguments: '',
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryTeal,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.mediumRadius,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Continue Searching',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: tight
                                  ? 2
                                  : compact
                                  ? 4
                                  : 8,
                            ),
                            SizedBox(
                              height: tight
                                  ? 40
                                  : compact
                                  ? 46
                                  : 50,
                              child: SecondaryButton(
                                text: 'Create Account',
                                onPressed: () =>
                                    _openRoute(context, AppRouter.signup),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showDemoNotice) ...[
                        SizedBox(height: compact ? 2 : 6),
                        _DemoNotice(compact: compact),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UsageCount extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _UsageCount({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isRemaining = label == 'Remaining';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isRemaining && count == 0
              ? AppColors.error
              : AppColors.secondaryTeal,
          size: 21,
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }
}

class _LimitReachedMessage extends StatelessWidget {
  final bool compact;
  final bool tight;

  const _LimitReachedMessage({required this.compact, required this.tight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        tight
            ? 7
            : compact
            ? 10
            : 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: tight
                ? 40
                : compact
                ? 48
                : 58,
            height: tight
                ? 40
                : compact
                ? 48
                : 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.error,
              size: tight
                  ? 24
                  : compact
                  ? 26
                  : 32,
            ),
          ),
          SizedBox(
            height: tight
                ? 4
                : compact
                ? 6
                : 12,
          ),
          Text(
            'Free searches used',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: tight
                ? 2
                : compact
                ? 3
                : 6,
          ),
          Text(
            'You’ve used both demo searches. Create an account or log in to continue.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: tight
                  ? 1.15
                  : compact
                  ? 1.25
                  : 1.45,
              fontSize: tight
                  ? 11
                  : compact
                  ? 12
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  final bool compact;

  const _DemoNotice({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          color: AppColors.secondaryTeal,
          size: compact ? 15 : 17,
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Demo counts are temporary and reset after each session.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: compact ? 10 : null,
            ),
          ),
        ),
      ],
    );
  }
}
