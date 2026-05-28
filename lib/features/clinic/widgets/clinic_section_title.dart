import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class ClinicSectionTitle extends StatelessWidget {
  const ClinicSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.title.copyWith(fontSize: 21));
  }
}
