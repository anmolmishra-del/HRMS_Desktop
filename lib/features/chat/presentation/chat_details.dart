import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/features/chat/model/chat_model.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatChannel channel;
  const ChatDetailScreen({super.key, required this.channel});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatAttachment> _pendingAttachments = [];
  int _lastMessageCount = 0;
  late ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    _chatCubit.fetchMessages(widget.channel.id);
  }

  @override
  void dispose() {
    // Safely clear the active chat using the stored cubit reference
    _chatCubit.clearActiveChat(widget.channel.id);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.bytes != null) {
            _pendingAttachments.add(ChatAttachment(
              id: 0,
              name: file.name,
              bytes: file.bytes!,
              mimeType: lookupMimeType(file.name) ?? 'application/octet-stream',
            ));
          }
        }
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _pendingAttachments.removeAt(index);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;

    final attachmentsCopy = List<ChatAttachment>.from(_pendingAttachments);
    _messageController.clear();
    setState(() {
      _pendingAttachments.clear();
    });

    final success = await _chatCubit.sendMessage(
      widget.channel.id, 
      text,
      attachments: attachmentsCopy.isNotEmpty ? attachmentsCopy : null,
    );
    
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                // Only scroll if we actually received new messages
                if (state.status == ChatStatus.loaded && state.activeMessages.length != _lastMessageCount) {
                  _lastMessageCount = state.activeMessages.length;
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state.status == ChatStatus.loading && state.activeMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.indigo));
                }

                if (state.activeMessages.isEmpty && state.status == ChatStatus.loaded) {
                  return _buildEmptyChat(context);
                } 

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: state.activeMessages.length,
                  itemBuilder: (context, index) {
                    final message = state.activeMessages[index];
                    return _MessageBubble(key: ValueKey(message.id), message: message);
                  },
                );
              },
            ),
          ),
          if (_pendingAttachments.isNotEmpty) _buildAttachmentPreview(),
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _buildSmallAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.channel.type == ChannelType.chat 
                      ? (widget.channel.imStatus != null ? widget.channel.imStatus![0].toUpperCase() + widget.channel.imStatus!.substring(1) : 'Offline') 
                      : '${widget.channel.memberCount} members',
                  style: TextStyle(
                    fontSize: 12, 
                    color: widget.channel.imStatus == 'online' ? Colors.green : Colors.grey
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: AppColors.indigo),
          onPressed: () => _showFeatureSoon(context, 'Video Call'),
        ),
        IconButton(
          icon: const Icon(Icons.phone_rounded, color: AppColors.indigo, size: 20),
          onPressed: () => _showFeatureSoon(context, 'Voice Call'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showFeatureSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.indigo,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSmallAvatar() {
    if (widget.channel.image != null && widget.channel.image != "false" && widget.channel.image!.isNotEmpty) {
      try {
        final bytes = base64Decode(widget.channel.image!.trim());
        return CircleAvatar(
          radius: 18,
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultSmallAvatarContent(),
            ),
          ),
        );
      } catch (e) {
        return _buildDefaultSmallAvatar();
      }
    }
    return _buildDefaultSmallAvatar();
  }

  Widget _buildDefaultSmallAvatarContent() {
    return Center(
      child: Text(
        widget.channel.displayName.isNotEmpty ? widget.channel.displayName[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDefaultSmallAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.indigo.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: _buildDefaultSmallAvatarContent(),
    );
  }

  Widget _buildEmptyChat(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No messages yet. Say hello!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pendingAttachments.length,
        itemBuilder: (context, index) {
          final att = _pendingAttachments[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.indigo.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.attach_file_rounded, size: 14, color: AppColors.indigo),
                const SizedBox(width: 6),
                Text(
                  att.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _removeAttachment(index),
                  child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
            child: IconButton(
              onPressed: _pickFiles, 
              icon: const Icon(Icons.add, color: AppColors.indigo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: AppColors.indigo, shape: BoxShape.circle),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.sender,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.indigo : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isMe ? 20 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.attachments != null && message.attachments!.isNotEmpty)
                  _buildAttachments(context),
                Text(
                  message.message,
                  style: TextStyle(
                    color: message.isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.formattedDate,
                      style: TextStyle(
                        fontSize: 10,
                        color: message.isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                      ),
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      BlocBuilder<ChatCubit, ChatState>(
                        buildWhen: (previous, current) => 
                            previous.partnerLastSeenMessageId != current.partnerLastSeenMessageId,
                        builder: (context, state) {
                          final isRead = state.partnerLastSeenMessageId != null && 
                                        state.partnerLastSeenMessageId! >= message.id;
                          return Icon(
                            isRead ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 14,
                            color: isRead ? Colors.cyanAccent : Colors.white.withOpacity(0.7),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    final images = message.attachments!.where((a) => a.mimeType?.startsWith('image/') ?? false).toList();
    final others = message.attachments!.where((a) => !(a.mimeType?.startsWith('image/') ?? false)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images.map((img) => _buildImageAttachment(context, img)).toList(),
            ),
          ),
        if (others.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: others.map((att) => _buildFileAttachment(context, att)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildImageAttachment(BuildContext context, ChatAttachment att) {
    return GestureDetector(
      onTap: () => _handleAttachmentClick(context, att),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 200,
          color: Colors.black.withOpacity(0.05),
          child: FutureBuilder<Uint8List?>(
            future: context.read<ChatCubit>().downloadAttachment(att.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)));
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(
                  snapshot.data!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                );
              }
              return const Center(child: Icon(Icons.image_rounded, color: Colors.grey));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFileAttachment(BuildContext context, ChatAttachment att) {
    return GestureDetector(
      onTap: () => _handleAttachmentClick(context, att),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(att.mimeType),
              size: 20,
              color: message.isMe ? Colors.white : AppColors.indigo,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                att.name,
                style: TextStyle(
                  color: message.isMe ? Colors.white : AppColors.textDark,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_rounded;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (mimeType.contains('word') || mimeType.contains('officedocument')) return Icons.description_rounded;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) return Icons.table_chart_rounded;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Icons.archive_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Future<void> _handleAttachmentClick(BuildContext context, ChatAttachment att) async {
    try {
      final cubit = context.read<ChatCubit>();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading ${att.name}...'), duration: const Duration(seconds: 1)),
      );

      final bytes = await cubit.downloadAttachment(att.id);
      if (bytes == null) throw 'Could not download file';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${att.name}');
      await file.writeAsBytes(bytes);

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
