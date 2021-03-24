import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/providers/audio_provider.dart';
import 'package:kart_project/providers/cooling_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/lockscreen.dart';
import 'package:kart_project/widgets/main/main.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(KartProject());
}

/// Implements all necessary providers for the project.
///
/// Shows a dark loading screen until the database is initalized. Shows a
/// splashscreen when failed to load the necessary database.
class KartProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfilProvider(),
      child: Selector<ProfilProvider, ProfilsState>(
        selector: (context, profilProvider) => profilProvider.state,
        builder: (context, state, child) {
          if (state == ProfilsState.notInitalized) {
            return Container(color: Colors.black);
          } else if (state == ProfilsState.failedToLoadDB) {
            return MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(body: Text(Strings.failedLoadingDatabase)),
            );
          } else {
            return child;
          }
        },
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => SystemProvider(),
            ),
            ChangeNotifierProxyProvider<ProfilProvider, AppearanceProvider>(
              create: (context) => AppearanceProvider(context),
              update: (_, profilProvider, appearanceProvider) {
                return appearanceProvider.update(profilProvider.currentProfil);
              },
            ),
            ChangeNotifierProxyProvider2<ProfilProvider, SystemProvider,
                LightProvider>(
              create: (context) => LightProvider(context),
              update: (_, profilProvider, bootProvider, lightProvider) {
                return lightProvider.update(
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
              create: (context) => NotificationsProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => CoolingProvider(),
            ),
            Provider(
              create: (context) => AudioProvider(),
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
      body: Selector<SystemProvider, bool>(
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
