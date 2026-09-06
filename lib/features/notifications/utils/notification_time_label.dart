import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

String notificationTimeLabel(DateTime? date, AppLocalizations l10n) {
  if (date == null) {
    return '';
  }

  final DateTime local = date.toLocal();
  final Duration diff = DateTime.now().difference(local);

  if (diff.inMinutes < 1) {
    return l10n.justNow;
  }
  if (diff.inMinutes < 60) {
    return l10n.minutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.hoursAgo(diff.inHours);
  }
  if (diff.inDays == 1) {
    return l10n.yesterday;
  }
  if (diff.inDays < 7) {
    return l10n.daysAgo(diff.inDays);
  }

  return DateFormat.yMMMd(l10n.localeName).format(local);
}
