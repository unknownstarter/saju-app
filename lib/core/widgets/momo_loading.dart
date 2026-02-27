import 'package:flutter/material.dart';

/// 모모 캐릭터 로딩 스피너
///
/// loading_spinner.gif를 사용한 공통 로딩 위젯.
/// GIF는 자동 무한 반복됩니다.
class MomoLoading extends StatelessWidget {
  const MomoLoading({
    super.key,
    this.size = 64,
  });

  /// 스피너 크기 (정사각형)
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/characters/loading_spinner.gif',
        width: size,
        height: size,
      ),
    );
  }
}
