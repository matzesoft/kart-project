import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/providers/audio_provider.dart';
import 'package:kart_project/providers/temperature_provider.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/preferences_provider.dart';
import 'package:kart_project/providers/user_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/lockscreen.dart';
import 'package:kart_project/widgets/main/main.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/extensions.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(AppInit());
}

class AppInit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferencesProvider>(
      create: (context) => PreferencesProvider(),
      child: Consumer<PreferencesProvider>(
        builder: (context, preferences, _) {
          if (!preferences.init) return Container(color: Colors.black);

          return ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider(
              context.read<PreferencesProvider>(),
            ),
            child: Selector<UserProvider, UsersState>(
              selector: (context, userProvider) => userProvider.state,
              builder: (context, state, child) {
                if (state == UsersState.notInitalized) {
                  return Container(color: Colors.black);
                } else if (state == UsersState.failedToLoadDB) {
                  return MaterialApp(
                    theme: AppTheme.lightTheme,
                    home: Scaffold(body: Text(Strings.failedLoadingDatabase)),
                  );
                } else {
                  return child!;
                }
              },
              child: ProviderInit(),
            ),
          );
        },
      ),
    );
  }
}

class ProviderInit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AudioProvider>(
          create: (context) => AudioProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (context) => NotificationsProvider(),
          lazy: false,
        ),
         ChangeNotifierProvider<TemperatureProvider>(
          create: (context) => TemperatureProvider(
            context.read<NotificationsProvider>(),
            context.read<MotorControllerProvider>(),
            context.read<SystemProvider>(),
          ),
          lazy: false,
        ),
        ChangeNotifierProvider<SystemProvider>(
          create: (context) => SystemProvider(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<UserProvider, AppearanceProvider>(
          create: (context) => AppearanceProvider(context.user()),
          update: (_, userProvider, appearanceProvider) {
            return appearanceProvider!.update(userProvider.currentUser);
          },
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<UserProvider, SystemProvider,
            LightProvider>(
          create: (context) => LightProvider(
            context.user(),
            context.locked(),
          ),
          update: (_, userProvider, bootProvider, lightProvider) {
            return lightProvider!.update(
              userProvider.currentUser,
              bootProvider.locked,
            );
          },
          lazy: false,
        ),
        ChangeNotifierProxyProvider<UserProvider, MapProvider>(
          create: (context) => MapProvider(context.user()),
          update: (_, userProvider, mapProvider) {
            return mapProvider!.update(userProvider.currentUser);
          },
          lazy: false,
        ),
        ChangeNotifierProxyProvider2<UserProvider, NotificationsProvider,
            MotorControllerProvider>(
          create: (context) {
            return MotorControllerProvider(
              context.user(),
              context.read<NotificationsProvider>(),
              context.read<PreferencesProvider>(),
            );
          },
          update: (_, userProvider, notificationProvider, kellyConroller) {
            return kellyConroller!.update(userProvider.currentUser);
          },
          lazy: false,
        ),
        ProxyProvider<MotorControllerProvider, BackDriveLightController>(
          create: (context) {
            return BackDriveLightController(
              context.read<MotorControllerProvider>().motorStateCommand,
            );
          },
          update: (_, kellyController, backDriveLightController) {
            return backDriveLightController!.update(
              kellyController.motorStateCommand,
            );
          },
          lazy: false,
        ),
      ],
      child: Core(),
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
          return child!;
        },
        child: Main(),
      ),
    );
  }
}
