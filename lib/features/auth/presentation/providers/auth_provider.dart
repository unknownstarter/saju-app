import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

/// AuthRemoteDatasource provider
@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(ref.watch(supabaseClientProvider));
}

/// AuthRepository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
}

/// 현재 로그인 유저의 프로필 (async)
@riverpod
Future<UserEntity?> currentUserProfile(Ref ref) async {
  // auth state가 바뀌면 다시 조회
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).getCurrentUserProfile();
}

/// 프로필 존재 여부 (온보딩 완료 판별)
@riverpod
Future<bool> hasProfile(Ref ref) async {
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).hasProfile();
}

/// Auth 액션 노티파이어 (로그인/로그아웃)
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  /// Apple 로그인
  Future<UserEntity?> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithApple();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Google 로그인
  Future<UserEntity?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signInWithGoogle();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
