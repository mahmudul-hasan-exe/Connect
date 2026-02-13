import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../theme/app_colors.dart';
import 'chat_view.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final chat = context.read<ChatController>();
      chat.loadReceivedRequests(auth.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final chat = context.watch<ChatController>();
    final myId = auth.user!.id;
    final colorScheme = Theme.of(context).colorScheme;
    final requests = chat.receivedRequests;
    final messageNotifications = chat.chats.where((c) => c.unread > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left_2, color: colorScheme.onSurface, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (requests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Friend requests',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...requests.map((req) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        req.fromUserName.isNotEmpty ? req.fromUserName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.fromUserName,
                            style: GoogleFonts.poppins(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'ID: ${req.fromUserId}',
                            style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sent you a friend request',
                            style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final ok = await chat.acceptConnectionRequest(req.id, myId);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Accepted. You can chat now.' : 'Failed'),
                            backgroundColor: ok ? AppColors.online : Colors.red.shade300,
                          ),
                        );
                      },
                      icon: const Icon(IconlyLight.tick_square, size: 18),
                      label: Text('Accept', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
          if (messageNotifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Messages',
                style: GoogleFonts.poppins(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...messageNotifications.map((c) {
              final other = c.otherUser;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatView(chat: c)),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            other?.name.isNotEmpty == true ? other!.name[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                other?.name ?? 'Unknown',
                                style: GoogleFonts.poppins(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${c.unread} unread message${c.unread > 1 ? 's' : ''}',
                                style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.unread > 99 ? '99+' : '${c.unread}',
                            style: GoogleFonts.poppins(color: AppColors.onPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          if (requests.isEmpty && messageNotifications.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(IconlyLight.notification, size: 56, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
