import 'dart:async';

import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

enum _ExitRouteBehavior { goHome, confirmExit }

class RootExitGuard extends StatefulWidget {
  const RootExitGuard({
    required this.child,
    super.key,
    this.isHomeRoute = false,
    this.isAuthRoute = false,
  });

  final Widget child;
  final bool isHomeRoute;
  final bool isAuthRoute;

  @override
  State<RootExitGuard> createState() => _RootExitGuardState();
}

class _RootExitGuardState extends State<RootExitGuard> {
  static const Duration _exitWindow = Duration(seconds: 2);
  DateTime? _lastBackPressAt;
  Timer? _resetTimer;
  bool _snackbarVisible = false;

  _ExitRouteBehavior get _behavior {
    if (widget.isAuthRoute || widget.isHomeRoute) {
      return _ExitRouteBehavior.confirmExit;
    }
    return _ExitRouteBehavior.goHome;
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _hideSnackBar(BuildContext context) {
    if (_snackbarVisible) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _snackbarVisible = false;
    }
  }

  Future<void> _showExitHint(BuildContext context) async {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final String message =
        // ignore: prefer_null_aware_method_calls
        l10n == null
        ? 'Press back again to exit the app'
        : l10n.pressBackAgainToExit;
    _hideSnackBar(context);

    final SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: _exitWindow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: AppColors.textDark,
      content: Row(
        children: <Widget>[
          const Icon(
            Icons.touch_app_rounded,
            color: AppColors.surface,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    _snackbarVisible = true;
    await ScaffoldMessenger.of(context).showSnackBar(snackBar).closed;
    _snackbarVisible = false;
  }

  Future<bool> _handleWillPop(BuildContext context) async {
    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      return true;
    }

    switch (_behavior) {
      case _ExitRouteBehavior.goHome:
        GoRouter.of(context).goNamed(RouteNames.home);
        return false;
      case _ExitRouteBehavior.confirmExit:
        final DateTime now = DateTime.now();
        final bool shouldExit =
            _lastBackPressAt != null &&
            now.difference(_lastBackPressAt!) < _exitWindow;

        if (shouldExit) {
          _resetTimer?.cancel();
          _hideSnackBar(context);
          return true;
        }

        _lastBackPressAt = now;
        _resetTimer?.cancel();
        _resetTimer = Timer(_exitWindow, () {
          _lastBackPressAt = null;
        });
        unawaited(_showExitHint(context));
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;
        unawaited(
          _handleWillPop(context).then((bool allowPop) {
            if (allowPop && mounted) {
              SystemNavigator.pop();
            }
          }),
        );
      },
      child: widget.child,
    );
  }
}
