import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF00352D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF00352D),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // ==========================================================
                // MAIN BACKGROUND
                // ==========================================================

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF006653),
                        Color(0xFF00483C),
                        Color(0xFF00352D),
                      ],
                    ),
                  ),
                ),

                // ==========================================================
                // TOP RIGHT SHAPES
                // ==========================================================
                Positioned(
                  top: 0,
                  right: 0,
                  child: CustomPaint(
                    size: Size(width * 0.63, height * 0.31),
                    painter: _TopRightShapesPainter(),
                  ),
                ),

                // ==========================================================
                // BOTTOM LEFT SHAPES
                // ==========================================================
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: CustomPaint(
                    size: Size(width * 0.63, height * 0.31),
                    painter: _BottomLeftShapesPainter(),
                  ),
                ),

                // ==========================================================
                // CENTER LOGO
                // ==========================================================
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * 0.285,
                  child: Center(
                    child: SizedBox(
                      width: width * 0.62,
                      child: SvgPicture.asset(
                        'assets/images/dealix_logo_transparent.svg',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                // ==========================================================
                // MOVING LOADING INDICATOR
                // ==========================================================
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * 0.075,
                  child: AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return _LoadingSection(
                        progress: _loadingController.value,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingSection extends StatelessWidget {
  final double progress;

  const _LoadingSection({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 125,
          height: 3,
          child: CustomPaint(painter: _LoadingBarPainter(progress)),
        ),
        const SizedBox(height: 7),
        const Text(
          'Loading...',
          style: TextStyle(
            color: Color(0xFFD1E8E1),
            fontSize: 9,
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MOVING LOADING BAR
// ============================================================================

class _LoadingBarPainter extends CustomPainter {
  final double progress;

  _LoadingBarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFF08715D);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      backgroundPaint,
    );

    const movingWidth = 42.0;

    final x = -movingWidth + ((size.width + movingWidth) * progress);

    final movingRect = Rect.fromLTWH(x, 0, movingWidth, size.height);

    final movingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF35C98A), Color(0xFFB9F8D9), Color(0xFF35C98A)],
      ).createShader(movingRect);

    canvas.save();

    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(movingRect, const Radius.circular(10)),
      movingPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LoadingBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================================
// TOP RIGHT SHAPES
// ============================================================================

class _TopRightShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Path()
      ..moveTo(size.width * 0.18, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.58, size.height * 0.38)
      ..close();

    canvas.drawPath(p1, Paint()..color = const Color(0xFF078C5B));

    final p2 = Path()
      ..moveTo(size.width * 0.46, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.44)
      ..lineTo(size.width * 0.74, size.height * 0.25)
      ..close();

    canvas.drawPath(p2, Paint()..color = const Color(0xFF18B96D));

    final p3 = Path()
      ..moveTo(size.width * 0.69, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.28)
      ..close();

    canvas.drawPath(p3, Paint()..color = const Color(0xFF35D77D));

    final p4 = Path()
      ..moveTo(size.width * 0.34, 0)
      ..lineTo(size.width * 0.67, 0)
      ..lineTo(size.width * 0.88, size.height * 0.25)
      ..lineTo(size.width * 0.65, size.height * 0.18)
      ..close();

    canvas.drawPath(p4, Paint()..color = const Color(0xFF06744F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// BOTTOM LEFT SHAPES
// ============================================================================

class _BottomLeftShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Path()
      ..moveTo(0, size.height * 0.25)
      ..lineTo(size.width * 0.35, size.height * 0.60)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(p1, Paint()..color = const Color(0xFF087852));

    final p2 = Path()
      ..moveTo(0, size.height * 0.50)
      ..lineTo(size.width * 0.25, size.height * 0.72)
      ..lineTo(size.width * 0.43, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(p2, Paint()..color = const Color(0xFF12AA67));

    final p3 = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.17, size.height * 0.32)
      ..lineTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(0, size.height * 0.36)
      ..close();

    canvas.drawPath(p3, Paint()..color = const Color(0xFF075D49));

    final p4 = Path()
      ..moveTo(0, size.height * 0.68)
      ..lineTo(size.width * 0.12, size.height * 0.80)
      ..lineTo(size.width * 0.28, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(p4, Paint()..color = const Color(0xFF0A8C5B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
