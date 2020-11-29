import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/models/profil.dart';
import 'package:kart_project/providers/map_provider.dart';
import 'package:kart_project/providers/controller_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/profil_provider/profil_provider.dart';
import 'package:kart_project/widgets/dashboard/dashboard.dart';
import 'package:kart_project/widgets/entertainment.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/extensions.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(KartProject());
}

class KartProject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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

class Root extends StatelessWidget {
  static String route = "/";

  @override
  Widget build(BuildContext context) {
    // TODO: Improve loading screen...
    return Selector<ProfilProvider, bool>(
      selector: (context, profilProvider) => profilProvider.initalized,
      builder: (context, initalized, child) {
        if (!initalized) return Text("Init...");
        return child;
      },
      child: Selector<ProfilProvider, Profil>(
        selector: (context, profilProvider) => profilProvider.currentProfil,
        builder: (context, profil, child) {
          context.read<MapProvider>().updateLocationsWithProfil(profil);
          return child;
        },
        child: Scaffold(
          body: Row(
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

/*
class GpioTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GpioTestState();
  }
}

class _GpioTestState extends State<GpioTest> {
  FlutterGpiod gpio;
  GpioChip chip;
  List<GpioLine> lines;
  double pwmRatio = 0.5;
  int frequence = 10;

  void initState() {
    setup();
    super.initState();
  }

  Future setup() async {
    gpio = await FlutterGpiod.getInstance();
    chip = gpio.chips.singleWhere((chip) => chip.label == 'pinctrl-bcm2835');
    lines = chip.lines;
    await lines[23].requestOutput(initialValue: true);
    startHeartbeat();
  }

  Future startHeartbeat() async {
    while (true) {
      if (pwmRatio != 0.0) {
        lines[23].setValue(true);
        await Future.delayed(
          Duration(milliseconds: (pwmRatio * frequence).round()),
        );
      }
      if (pwmRatio != 1.0) {
        lines[23].setValue(false);
        await Future.delayed(
          Duration(milliseconds: ((1 - pwmRatio) * frequence).round()),
        );
      }
    }
  }

  void onPwmRatioChanged(double value) {
    setState(() {
      pwmRatio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Slider(
            value: pwmRatio,
            onChanged: onPwmRatioChanged,
          ),
        ],
      ),
    );
  }
}
*/
