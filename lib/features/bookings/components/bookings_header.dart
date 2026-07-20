import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingsHeader extends StatelessWidget {
  const BookingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: SizedBox(
        height: 52,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed: () {
                  // Bookings is usually reached via goNamed (bottom nav),
                  // so the stack is empty — fall back to Home.
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.goNamed(RouteNames.home);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.primary,
                iconSize: 22,
              ),
            ),
            Expanded(
              child: Text(
                'My Appointments',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}
