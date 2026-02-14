import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import '../../models/chat_model.dart';
import '../../theme/app_colors.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final bool isOtherTyping;
  final VoidCallback onTap;

  const ChatTile(
      {super.key,
      required this.chat,
      required this.isOtherTyping,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final other = chat.otherUser;
    final last = chat.lastMessage;
    final time = last != null
        ? DateFormat(last.createdAt >
                    DateTime.now().millisecondsSinceEpoch - 86400000
                ? 'HH:mm'
                : 'MMM d')
            .format(DateTime.fromMillisecondsSinceEpoch(last.createdAt))
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08), width: 1),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: other?.online == true
                            ? AppColors.online
                            : colorScheme.outline.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: colorScheme.primary,
                      child: other != null
                          ? Text(
                              other.name.isNotEmpty
                                  ? other.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                color: AppColors.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const Icon(IconlyBold.profile,
                              color: AppColors.onPrimary, size: 24),
                    ),
                  ),
                  if (other?.online == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.surfaceContainerHighest,
                              width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      other?.name ?? 'Unknown',
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOtherTyping
                          ? 'typing...'
                          : (last != null
                              ? last.text
                              : 'Tap to start chatting'),
                      style: GoogleFonts.poppins(
                        color: isOtherTyping
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontStyle:
                            isOtherTyping ? FontStyle.italic : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: chat.unread > 0 ? 80 : 52,
                child: chat.unread > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          time.isNotEmpty
                              ? Text(
                                  time,
                                  style: GoogleFonts.poppins(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : const SizedBox.shrink(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chat.unread > 99 ? '99+' : '${chat.unread}',
                              style: GoogleFonts.poppins(
                                color: AppColors.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: time.isNotEmpty
                            ? Text(
                                time,
                                style: GoogleFonts.poppins(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
