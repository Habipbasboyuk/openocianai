import 'dart:math';
import 'package:flutter/material.dart';

/// Animated ocean background with ambient motion - slow gradient shifts,
/// floating particles, and subtle wave effects.
class OceanBackground extends StatefulWidget {
  final int particleCount;
  const OceanBackground({super.key, this.particleCount = 15});

  @override
  State<OceanBackground> createState() => _OceanBackgroundState();
}

class _OceanBackgroundState extends State<OceanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rnd = Random(42);

  @override
  void initState() {
    super.initState();
    // Slow ambient animation - 20 seconds for full cycle
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _particles = List.generate(
      widget.particleCount,
      (i) => _Particle.random(_rnd),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _OceanPainter(_particles, _ctrl.value, Theme.of(context)),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x; // relative 0..1
  final double y; // relative 0..1
  final double size; // relative size
  final double speed; // drift speed multiplier
  final double wobbleAmp; // vertical wobble amplitude
  final double wobbleFreq; // wobble frequency
  final double phase; // phase offset
  final Color color;

  _Particle(
    this.x,
    this.y,
    this.size,
    this.speed,
    this.wobbleAmp,
    this.wobbleFreq,
    this.phase,
    this.color,
  );

  factory _Particle.random(Random rnd) {
    final x = rnd.nextDouble();
    final y = rnd.nextDouble();
    final size = 0.04 + rnd.nextDouble() * 0.12; // 4%..16%
    final speed = 0.3 + rnd.nextDouble() * 0.8;
    final wobbleAmp = 0.03 + rnd.nextDouble() * 0.08;
    final wobbleFreq = 0.4 + rnd.nextDouble() * 1.2;
    final phase = rnd.nextDouble();
    // Light-friendly palette - will work well in both dark and light modes
    final palette = [
      const Color(0xFF4ECDC4), // Seafoam
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF80D0F0), // Sky blue
      const Color(0xFF00A3D6), // Ocean blue
      const Color(0xFFB3E5F5), // Light cyan
    ];
    final color = palette[rnd.nextInt(palette.length)].withOpacity(
      0.15 +
          rnd.nextDouble() *
              0.25, // Slightly more opaque for visibility in light mode
    );
    return _Particle(x, y, size, speed, wobbleAmp, wobbleFreq, phase, color);
  }
}

class _OceanPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1 animation progress
  final ThemeData theme;

  _OceanPainter(this.particles, this.t, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = theme.brightness == Brightness.dark;

    // Animated gradient background with slow color shifts
    final rect = Offset.zero & size;

    // Shift gradient colors slowly based on time
    final colorShift = sin(t * 2 * pi) * 0.1;
    final topColor = isDark
        ? Color.lerp(
            const Color(0xFF06303A),
            const Color(0xFF0B3B46),
            0.5 + colorShift,
          )!
        : Color.lerp(
            const Color(0xFFB3E5F5), // Light cyan
            const Color(0xFF80D0F0), // Sky blue
            0.5 + colorShift,
          )!;
    final bottomColor = isDark
        ? Color.lerp(
            const Color(0xFF0B3B46),
            const Color(0xFF06303A),
            0.5 + colorShift,
          )!
        : Color.lerp(
            const Color(0xFFFFF4E6), // Sand/cream
            const Color(0xFFFFE4B5), // Light peach
            0.5 + colorShift,
          )!;

    // Slowly rotating gradient angle
    final angle = t * pi / 4; // Rotate 45° over full cycle
    final grad = LinearGradient(
      begin: Alignment(cos(angle), sin(angle)),
      end: Alignment(-cos(angle), -sin(angle)),
      colors: [topColor, bottomColor],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()..shader = grad.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw subtle wave overlay
    _drawWaveOverlay(canvas, size, isDark);

    // Draw floating particles with ambient motion
    final minDim = min(size.width, size.height);
    for (var particle in particles) {
      final localPhase = (t * particle.speed) % 1.0;

      // Horizontal drift with wrapping
      double posX = particle.x + particle.speed * 0.15 * t;
      posX = posX - posX.floorToDouble();

      // Vertical wobble
      final wobble =
          sin((t + particle.phase) * 2 * pi * particle.wobbleFreq) *
          particle.wobbleAmp;
      final posY = (particle.y + wobble).clamp(0.0, 1.0);

      // Additional subtle circular drift
      final driftX = sin((localPhase + particle.phase) * 2 * pi) * 0.02;
      final driftY = cos((localPhase + particle.phase) * 2 * pi) * 0.015;

      final cx = posX * size.width + driftX * size.width;
      final cy = posY * size.height + driftY * size.height;
      final r = particle.size * minDim;

      // Breathing effect - subtle scale pulsing
      final breathe = 0.9 + sin((t + particle.phase) * 2 * pi * 0.7) * 0.1;
      final finalRadius = r * breathe;

      // Draw particle with soft glow
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.color.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(Offset(cx, cy), finalRadius * 1.8, glowPaint);

      final particlePaint = Paint()..color = particle.color;
      canvas.drawCircle(Offset(cx, cy), finalRadius, particlePaint);
    }
  }

  void _drawWaveOverlay(Canvas canvas, Size size, bool isDark) {
    // Subtle wave lines that move across the screen
    final wavePaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF006994)).withOpacity(
        isDark ? 0.03 : 0.08,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = (t + i * 0.33) * size.width;
      final amplitude = 20.0 + i * 10;
      final frequency = 0.01 + i * 0.005;

      path.moveTo(-waveOffset % size.width, size.height * (0.3 + i * 0.2));

      for (double x = -waveOffset % size.width; x < size.width + 100; x += 5) {
        final y =
            size.height * (0.3 + i * 0.2) +
            sin(x * frequency + t * 2 * pi) * amplitude;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanPainter oldDelegate) => oldDelegate.t != t;
}
