import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_step_title.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Step 2: pick a date. The calendar's month paging state lives here so
/// swiping months never rebuilds the rest of the screen.
class DateStep extends StatefulWidget {
  const DateStep({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<DateStep> createState() => _DateStepState();
}

class _DateStepState extends State<DateStep> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(now.year, now.month, now.day);
    final DateTime lastDay = firstDay.add(const Duration(days: 180));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: <Widget>[
        BookingStepTitle(
          title: l10n.selectDate,
          subtitle: l10n.selectDateSubtitle,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: TableCalendar<void>(
            locale: Localizations.localeOf(context).toLanguageTag(),
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (DateTime day) =>
                isSameDay(widget.selectedDate, day),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState(() => _focusedDay = focusedDay);
              widget.onDateSelected(selectedDay);
            },
            onPageChanged: (DateTime focusedDay) {
              _focusedDay = focusedDay;
            },
            availableCalendarFormats: <CalendarFormat, String>{
              CalendarFormat.month: l10n.calendarMonth,
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTextStyles.smallCaps,
              weekendStyle: AppTextStyles.smallCaps,
            ),
            daysOfWeekHeight: 28,
            rowHeight: 44,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              disabledTextStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textFaint,
              ),
              todayTextStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary),
              ),
              selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
