import 'package:flutter/material.dart';
import '../../theme/paalvandi_theme.dart';

/// Reusable shimmer skeleton loader for loading states across all screens.
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                PaalvandiTheme.shimmerBase,
                PaalvandiTheme.shimmerHighlight,
                PaalvandiTheme.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card that mimics a full order/subscription card
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PaalvandiTheme.cardDecoration,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 100, height: 16),
              SkeletonLoader(width: 60, height: 16),
            ],
          ),
          SizedBox(height: 12),
          SkeletonLoader(height: 14),
          SizedBox(height: 8),
          SkeletonLoader(width: 200, height: 14),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonLoader(height: 40)),
              SizedBox(width: 8),
              Expanded(child: SkeletonLoader(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A full-screen skeleton dashboard for home loading state
class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 200, height: 28),
          SizedBox(height: 8),
          SkeletonLoader(width: 140, height: 16),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: SkeletonLoader(height: 90)),
              SizedBox(width: 12),
              Expanded(child: SkeletonLoader(height: 90)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SkeletonLoader(height: 90)),
              SizedBox(width: 12),
              Expanded(child: SkeletonLoader(height: 90)),
            ],
          ),
          SizedBox(height: 24),
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
        ],
      ),
    );
  }
}
