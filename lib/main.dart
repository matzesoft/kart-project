import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/boot_provider.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/controller_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:kart_project/widgets/dashboard/dashboard.dart';
import 'package:kart_project/widgets/entertainment.dart';
import 'package:kart_project/widgets/lockscreen.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/extensions.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(KartProject());
}

/// Implements all necessary providers for the project.
class KartProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BootProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfilProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ControllerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MapProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationsProvider(),
        ),
      ],
      child: Core(),
    );
  }
}

/// Implements the core widget [MaterialApp]. Sets up different values like the
/// [themeMode] and [routes]. Also takes the core widget of the [OverlaySupport].
class Core extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Kart Project',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
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

  /// Updates all providers which depend on profil data.
  void _updateProviders(BuildContext context, Profil profil) {
    context.read<MapProvider>().updateLocationsWithProfil(profil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Consumer<ProfilProvider>(
        builder: (context, profilProvider, child) {
          if (!profilProvider.initalized)
            return Text("Init..."); // TODO: Improve
          _updateProviders(context, profilProvider.currentProfil);
          return child;
        },
        child: Selector<BootProvider, bool>(
          selector: (context, bootProvider) => bootProvider.locked,
          builder: (context, locked, child) {
            if (locked) return Lockscreen();
            return child;
          },
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Dashboard(),
              ),
              Expanded(
                flex: 7,
                child: Entertainment(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
