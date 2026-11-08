import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/guest_usage_session.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    if (email.toLowerCase() != 'demo@dealix.ai' || password != 'Dealix123') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid demo credentials. Please try again.'),
        ),
      );
      return;
    }

    GuestUsageSession.instance.endGuestSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Decorative mint waves using shared AppColors.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 155,
            child: IgnorePointer(
              child: CustomPaint(painter: BottomWavesPainter()),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dealix AI logo.
                          Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryTeal,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.mediumRadius,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.mediumRadius,
                                ),
                                child: Image.asset(
                                  'lib/core/Assets/logo.jpeg',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Log in to see your watchlist and alerts',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                          ),

                          const SizedBox(height: 23),

                          // Email field.
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              hint: 'Email or phone',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 9),

                          // Password field.
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            decoration: _inputDecoration(
                              hint: 'Password',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 9),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Forgot password UI is not connected yet.',
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.secondaryTeal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          //login button

                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // OR divider.
                          const Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.border,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 13),

                          // Google sign-in UI.
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Google sign-in is not connected yet.',
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                backgroundColor: AppColors.white,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.mediumRadius,
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GoogleLogo(),
                                  SizedBox(width: 9),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Material(
                            color: AppColors.lightMint,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.mediumRadius,
                              ),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                AppTheme.mediumRadius,
                              ),
                              onTap: () {
                                GuestUsageSession.instance.startGuestSession();
                                final navigator = Navigator.of(context);
                                navigator.pushNamedAndRemoveUntil(
                                  AppRouter.home,
                                  (_) => false,
                                );
                                navigator.pushNamed(AppRouter.freeUsage);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.secondaryTeal,
                                      size: 23,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Continue as Guest',
                                            style: TextStyle(
                                              color: AppColors.secondaryTeal,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Get 2 free product checks',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Signup navigation.
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: AppColors.secondaryTeal,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Google logo SVG.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 17,
      child: SvgPicture.asset(
        'assets/images/google_g_logo.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}

// Decorative bottom waves using shared theme colors.
class BottomWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backPaint = Paint()
      ..color = AppColors.softMint
      ..style = PaintingStyle.fill;

    final frontPaint = Paint()
      ..color = AppColors.lightMint
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height * 0.17)
      ..cubicTo(
        size.width * 0.13,
        size.height * 0.25,
        size.width * 0.12,
        size.height * 0.77,
        size.width * 0.40,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.80,
        size.width * 0.79,
        size.height * 0.25,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backPath, backPaint);

    final frontPath = Path()
      ..moveTo(0, size.height * 0.43)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.80,
        size.width * 0.33,
        size.height * 0.90,
        size.width * 0.53,
        size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.85,
        size.width * 0.85,
        size.height * 0.57,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant BottomWavesPainter oldDelegate) => false;
}
