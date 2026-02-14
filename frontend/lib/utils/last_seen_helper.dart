import 'package:intl/intl.dart';

String formatLastSeen(int? lastSeenMs) {
  if (lastSeenMs == null) return 'Online';
  final now = DateTime.now();
  final then = DateTime.fromMillisecondsSinceEpoch(lastSeenMs);
  final diff = now.difference(then);
  final today = DateTime(now.year, now.month, now.day);
  final thenDate = DateTime(then.year, then.month, then.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (diff.inSeconds < 60) return 'Last seen just now';
  if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} min ago';
  if (diff.inHours < 24) return 'Last seen ${diff.inHours} hr ago';
  if (thenDate == yesterday) {
    return 'Last seen yesterday at ${DateFormat('HH:mm').format(then)}';
  }
  if (diff.inDays < 7) return 'Last seen ${diff.inDays} days ago';
  if (then.year == now.year) {
    return 'Last seen ${DateFormat('MMM d').format(then)}';
  }
  return 'Last seen ${DateFormat('MMM d, yyyy').format(then)}';
}
