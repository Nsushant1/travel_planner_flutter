import 'package:flutter/material.dart';

// ─── Shimmer engine ───────────────────────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              Color(0xFFE8EDF2),
              Color(0xFFF5F7FA),
              Color(0xFFECF0F5),
              Color(0xFFE8EDF2),
            ],
            stops: const [0.0, 0.4, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

// ─── Saved trips skeleton card ────────────────────────────────────────────────

class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Column(
        children: [
          // Header area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ShimmerBox(
              width: double.infinity,
              height: 80,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          // Info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                ShimmerBox(
                    width: 72,
                    height: 24,
                    borderRadius: BorderRadius.circular(6)),
                const SizedBox(width: 8),
                ShimmerBox(
                    width: 56,
                    height: 24,
                    borderRadius: BorderRadius.circular(6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent trip tile skeleton ────────────────────────────────────────────────

class TripTileSkeleton extends StatelessWidget {
  const TripTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Row(
        children: [
          ShimmerBox(
              width: 44, height: 44, borderRadius: BorderRadius.circular(12)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: 120,
                    height: 14,
                    borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 6),
                ShimmerBox(
                    width: 90,
                    height: 11,
                    borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
          ShimmerBox(
              width: 60, height: 22, borderRadius: BorderRadius.circular(6)),
        ],
      ),
    );
  }
}
