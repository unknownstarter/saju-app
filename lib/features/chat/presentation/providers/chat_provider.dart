import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';

// =============================================================================
// 채팅방 목록 Provider
// =============================================================================

/// 채팅방 목록 스트림
///
/// Realtime으로 업데이트되는 채팅방 목록을 제공합니다.
final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';
  if (userId.isEmpty) return const Stream.empty();
  return repo.watchChatRooms(userId);
});

/// 전체 안읽은 메시지 수
final totalUnreadCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';
  if (userId.isEmpty) return 0;
  return repo.getTotalUnreadCount(userId);
});

// =============================================================================
// 채팅방 메시지 Provider
// =============================================================================

/// 특정 채팅방 메시지 스트림
///
/// [roomId]를 family 파라미터로 받아 해당 방의 메시지를 실시간 제공합니다.
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  final repo = ref.watch(chatRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';

  // 채팅방 진입 시 읽음 처리
  if (userId.isNotEmpty) {
    repo.markAsRead(roomId, userId);
  }

  return repo.watchMessages(roomId);
});

/// 특정 채팅방 정보
final chatRoomProvider =
    FutureProvider.family<ChatRoom?, String>((ref, roomId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatRoom(roomId);
});

// =============================================================================
// 메시지 전송 Notifier
// =============================================================================

/// 메시지 전송 상태
class SendMessageNotifier extends StateNotifier<AsyncValue<void>> {
  SendMessageNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  String get _userId => _ref.read(currentUserProvider)?.id ?? '';

  /// 텍스트 메시지 전송
  Future<void> send({
    required String roomId,
    required String content,
  }) async {
    if (content.trim().isEmpty || _userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(chatRepositoryProvider);
      await repo.sendMessage(
        roomId: roomId,
        senderId: _userId,
        content: content.trim(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 이미지 메시지 전송
  Future<void> sendImage({
    required String roomId,
    required String imagePath,
  }) async {
    if (_userId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(chatRepositoryProvider);
      await repo.sendImageMessage(
        roomId: roomId,
        senderId: _userId,
        imagePath: imagePath,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 메시지 삭제
  Future<void> deleteMessage(String messageId) async {
    try {
      final repo = _ref.read(chatRepositoryProvider);
      await repo.deleteMessage(messageId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// 메시지 전송 Provider
final sendMessageProvider =
    StateNotifierProvider<SendMessageNotifier, AsyncValue<void>>((ref) {
  return SendMessageNotifier(ref);
});
