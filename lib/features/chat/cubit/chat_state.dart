import 'package:equatable/equatable.dart';
import 'package:hrms_desktop/features/chat/model/chat_model.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatChannel> channels;
  final List<ChatChannel> directMessages;
  final List<ChatMessage> activeMessages;
  final String? errorMessage;
  final String? currentChatId;
  final int? partnerLastSeenMessageId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.channels = const [],
    this.directMessages = const [],
    this.activeMessages = const [],
    this.errorMessage,
    this.currentChatId,
    this.partnerLastSeenMessageId,
  });

  // FIX: Use sentinel objects to allow explicitly setting nullable fields to null.
  // Previously, copyWith(currentChatId: null) was silently ignored because of
  // "null ?? this.currentChatId" — the old value was always kept.
  static const _clearString = Object();
  static const _clearInt = Object();

  ChatState copyWith({
    ChatStatus? status,
    List<ChatChannel>? channels,
    List<ChatChannel>? directMessages,
    List<ChatMessage>? activeMessages,
    String? errorMessage,
    Object? currentChatId = _clearString, // sentinel trick
    Object? partnerLastSeenMessageId = _clearInt,
  }) {
    return ChatState(
      status: status ?? this.status,
      channels: channels ?? this.channels,
      directMessages: directMessages ?? this.directMessages,
      activeMessages: activeMessages ?? this.activeMessages,
      errorMessage: errorMessage ?? this.errorMessage,
      currentChatId: identical(currentChatId, _clearString)
          ? this.currentChatId
          : currentChatId as String?,
      partnerLastSeenMessageId: identical(partnerLastSeenMessageId, _clearInt)
          ? this.partnerLastSeenMessageId
          : partnerLastSeenMessageId as int?,
    );
  }

  // Convenience method to explicitly clear nullable fields
  ChatState clearCurrentChat() {
    return ChatState(
      status: status,
      channels: channels,
      directMessages: directMessages,
      activeMessages: const [],
      errorMessage: errorMessage,
      currentChatId: null,
      partnerLastSeenMessageId: null,
    );
  }

  @override
  List<Object?> get props => [
    status, channels, directMessages, activeMessages,
    errorMessage, currentChatId, partnerLastSeenMessageId
  ];
}
