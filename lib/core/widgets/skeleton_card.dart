import 'package:flutter/material.dart';

/// 매칭 카드 형태의 스켈레톤 로딩 위젯
///
/// shimmer 효과를 가진 플레이스홀더 카드.
/// 홈 페이지의 "오늘의 추천" 로딩 상태에서 사용한다.
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key, this.width = 180, this.height = 260});

  final double width;
  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDE8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진 영역 (shimmer gradient)
              Container(
                height: widget.height * 0.6,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin:
                        Alignment(-1 + 2 * _shimmerController.value, 0),
                    end: Alignment(
                        1 + 2 * _shimmerController.value, 0),
                    colors: const [
                      Color(0xFFE8E4DF),
                      Color(0xFFF0EDE8),
                      Color(0xFFE8E4DF),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // 텍스트 영역
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBar(width: widget.width * 0.5, height: 14),
                    const SizedBox(height: 8),
                    _shimmerBar(width: widget.width * 0.7, height: 12),
                    const SizedBox(height: 8),
                    _shimmerBar(width: widget.width * 0.4, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DF),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
