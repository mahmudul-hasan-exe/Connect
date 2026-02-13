import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../models/user_model.dart';
import '../theme/app_colors.dart';
import 'chat_view.dart';
import 'new_chat_view.dart';
import 'notification_view.dart';
import 'profile_view.dart';
import 'widgets/chat_tile.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final chat = context.read<ChatController>();
      chat.setToken(auth.token);
      chat.loadChats(auth.user!.id);
      chat.loadUsers();
      chat.loadReceivedRequests(auth.user!.id);
      auth.socket.setOnMessage((msg) => chat.addMessage(msg, myUserId: auth.user?.id));
      auth.socket.setOnMessageStatus((messageId, status) => chat.updateMessageStatus(messageId, status));
      auth.socket.setOnUserOnline((userId, online, lastSeen) => chat.updateUserStatus(userId, online, lastSeen));
      auth.socket.setOnTyping((chatId, userId, isTyping) => chat.setTyping(chatId, userId, isTyping));
      auth.socket.setOnFriendRequest((data) {
        final r = ConnectionRequestModel.fromJson(Map<String, dynamic>.from(data));
        chat.addReceivedRequest(r);
      });
      auth.socket.setOnFriendRequestAccepted((_) {
        final uid = auth.user?.id;
        if (uid != null) chat.loadUsersWithStatus(uid);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final chat = context.watch<ChatController>();
    final userName = auth.user?.name ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (auth.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: Text(
          'Connect',
          style: GoogleFonts.poppins(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(IconlyLight.notification, color: colorScheme.onSurface, size: 22),
                onPressed: () {
                  chat.loadReceivedRequests(auth.user!.id);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationView()),
                  );
                },
              ),
              if (chat.pendingRequestsCount > 0 || chat.totalUnreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${chat.pendingRequestsCount + chat.totalUnreadCount > 99 ? 99 : chat.pendingRequestsCount + chat.totalUnreadCount}',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Hi, $userName',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Stay connected with people who matter.',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
          ],
          Expanded(
            child: chat.loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading chats...',
                          style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : chat.chats.isEmpty
                    ? _EmptyState(onStartChat: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewChatView()),
                        );
                      })
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: chat.chats.length,
                        itemBuilder: (context, i) {
                          final c = chat.chats[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ChatTile(
                              chat: c,
                              isOtherTyping: chat.isOtherTyping(c.id, c.otherUser?.id),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatView(chat: c),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: chat.chats.isNotEmpty && !chat.loading
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewChatView()),
                  );
                },
                backgroundColor: AppColors.primary,
                elevation: 0,
                child: const Icon(IconlyBold.plus, color: AppColors.onPrimary, size: 28),
              ),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartChat;

  const _EmptyState({required this.onStartChat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconlyLight.message,
                size: 56,
                color: colorScheme.primary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: GoogleFonts.poppins(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a chat with someone to see your messages here.',
              style: GoogleFonts.poppins(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onStartChat,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconlyBold.plus, color: AppColors.onPrimary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Start chat',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
