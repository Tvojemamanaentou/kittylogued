import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kittylogued/app_services.dart';
import 'package:kittylogued/pages/main_shell.dart';
import 'package:kittylogued/theme/app_themes.dart';

class KittyloguedApp extends StatelessWidget {
  final AppServices services;

  const KittyloguedApp({super.key, required this.services});

  void _goBack() {
    final navigator = services.navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = services.settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final palette = AppThemes.byId(settings.paletteId);
        return MaterialApp(
          title: 'Kittylogued',
          debugShowCheckedModeBanner: false,
          navigatorKey: services.navigatorKey,
          theme: AppThemes.build(
            palette,
            Brightness.light,
            highContrast: settings.highContrast,
          ),
          darkTheme: AppThemes.build(
            palette,
            Brightness.dark,
            highContrast: settings.highContrast,
          ),
          themeMode: settings.themeMode,
          // Everything below (including pushed pages and dialogs) can reach
          // the shared services through AppScope.of(context).
          builder: (context, child) => AppScope(
            services: services,
            child: CallbackShortcuts(
              bindings: {
                // Esc = back, like the Android back button.
                const SingleActivator(LogicalKeyboardKey.escape): _goBack,
              },
              child: Focus(
                autofocus: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
          home: const MainShell(),
        );
      },
    );
  }
}
