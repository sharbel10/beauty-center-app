import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

void showAuthSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  context.showSnackbar(message, isError: isError);
}
