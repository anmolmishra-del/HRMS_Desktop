import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/features/chat/model/chat_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/shared_pref.dart';
import 'chat_state.dart';
import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/navigation/navigator_service.dart';
import 'package:hrms_desktop/features/chat/presentation/chat_details.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  WebSocketChannel? _channelSocket;
  StreamSubscription? _channelSubscription;
  Timer? _pollingTimer;
  final Map<int, Uint8List> _attachmentCache = {};

  // KEY FIX: Store the timestamp of WHEN we last successfully read a channel.
  // This is used to suppress stale unread counts from the server for a short window.
  final Map<int, DateTime> _channelReadTimestamps = {};
  bool _isFirstLoad = true;

  Future<void> initChat() async {
    emit(state.copyWith(status: ChatStatus.loading));
    await fetchChannels();
    _startPolling(); // Always start reliable background polling
    _initWebSockets();
  }

  Future<void> _initWebSockets() async {
    try {
      _channelSubscription?.cancel();
      try {
        _channelSocket?.sink.close();
      } catch (_) {}

      final prefs = SharedPref();
      final baseUrl = await prefs.getString('baseUrl');
      final sessionJson = await prefs.getObject('session');
      final port=await prefs.getObject('port');

      if (baseUrl == null || sessionJson == null) {
        debugPrint('ChatCubit: Missing baseUrl or session data. Cannot init WebSockets.');
        return;
      }

      final uri = Uri.parse(baseUrl.trim());
      final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final host = uri.host;
      final wsUrl = '$wsScheme://$host:${port ?? 7075}/websocket';
      final session = OdooSession.fromJson(sessionJson);
      final sessionId = session.id;

      debugPrint('ChatCubit: ==========================================');
      debugPrint('ChatCubit: Initializing Odoo 18 WebSocket Connection');
      debugPrint('ChatCubit: Base URL: $baseUrl');
      debugPrint('ChatCubit: Host: $host');
      debugPrint('ChatCubit: Target WS URL: $wsUrl');
      debugPrint('ChatCubit: Session ID (Cookie): ${sessionId != null ? "PRESENT (${sessionId.toString().substring(0, 6)}...)" : "MISSING"}');
      debugPrint('ChatCubit: ==========================================');

      _channelSocket = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Cookie': 'session_id=$sessionId'},
      );

      _channelSocket!.ready.catchError((e) {
        // debugPrint('ChatCubit: [WebSocket Ready Error Handled] --> $e');
      });

      _channelSubscription = _channelSocket!.stream.listen(
        (message) async {
          debugPrint('ChatCubit: [WebSocket Event Received] --> $message');
          try {
            json.decode(message);
          } catch (_) {}
          if (state.currentChatId != null) {
            await fetchMessages(int.parse(state.currentChatId!), quiet: true);
          }
          await fetchChannels();
        },
        // onError: (error) {
        //   debugPrint('ChatCubit: [WebSocket Error Handled] --> $error');
        // },
        onDone: () {
          debugPrint('ChatCubit: [WebSocket Closed / Disconnected]');
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('ChatCubit: [WebSocket Connection Exception Handled] --> $e');
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    debugPrint('ChatCubit: [Polling Activated] --> Polling every 5 seconds.');
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      debugPrint('ChatCubit: [Polling Execution] --> Fetching active chat messages & latest channels.');
      if (state.currentChatId != null) {
        await fetchMessages(int.parse(state.currentChatId!), quiet: true);
      }
      await fetchChannels();
    });
  }

  Future<void> fetchChannels() async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return;

      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final channelMembers = await client.callKw({
        'model': 'discuss.channel.member',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['partner_id', '=', session.partnerId]],
          'fields': [
            'channel_id',
            'message_unread_counter',
            'custom_channel_name',
            'is_pinned',
            'seen_message_id',
            'fetched_message_id',
            'last_interest_dt'
          ],
        },
      });

      final channelIds = (channelMembers as List)
          .map((m) => m['channel_id'])
          .where((id) => id != null)
          .map((id) {
            final val = id is List ? id[0] : id;
            return val is int ? val : int.tryParse(val.toString());
          })
          .whereType<int>()
          .toList();

      final channelRecords = await client.callKw({
        'model': 'discuss.channel',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['id', 'in', channelIds]],
          'fields': ['id', 'name', 'channel_type', 'display_name', 'image_128', 'channel_member_ids', 'description', 'active'],
        },
      });

      final List<ChatChannel> channels = [];
      final List<ChatChannel> dms = [];

      final allMembers = await client.callKw({
        'model': 'discuss.channel.member',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['channel_id', 'in', channelIds]],
          'fields': ['channel_id', 'partner_id'],
        },
      });

      final List<int> partnerIdsToFetch = [];
      for (var m in (allMembers as List)) {
        if (m['partner_id'] is List && m['partner_id'][0] != session.partnerId) {
          partnerIdsToFetch.add(m['partner_id'][0]);
        }
      }

      Map<int, String> partnerStatuses = {};
      Map<int, String?> partnerImages = {};
      if (partnerIdsToFetch.isNotEmpty) {
        final partners = await client.callKw({
          'model': 'res.partner',
          'method': 'read',
          'args': [partnerIdsToFetch, ['im_status', 'image_128']],
          'kwargs': {},
        });
        for (var p in (partners as List)) {
          partnerStatuses[p['id']] = p['im_status'] ?? 'offline';
          partnerImages[p['id']] = p['image_128'] is String ? p['image_128'] : null;
        }
      }

      Map<int, Map<String, dynamic>> lastMessages = {};
      Map<int, List<int>> channelMessageIds = {};

      if (channelIds.isNotEmpty) {
        final messages = await client.callKw({
          'model': 'mail.message',
          'method': 'search_read',
          'args': [[['res_id', 'in', channelIds], ['model', '=', 'discuss.channel']]],
          'kwargs': {
            'fields': ['id', 'res_id', 'body', 'date'],
            'order': 'date desc',
            'limit': 1000,
          },
        });
        for (var m in (messages as List)) {
          final resId = m['res_id'] is List ? m['res_id'][0] : m['res_id'];
          final msgId = m['id'] as int? ?? 0;
          if (resId != null && msgId > 0) {
            if (!lastMessages.containsKey(resId)) {
              lastMessages[resId] = {
                'id': msgId,
                'body': _stripHtml(m['body'] is String ? m['body'] : ''),
                'date': m['date']
              };
            }
            channelMessageIds.putIfAbsent(resId, () => []).add(msgId);
          }
        }
      }

      final now = DateTime.now();

      for (var json in (channelRecords as List)) {
        final channel = ChatChannel.fromJson(json, session.userName, session.partnerId);
        final memberInfo = (channelMembers as List).firstWhere(
          (m) => (m['channel_id'] is List ? m['channel_id'][0] : m['channel_id']) == channel.id,
          orElse: () => {},
        );

        String? imStatus;
        String? partnerImage;
        if (channel.type == ChannelType.chat) {
          final otherMember = (allMembers as List).firstWhere(
            (m) => (m['channel_id'] is List ? m['channel_id'][0] : m['channel_id']) == channel.id &&
                   (m['partner_id'] is List ? m['partner_id'][0] : m['partner_id']) != session.partnerId,
            orElse: () => null,
          );
          if (otherMember != null) {
            final pid = otherMember['partner_id'] is List ? otherMember['partner_id'][0] : otherMember['partner_id'];
            imStatus = partnerStatuses[pid];
            partnerImage = partnerImages[pid];
          }
        }

        final lastMsgInfo = lastMessages[channel.id];
        final lastMsgDate = _parseOdooDate(lastMsgInfo?['date']);
        final lastMsgTime = lastMsgDate != null
            ? (lastMsgDate.year == now.year && lastMsgDate.month == now.month && lastMsgDate.day == now.day
                ? DateFormat('h:mm a').format(lastMsgDate)
                : DateFormat('MMM d').format(lastMsgDate))
            : '';

        final rawDisplayName = memberInfo['custom_channel_name'] is String ? memberInfo['custom_channel_name'] : channel.displayName;
        final finalDisplayName = _formatDisplayName(rawDisplayName, session.userName, channel.type);

        final isCurrentChat = state.currentChatId == channel.id.toString();
        int unreadCount = memberInfo['message_unread_counter'] ?? 0;

        final seenIdRaw = memberInfo['seen_message_id'];
        int seenId = 0;
        if (seenIdRaw is int) seenId = seenIdRaw;
        else if (seenIdRaw is List && seenIdRaw.isNotEmpty) seenId = seenIdRaw[0];

        final lastMsgId = lastMsgInfo?['id'] as int? ?? 0;
        final msgIds = channelMessageIds[channel.id] ?? [];

        // WHATSAPP-LIKE SYNC:
        // Calculate unread count with mathematical precision by checking local message IDs strictly greater than seenId.
        if (isCurrentChat) {
          unreadCount = 0;
        } else if (seenId > 0 && lastMsgId > 0 && seenId >= lastMsgId) {
          unreadCount = 0; // Verified: user has already seen the newest message in this channel
        } else if (_channelReadTimestamps.containsKey(channel.id)) {
          final sinceRead = now.difference(_channelReadTimestamps[channel.id]!).inSeconds;
          if (sinceRead < 8) {
            unreadCount = 0; // Server still syncing, keep badge clear
          } else {
            _channelReadTimestamps.remove(channel.id);
            if (seenId > 0 && msgIds.isNotEmpty) {
              unreadCount = msgIds.where((id) => id > seenId).length;
            }
          }
        } else if (seenId > 0 && msgIds.isNotEmpty) {
          unreadCount = msgIds.where((id) => id > seenId).length;
        }

        final updatedChannel = ChatChannel(
          id: channel.id,
          name: channel.name,
          displayName: finalDisplayName,
          type: channel.type,
          unreadCount: unreadCount,
          isPinned: memberInfo['is_pinned'] ?? false,
          memberCount: channel.memberCount,
          image: (channel.image == null || channel.image == "false") ? partnerImage : channel.image,
          description: channel.description,
          active: channel.active,
          imStatus: imStatus,
          lastMessage: lastMsgInfo?['body'] ?? '',
          lastMessageTime: lastMsgTime,
          lastMessageRaw: lastMsgDate,
        );

        if (updatedChannel.type == ChannelType.chat) dms.add(updatedChannel);
        else channels.add(updatedChannel);
      }

      channels.sort((a, b) {
        final aTime = a.lastMessageRaw;
        final bTime = b.lastMessageRaw;
        if (aTime != null && bTime != null) {
          return bTime.compareTo(aTime);
        }
        if (aTime != null) return -1;
        if (bTime != null) return 1;
        return b.id.compareTo(a.id);
      });

      dms.sort((a, b) {
        final aTime = a.lastMessageRaw;
        final bTime = b.lastMessageRaw;
        if (aTime != null && bTime != null) {
          return bTime.compareTo(aTime);
        }
        if (aTime != null) return -1;
        if (bTime != null) return 1;
        return b.id.compareTo(a.id);
      });

      // Trigger desktop notifications for new unread messages
      if (!_isFirstLoad) {
        final List<ChatChannel> allFresh = [...channels, ...dms];
        final List<ChatChannel> allOld = [...state.channels, ...state.directMessages];

        for (var fresh in allFresh) {
          final old = allOld.firstWhere(
            (c) => c.id == fresh.id,
            orElse: () => ChatChannel(id: fresh.id, name: '', displayName: '', type: fresh.type),
          );
          
          if (fresh.unreadCount > old.unreadCount) {
            debugPrint('ChatCubit: [NOTIFICATION TRIGGERED] Channel: ${fresh.displayName}, Old Unread: ${old.unreadCount}, New Unread: ${fresh.unreadCount}, Last Message: ${fresh.lastMessage}');
            try {
              final LocalNotification notification = LocalNotification(
                identifier: 'new_msg_${fresh.id}',
                title: fresh.displayName,
                subtitle: fresh.type == ChannelType.chat ? 'New Direct Message' : 'New Channel Message',
                body: fresh.lastMessage.isNotEmpty ? fresh.lastMessage : 'New message received',
                silent: false,
              );
              notification.onShow = () {
                debugPrint('ChatCubit: [Notification Success] Notification displayed on screen.');
              };
              notification.onClick = () async {
                debugPrint('ChatCubit: [Notification Clicked] User clicked the notification.');
                
                // 1. Bring the app window to the front
                try {
                  if (await windowManager.isMinimized()) {
                    await windowManager.restore();
                  }
                  await windowManager.show();
                  await windowManager.focus();
                } catch (e) {
                  debugPrint('ChatCubit: Error focusing window: $e');
                }

                // 2. Navigate to the chat details screen
                if (state.currentChatId == fresh.id.toString()) {
                  debugPrint('ChatCubit: User is already looking at this chat. Skip pushing duplicate screen.');
                  return;
                }

                final context = NavigatorService.navigatorKey.currentContext;
                if (context != null) {
                  // If we are looking at a different chat details screen, pop it first to prevent nesting!
                  if (state.currentChatId != null && state.currentChatId!.isNotEmpty) {
                    try {
                      Navigator.pop(context);
                    } catch (e) {
                      debugPrint('ChatCubit: Error popping old chat details: $e');
                    }
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(channel: fresh),
                    ),
                  );
                }
              };
              notification.onClose = (reason) {
                debugPrint('ChatCubit: [Notification Closed] Reason: $reason');
              };
              notification.show();
            } catch (e) {
              debugPrint('ChatCubit: [Notification Error] Local notification failed to show: $e');
            }
          }
        }
      } else {
        _isFirstLoad = false;
        debugPrint('ChatCubit: Initial channels loaded, _isFirstLoad set to false.');
      }

      emit(state.copyWith(status: ChatStatus.loaded, channels: channels, directMessages: dms));
    } catch (e) {
      debugPrint('ChatCubit: Fetch Channels Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchContacts() async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return [];
      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);
      final result = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [['user_ids', '!=', false], ['id', '!=', session.partnerId]],
          'fields': ['id', 'name', 'email', 'image_128', 'function'],
          'limit': 100,
        },
      });
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Fetch Contacts Error: $e');
      return [];
    }
  }

  Future<ChatChannel?> createDirectMessage(int partnerId) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return null;
      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);
      debugPrint('ChatCubit: Calling channel_get for partnerId $partnerId');
      final result = await client.callKw({
        'model': 'discuss.channel',
        'method': 'channel_get',
        'args': [],
        'kwargs': {'partners_to': [partnerId]},
      });

      debugPrint('ChatCubit: channel_get Result Type: ${result.runtimeType}');
      debugPrint('ChatCubit: channel_get Result Payload: $result');

      if (result != null) {
        // Case 1: Result is a direct Map
        if (result is Map && result['id'] != null) {
          final channelMap = Map<String, dynamic>.from(result);
          final channel = ChatChannel.fromJson(channelMap, session.userName, session.partnerId);
          final formattedChannel = channel.copyWith(
            displayName: _formatDisplayName(channel.displayName, session.userName, channel.type)
          );
          fetchChannels();
          return formattedChannel;
        }

        // Case 2: Result is a List of maps
        if (result is List && result.isNotEmpty && result[0] is Map && result[0]['id'] != null) {
          final channelMap = Map<String, dynamic>.from(result[0]);
          final channel = ChatChannel.fromJson(channelMap, session.userName, session.partnerId);
          final formattedChannel = channel.copyWith(
            displayName: _formatDisplayName(channel.displayName, session.userName, channel.type)
          );
          fetchChannels();
          return formattedChannel;
        }

        // Case 3: Result is a Map containing Odoo 18 discuss.channel metadata
        if (result is Map && result.containsKey('discuss.channel')) {
          final channelList = result['discuss.channel'];
          if (channelList is List && channelList.isNotEmpty) {
            final channelMap = Map<String, dynamic>.from(channelList[0]);
            final channel = ChatChannel.fromJson(channelMap, session.userName, session.partnerId);
            final formattedChannel = channel.copyWith(
              displayName: _formatDisplayName(channel.displayName, session.userName, channel.type)
            );
            fetchChannels();
            return formattedChannel;
          }
        }

        // Case 4: Result is an integer ID (Common in Odoo 17/18)
        if (result is int) {
          debugPrint('ChatCubit: channel_get returned integer ID ($result). Fetching channel details...');
          final channelRecords = await client.callKw({
            'model': 'discuss.channel',
            'method': 'search_read',
            'args': [],
            'kwargs': {
              'domain': [['id', '=', result]],
              'fields': ['id', 'name', 'channel_type', 'display_name', 'image_128', 'channel_member_ids', 'description', 'active'],
            },
          });

          if (channelRecords != null && channelRecords is List && channelRecords.isNotEmpty) {
            final channelMap = Map<String, dynamic>.from(channelRecords[0]);
            final channel = ChatChannel.fromJson(channelMap, session.userName, session.partnerId);
            final formattedChannel = channel.copyWith(
              displayName: _formatDisplayName(channel.displayName, session.userName, channel.type)
            );
            fetchChannels();
            return formattedChannel;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Create DM Error: $e');
      return null;
    }
  }

  Future<void> fetchMessages(int channelId, {bool quiet = false}) async {
    try {
      // Stamp: record that we read this channel RIGHT NOW
      _channelReadTimestamps[channelId] = DateTime.now();

      // Instant UI update: clear old data and badge before server responds
      final updatedChannels = state.channels.map((c) =>
        c.id == channelId ? c.copyWith(unreadCount: 0) : c).toList();
      final updatedDms = state.directMessages.map((c) =>
        c.id == channelId ? c.copyWith(unreadCount: 0) : c).toList();

      if (state.currentChatId != channelId.toString()) {
        emit(state.copyWith(
          activeMessages: [],
          currentChatId: channelId.toString(),
          status: ChatStatus.loading,
          channels: updatedChannels,
          directMessages: updatedDms,
        ));
      } else {
        emit(state.copyWith(channels: updatedChannels, directMessages: updatedDms));
        if (!quiet && state.activeMessages.isEmpty) {
          emit(state.copyWith(status: ChatStatus.loading));
        }
      }

      debugPrint('ChatCubit: fetchMessages called for channel $channelId');

      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return;
      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final response = await client.callKw({
        'model': 'mail.message',
        'method': 'search_read',
        'args': [[['res_id', '=', channelId], ['model', '=', 'discuss.channel']]],
        'kwargs': {
          'fields': ['id', 'date', 'author_id', 'body', 'message_type', 'attachment_ids', 'subject', 'subtype_id', 'partner_ids', 'needaction', 'starred_partner_ids'],
          'limit': 50,
          'order': 'date desc'
        }
      });

      debugPrint('ChatCubit: fetchMessages response length: ${(response as List).length}');

      final List<ChatMessage> messages = [];
      Map<int, ChatAttachment> attachmentMap = {};
      final List<int> allAttachmentIds = [];
      for (var msg in (response as List)) {
        if (msg['attachment_ids'] is List) allAttachmentIds.addAll((msg['attachment_ids'] as List).cast<int>());
      }
      if (allAttachmentIds.isNotEmpty) {
        final attachmentRecords = await client.callKw({
          'model': 'ir.attachment',
          'method': 'read',
          'args': [allAttachmentIds, ['id', 'name', 'mimetype', 'file_size', 'create_uid']],
          'kwargs': {},
        });
        for (var att in (attachmentRecords as List)) attachmentMap[att['id']] = ChatAttachment.fromJson(att);
      }

      for (var msg in (response as List)) {
        final authorId = msg['author_id'] is List ? msg['author_id'][0] : 0;
        final date = _parseOdooDate(msg['date']) ?? DateTime.now();
        final List<ChatAttachment> msgAttachments = [];
        if (msg['attachment_ids'] is List) {
          for (var id in (msg['attachment_ids'] as List)) {
            if (attachmentMap.containsKey(id)) msgAttachments.add(attachmentMap[id]!);
          }
        }
        messages.add(ChatMessage(
          id: msg['id'],
          sender: msg['author_id'] is List ? msg['author_id'][1] : 'Unknown',
          senderId: authorId,
          message: _stripHtml(msg['body'] ?? ''),
          date: date,
          formattedDate: DateFormat('h:mm a').format(date),
          isMe: authorId == session.partnerId,
          messageType: msg['message_type'],
          attachments: msgAttachments,
        ));
      }

      int? partnerLastSeenId;
      try {
        final members = await client.callKw({
          'model': 'discuss.channel.member',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [['channel_id', '=', channelId]],
            'fields': ['partner_id', 'seen_message_id'],
          },
        });

        debugPrint('ChatCubit: fetchMessages members fetched: ${(members as List).length}');

        int? myMemberId;
        int mySeenMessageId = 0;

        if (members != null && (members as List).isNotEmpty) {
          for (var m in members) {
            final pid = m['partner_id'] is List ? m['partner_id'][0] : m['partner_id'];
            final seenIdRaw = m['seen_message_id'];
            int seenId = 0;
            if (seenIdRaw is int) seenId = seenIdRaw;
            else if (seenIdRaw is List && seenIdRaw.isNotEmpty) seenId = seenIdRaw[0];

            if (pid == session.partnerId) {
              myMemberId = m['id'];
              mySeenMessageId = seenId;
            } else {
              if (partnerLastSeenId == null || seenId > partnerLastSeenId!) {
                partnerLastSeenId = seenId;
              }
            }
          }
        }

        debugPrint('ChatCubit: fetchMessages myMemberId=$myMemberId, mySeenMessageId=$mySeenMessageId, responseNotEmpty=${response.isNotEmpty}');

        if (myMemberId == null && response.isNotEmpty) {
          debugPrint('ChatCubit: myMemberId not found in initial search. Executing targeted query...');
          try {
            final mySelf = await client.callKw({
              'model': 'discuss.channel.member',
              'method': 'search_read',
              'args': [],
              'kwargs': {
                'domain': [['channel_id', '=', channelId], ['partner_id', '=', session.partnerId]],
                'fields': ['seen_message_id'],
              },
            });
            if (mySelf != null && (mySelf as List).isNotEmpty) {
              myMemberId = mySelf[0]['id'];
              final seenIdRaw = mySelf[0]['seen_message_id'];
              int seenId = 0;
              if (seenIdRaw is int) seenId = seenIdRaw;
              else if (seenIdRaw is List && seenIdRaw.isNotEmpty) seenId = seenIdRaw[0];
              mySeenMessageId = seenId;
            }
          } catch (e) {
            debugPrint('ChatCubit: Targeted member query error: $e');
          }
        }

        if (myMemberId != null && response.isNotEmpty) {
          int newestId = response[0]['id'];
          for (var msg in response) {
            if (msg['id'] is int && msg['id'] > newestId) {
              newestId = msg['id'];
            }
          }

          // CRITICAL CHECK: Only mark as seen if user is STILL in this chat
          if (state.currentChatId != channelId.toString()) {
            debugPrint('ChatCubit: Skip mark-as-seen — user already left chat $channelId');
          } else {
            try {
              final writeRes = await client.callKw({
                'model': 'discuss.channel.member',
                'method': 'write',
                'args': [[myMemberId], {
                  'seen_message_id': newestId,
                  'fetched_message_id': newestId,
                  'message_unread_counter': 0,
                }],
                'kwargs': {},
              });
              debugPrint('ChatCubit: [Odoo Write Success] discuss.channel.member write response: $writeRes');
            } catch (err) {
              debugPrint('ChatCubit: [Odoo Write Error] discuss.channel.member write failed: $err');
            }

            // Refresh timestamp after successful server write
            _channelReadTimestamps[channelId] = DateTime.now();
            debugPrint('ChatCubit: Finished marking channel $channelId as seen up to message $newestId');
          }
        }
      } catch (e) {
        debugPrint('ChatCubit: Seen-status update error: $e');
      }

      emit(state.copyWith(
        status: ChatStatus.loaded,
        activeMessages: messages.reversed.toList(),
        currentChatId: channelId.toString(),
        partnerLastSeenMessageId: partnerLastSeenId,
      ));

      if (!quiet) await fetchChannels();
    } catch (e) {
      debugPrint('ChatCubit: Fetch Messages Error: $e');
      emit(state.copyWith(status: ChatStatus.loaded));
    }
  }

  void clearActiveChat(int channelId) {
    _channelReadTimestamps[channelId] = DateTime.now();
    emit(state.clearCurrentChat());
  }

  Future<void> markAsRead(int channelId, int messageId) async {
    // Handled automatically in fetchMessages
  }

  Future<bool> sendMessage(int channelId, String text, {List<ChatAttachment>? attachments}) async {
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return false;
      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final List<int> attachmentIds = [];
      if (attachments != null) {
        for (var att in attachments) {
          if (att.bytes != null) {
            final res = await client.callKw({
              'model': 'ir.attachment',
              'method': 'create',
              'args': [{
                'name': att.name,
                'datas': base64Encode(att.bytes!),
                'res_model': 'discuss.channel',
                'res_id': channelId,
                'mimetype': att.mimeType
              }],
              'kwargs': {},
            });
            if (res != null) attachmentIds.add(res is int ? res : int.parse(res.toString()));
          }
        }
      }
      await client.callKw({
        'model': 'discuss.channel',
        'method': 'message_post',
        'args': [channelId],
        'kwargs': {
          'body': text,
          'message_type': 'comment',
          'subtype_xmlid': 'mail.mt_comment',
          if (attachmentIds.isNotEmpty) 'attachment_ids': attachmentIds
        },
      });
      await fetchMessages(channelId, quiet: false);
      return true;
    } catch (e) {
      debugPrint('Send Message Error: $e');
      return false;
    }
  }

  Future<Uint8List?> downloadAttachment(int attachmentId) async {
    if (_attachmentCache.containsKey(attachmentId)) {
      return _attachmentCache[attachmentId];
    }
    try {
      final prefs = SharedPref();
      final sobj = await prefs.getObject('session');
      final baseUrl = await prefs.getString('baseUrl');
      if (baseUrl == null || sobj == null) return null;
      final session = OdooSession.fromJson(sobj);
      final client = OdooClient(baseUrl, sessionId: session);

      final result = await client.callKw({
        'model': 'ir.attachment',
        'method': 'read',
        'args': [[attachmentId], ['datas']],
        'kwargs': {'context': {'bin_size': false}},
      });

      if (result != null && (result as List).isNotEmpty) {
        var datas = result[0]['datas'];
        if (datas is String && datas != "false") {
          try {
            final cleanedDatas = datas.trim().replaceAll(RegExp(r'\s+'), '');
            final actualBase64 = cleanedDatas.contains(',') ? cleanedDatas.split(',').last : cleanedDatas;
            final bytes = base64Decode(actualBase64);
            _attachmentCache[attachmentId] = bytes;
            return bytes;
          } catch (e) {
            debugPrint('ChatCubit: Base64 decode failed for attachment $attachmentId: $e');
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Download Attachment Error: $e');
      return null;
    }
  }

  String _formatDisplayName(String name, String currentUserName, ChannelType type) {
    if (type != ChannelType.chat) return name;
    final parts = name.split(',').map((s) => s.trim()).toList();
    if (parts.length > 1) {
      parts.removeWhere((n) => n.toLowerCase() == currentUserName.toLowerCase());
      if (parts.isNotEmpty) return parts.join(', ');
    }
    return name;
  }

  String _stripHtml(String html) {
    if (html.isEmpty) return "";
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  DateTime? _parseOdooDate(String? dateStr) {
    if (dateStr == null || dateStr == "false" || dateStr.isEmpty) return null;
    try {
      String normalized = dateStr.trim();
      if (!normalized.contains('T')) normalized = normalized.replaceFirst(' ', 'T');
      if (!normalized.endsWith('Z') && !normalized.contains('+')) normalized = '${normalized}Z';
      return DateTime.parse(normalized).toLocal();
    } catch (e) {
      return DateTime.tryParse(dateStr!)?.toLocal();
    }
  }

  @override
  Future<void> close() {
    _channelSubscription?.cancel();
    try {
      _channelSocket?.sink.close();
    } catch (_) {}
    _pollingTimer?.cancel();
    return super.close();
  }
}
