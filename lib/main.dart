import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/extensions.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/providers/controller_provider.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:kart_project/widgets/lockscreen.dart';
import 'package:kart_project/widgets/main/main.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(KartProject());
}

/// Implements all necessary providers for the project. Shows a dark loading
/// screen until the database is loaded up and the
class KartProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilProvider(),
      child: Selector<ProfilProvider, bool>(
        selector: (context, profilProvider) => profilProvider.initalized,
        builder: (context, initalized, child) {
          if (!initalized) return Container(color: Colors.black);
          return child;
        },
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BootProvider(),
            ),
            ChangeNotifierProxyProvider2<ProfilProvider, BootProvider,
                AppearanceProvider>(
              create: (context) => AppearanceProvider(context),
              update: (_, profilProvider, bootProvider, appearanceProvider) {
                return appearanceProvider.update(
                  profilProvider.currentProfil,
                  bootProvider.locked,
                );
              },
            ),
            ChangeNotifierProxyProvider<ProfilProvider, MapProvider>(
              create: (context) => MapProvider(context),
              update: (_, profilProvider, mapProvider) {
                return mapProvider.update(profilProvider.currentProfil);
              },
            ),
            ChangeNotifierProvider(
              create: (context) => ControllerProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => NotificationsProvider(),
            ),
          ],
          child: Core(),
        ),
      ),
    );
  }
}

/// Implements the core widget [MaterialApp]. Sets up different values like the
/// [ThemeMode] and [routes]. Also takes the core widget of the [OverlaySupport].
class Core extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Kart Project',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: context.watch<AppearanceProvider>().themeMode,
        initialRoute: Root.route,
        routes: {
          Root.route: (context) => Root(),
          Settings.route: (context) => Settings(),
        },
      ),
    );
  }
}

/// Shows a loading screen until all necessary components are loaded.
/// Afterwards requestes a pin of the user to unlock the kart.
class Root extends StatelessWidget {
  static String route = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Selector<BootProvider, bool>(
        selector: (context, bootProvider) => bootProvider.locked,
        builder: (context, locked, child) {
          if (locked) return Lockscreen();
          return child;
        },
        child: Main(),
      ),
    );
  }
}
