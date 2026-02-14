import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../models/connection_request_model.dart';
import '../theme/app_colors.dart';
import 'conversation_view.dart';

class CreateChatView extends StatefulWidget {
  const CreateChatView({super.key});

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthController>();
      final chat = context.read<ChatController>();
      await Future.wait([
        chat.loadUsersWithStatus(auth.user!.id),
        chat.loadReceivedRequests(auth.user!.id),
      ]);
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final chat = context.watch<ChatController>();
    final myId = auth.user!.id;
    final users = chat.usersWithStatus;
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading && users.isEmpty) {
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
          title: Text(
            'All users',
            style: GoogleFonts.poppins(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        title: Text(
          'All users',
          style: GoogleFonts.poppins(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                'No other users. Open another device and sign in.',
                style: GoogleFonts.poppins(
                    color: colorScheme.onSurfaceVariant, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: users.length,
              itemBuilder: (context, i) {
                final u = users[i];
                final status = u.connectionStatus ?? 'none';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side:
                        BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(
                                color: AppColors.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: GoogleFonts.poppins(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: ${u.id}',
                                style: GoogleFonts.poppins(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (status == 'none')
                          TextButton.icon(
                            onPressed: () async {
                              final ok =
                                  await chat.sendConnectionRequest(myId, u.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Request sent'
                                      : 'Could not send request'),
                                  backgroundColor: ok
                                      ? AppColors.online
                                      : Colors.red.shade300,
                                ),
                              );
                            },
                            icon: Icon(IconlyLight.send,
                                size: 18, color: colorScheme.primary),
                            label: Text('Send request',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary)),
                          ),
                        if (status == 'pending_sent')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              'Pending',
                              style: GoogleFonts.poppins(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        if (status == 'pending_received')
                          TextButton.icon(
                            onPressed: () async {
                              ConnectionRequestModel? req;
                              for (final r in chat.receivedRequests) {
                                if (r.fromUserId == u.id) {
                                  req = r;
                                  break;
                                }
                              }
                              if (req == null) return;
                              final ok = await chat.acceptConnectionRequest(
                                  req.id, myId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok ? 'Accepted' : 'Failed'),
                                  backgroundColor: ok
                                      ? AppColors.online
                                      : Colors.red.shade300,
                                ),
                              );
                            },
                            icon: const Icon(IconlyLight.tick_square, size: 18),
                            label: Text('Accept',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        if (status == 'connected')
                          TextButton.icon(
                            onPressed: () async {
                              final c = await chat.createChat(myId, u.id);
                              if (!context.mounted) return;
                              if (c != null) {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ConversationView(chat: c)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Connect first. Send a request and wait for acceptance.')),
                                );
                              }
                            },
                            icon: const Icon(IconlyLight.chat, size: 18),
                            label: Text('Chat',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
