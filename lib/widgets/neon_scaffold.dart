import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/routes.dart';
import '../utils/constants.dart';

class NeonScaffold extends StatelessWidget {
  const NeonScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool showBack;

  void _goBack(BuildContext context) {
    AppScope.of(context).playTap();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF090916), NeonColors.background],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => _goBack(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: NeonColors.cyan,
                        )
                      else
                        const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: NeonColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
