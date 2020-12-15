import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class AppearanceSetting extends StatefulWidget {
  @override
  _AppearanceSettingState createState() => _AppearanceSettingState();
}

class _AppearanceSettingState extends State<AppearanceSetting> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceProvider>(
      builder: (context, appearance, child) {
        return Column(
          children: [
            LightCard(appearance),
            ThemeModeCard(appearance),
          ],
        );
      },
    );
  }
}

class LightCard extends StatelessWidget {
  final AppearanceProvider appearance;

  LightCard(this.appearance);

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.light,
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MaxBrightnessSlider(appearance),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(Strings.setMaxLightBrightness),
            )
          ],
        ),
      ),
    );
  }
}

class MaxBrightnessSlider extends StatefulWidget {
  final AppearanceProvider appearance;

  MaxBrightnessSlider(this.appearance);

  @override
  _MaxBrightnessSliderState createState() => _MaxBrightnessSliderState();
}

class _MaxBrightnessSliderState extends State<MaxBrightnessSlider> {
  double sliderValue;
  LightState state;

  @override
  void initState() {
    sliderValue = widget.appearance.maxLightBrightness;
    super.initState();
  }

  void onChangeStart() {
    state = widget.appearance.lightState;
  }

  void onChanged(double value) {
    setState(() {
      sliderValue = value;
    });
    widget.appearance.setLight(value);
  }

  void onChangeEnd(BuildContext context, double value) {
    widget.appearance.setMaxLightBrightness(value, context: context);
    widget.appearance.setLightState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: sliderValue,
      min: dimmedLightBrightness,
      max: 1.0,
      onChangeStart: (_) {
        onChangeStart();
      },
      onChanged: onChanged,
      onChangeEnd: (double value) {
        onChangeEnd(context, value);
      },
    );
  }
}

class ThemeModeCard extends StatelessWidget {
  final AppearanceProvider appearance;
  final ThemeMode _themeMode;

  /// Returns true if [_themeMode] is set to light and false if dark.
  bool get _lightMode => _themeMode == ThemeMode.light ? true : false;
  IconData get _themeIcon => _lightMode ? EvaIcons.sun : EvaIcons.moonOutline;
  String get _themeTitle => _lightMode ? Strings.lightMode : Strings.darkMode;

  ThemeModeCard(this.appearance) : _themeMode = appearance.themeMode;

  /// Switches the theme mode based on value of the switch.
  void onThemeModeSwitched(BuildContext context, {bool lightMode}) {
    ThemeMode mode;
    if (lightMode == null) {
      mode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      mode = lightMode ? ThemeMode.light : ThemeMode.dark;
    }
    appearance.setThemeMode(mode, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: Strings.appearance,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: CustomListTile(
          icon: Icon(_themeIcon),
          title: _themeTitle,
          subtitle: Strings.changeAppTheme,
          trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSwitch(
              value: _lightMode,
              onChanged: (value) {
                onThemeModeSwitched(context, lightMode: value);
              },
            ),
          ),
          onPressed: () {
            onThemeModeSwitched(context);
          },
        ),
      ),
    );
  }
}
