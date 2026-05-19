import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/constants/app_colors.dart';
import 'package:hrms_desktop/features/chat/model/chat_model.dart';
import 'package:hrms_desktop/features/chat/presentation/chat_details.dart';
import 'package:intl/intl.dart';  
import '../../../core/theme/app_theme.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';


class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ChatCubit>().initChat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showContactPicker() async {
    final allContacts = await context.read<ChatCubit>().fetchContacts();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredContacts = allContacts.where((c) {
              final name = (c['name'] ?? '').toString().toLowerCase();
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        Text(
                          'Start New Chat',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search people...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.indigo),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade200),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty ? 'No contacts found' : 'No matches for "$searchQuery"',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: filteredContacts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                leading: _buildContactAvatar(contact['image_128']),
                                title: Text(
                                  contact['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                subtitle: Text(
                                  (contact['function'] is String ? contact['function'] : null) ??
                                      (contact['email'] is String ? contact['email'] : null) ??
                                      'Employee',
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                ),
                                onTap: () async {
                                  final partnerId = contact['id'];
                                  if (partnerId != null) {
                                    final navigator = Navigator.of(context);
                                    final chatCubit = context.read<ChatCubit>();
                                    final ChatChannel? channel = await chatCubit.createDirectMessage(partnerId);
                                    if (channel != null && mounted) {
                                      navigator.pop(); // Close sheet safely
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (context) => ChatDetailScreen(channel: channel),
                                        ),
                                      ).then((_) {
                                        if (mounted) {
                                          chatCubit.fetchChannels();
                                        }
                                      });
                                    }
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContactAvatar(dynamic imageBase64) {
    if (imageBase64 is String && imageBase64 != "false" && imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64.trim());
        return CircleAvatar(
          radius: 20,
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
            ),
          ),
        );
      } catch (e) {
        return const CircleAvatar(radius: 20, child: Icon(Icons.person));
      }
    }
    return const CircleAvatar(radius: 20, child: Icon(Icons.person));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : Colors.white,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.indigo,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Channels'),
            Tab(text: 'Direct Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChannelList(ChannelType.channel),
          _buildChannelList(ChannelType.chat),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPicker,
        backgroundColor: AppColors.indigo,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildChannelList(ChannelType type) {
    return BlocBuilder<ChatCubit, ChatState>(
      // FIX: Only rebuild when the actual list data changes, NOT on every loading state.
      // This prevents the full-screen spinner from appearing during background polls.
      buildWhen: (previous, current) {
        final prevItems = type == ChannelType.channel ? previous.channels : previous.directMessages;
        final currItems = type == ChannelType.channel ? current.channels : current.directMessages;
        // Rebuild only if: initial load is done, or the list itself changes
        return (previous.status == ChatStatus.loading && current.status == ChatStatus.loaded) ||
               prevItems.length != currItems.length ||
               prevItems != currItems;
      },
      builder: (context, state) {
        // Only show full spinner on very first load (no data yet)
        if (state.status == ChatStatus.loading && state.channels.isEmpty && state.directMessages.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.indigo));
        }

        final items = type == ChannelType.channel ? state.channels : state.directMessages;

        if (items.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ChatCubit>().fetchChannels(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            // FIX: Use ValueKey with channel ID so Flutter ALWAYS maps
            // the correct widget to the correct channel — prevents wrong chat opening.
            itemBuilder: (context, index) {
              final channel = items[index];
              return _ChannelTile(
                key: ValueKey(channel.id),
                channel: channel,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ChannelType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == ChannelType.channel ? Icons.forum_outlined : Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            type == ChannelType.channel ? 'No Channels Found' : 'No Direct Messages',
            style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final ChatChannel channel;
  const _ChannelTile({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('ChatListPage: Tapped on channel ${channel.displayName} (ID: ${channel.id})');
            // Capture channel reference before navigation to prevent stale closure
            final selectedChannel = channel;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(channel: selectedChannel),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<ChatCubit>().fetchChannels();
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(context),
                  if (channel.type == ChannelType.chat && channel.imStatus != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _getStatusColor(channel.imStatus!),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            channel.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (channel.lastMessageTime.isNotEmpty)
                          Text(
                            channel.lastMessageTime,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.lastMessage.isEmpty ? 'No messages yet' : channel.lastMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: channel.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                              fontWeight: channel.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (channel.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.indigo,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              channel.unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildAvatar(BuildContext context) {
    if (channel.image != null && channel.image != "false" && channel.image!.isNotEmpty) {
      try {
        final bytes = base64Decode(channel.image!.trim());
        return CircleAvatar(
          radius: 28,
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatarContent(),
            ),
          ),
        );
      } catch (e) {
        return _buildDefaultAvatar();
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatarContent() {
    return Center(
      child: Text(
        channel.displayName.isNotEmpty ? channel.displayName[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo, AppColors.brightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildDefaultAvatarContent(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'offline':
      default:
        return Colors.grey;
    }
  }
}
