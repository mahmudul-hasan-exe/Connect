import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_model.dart';
import '../theme/app_colors.dart';
import '../utils/last_seen_helper.dart';
import 'widgets/message_bubble.dart';

class ConversationView extends StatefulWidget {
  final ChatModel chat;

  const ConversationView({super.key, required this.chat});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  ChatController? _chatController;
  AuthController? _authController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatController ??= context.read<ChatController>();
    _authController ??= context.read<AuthController>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = _chatController ?? context.read<ChatController>();
      final auth = _authController ?? context.read<AuthController>();
      chat.loadMessages(widget.chat.id, userId: auth.user?.id);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    final chat = _chatController;
    WidgetsBinding.instance.addPostFrameCallback((_) => chat?.clearMessages());
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<AuthController>().socket.sendMessage(widget.chat.id, text);
    _textController.clear();
    context.read<AuthController>().socket.emitTyping(widget.chat.id, false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final chat = context.watch<ChatController>();
    ChatModel currentChat = widget.chat;
    for (final c in chat.chats) {
      if (c.id == widget.chat.id) {
        currentChat = c;
        break;
      }
    }
    final other = currentChat.otherUser;
    final myId = auth.user!.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left_2,
              color: colorScheme.onSurface, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary,
              child: Text(
                other?.name.isNotEmpty == true
                    ? other!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    other?.name ?? 'Chat',
                    style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chat.isOtherTyping(widget.chat.id, other?.id))
                    Text(
                      'typing...',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    )
                  else if (other != null)
                    Text(
                      other.online ? 'Online' : formatLastSeen(other.lastSeen),
                      style: TextStyle(
                        color: other.online
                            ? AppColors.online
                            : colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(IconlyLight.video,
                  color: colorScheme.onSurface, size: 22),
              onPressed: () {}),
          IconButton(
              icon: Icon(IconlyLight.call,
                  color: colorScheme.onSurface, size: 22),
              onPressed: () {}),
          PopupMenuButton<String>(
            icon: Icon(IconlyLight.more_circle,
                color: colorScheme.onSurface, size: 22),
            onSelected: (value) async {
              if (other == null) return;
              if (value == 'block') {
                final ok = await chat.blockUser(myId, other.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(ok ? 'Blocked' : 'Failed'),
                      backgroundColor: ok ? null : Colors.red.shade300),
                );
              } else if (value == 'unblock') {
                final ok = await chat.unblockUser(myId, other.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(ok ? 'Unblocked' : 'Failed'),
                      backgroundColor: ok ? null : Colors.red.shade300),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: currentChat.iBlockedThem ? 'unblock' : 'block',
                child: Row(
                  children: [
                    Icon(
                        currentChat.iBlockedThem
                            ? IconlyLight.tick_square
                            : IconlyLight.lock,
                        size: 20,
                        color: colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text(currentChat.iBlockedThem ? 'Unblock' : 'Block',
                        style: GoogleFonts.poppins(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentChat.iBlockedThem)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(IconlyLight.lock,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('You have blocked this user',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          if (currentChat.blockedByThem)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(IconlyLight.lock, size: 18, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text('You are blocked by this user',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          Expanded(
            child: chat.currentChatId != widget.chat.id
                ? Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary))
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) {
                      final msg = chat.messages[chat.messages.length - 1 - i];
                      final isMe = msg.senderId == myId;
                      return MessageBubble(
                        message: msg,
                        isMe: isMe,
                        showTime: true,
                      );
                    },
                  ),
          ),
          if (!currentChat.blockedByThem)
            Container(
              color: colorScheme.surfaceContainerHighest,
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: 8 + MediaQuery.of(context).padding.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(
                            color: colorScheme.onSurface, fontSize: 16),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: (_) {
                          auth.socket.emitTyping(
                              widget.chat.id, _textController.text.isNotEmpty);
                        },
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: colorScheme.outline.withValues(alpha: 0.3)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: _send,
                        borderRadius: BorderRadius.circular(24),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(IconlyBold.send,
                              color: AppColors.onPrimary, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.only(
                  bottom: 8 + MediaQuery.of(context).padding.bottom),
              child: SafeArea(
                top: false,
                child: Center(
                  child: Text(
                    'You cannot send messages',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
