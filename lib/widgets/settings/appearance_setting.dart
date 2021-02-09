import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/card_with_title.dart';
import 'package:kart_project/design/custom_list_tile.dart';
import 'package:kart_project/providers/appearance_provider.dart';
import 'package:kart_project/providers/light_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

class AppearanceSetting extends StatefulWidget {
  @override
  _AppearanceSettingState createState() => _AppearanceSettingState();
}

class _AppearanceSettingState extends State<AppearanceSetting> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LightCard(),
        ThemeModeCard(),
      ],
    );
  }
}

class LightCard extends StatelessWidget {
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
              child: MaxBrightnessSlider(),
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

/// Lets you control the maximum light brightness of the front light.
class MaxBrightnessSlider extends StatefulWidget {
  @override
  _MaxBrightnessSliderState createState() => _MaxBrightnessSliderState();
}

class _MaxBrightnessSliderState extends State<MaxBrightnessSlider> {
  LightProvider light;

  /// Holds the current value of the slider.
  double sliderValue;

  /// Holds the state of the light before moving the [Slider]. When finishing
  /// moving him, the light state will be reset to this value.
  LightState state;

  /// Sets the [sliderValue] to the current maximumm light brightness.
  @override
  void initState() {
    sliderValue = context.read<LightProvider>().maxLightBrightness;
    super.initState();
  }

  /// Sets [state] to the current light state.
  void onChangeStart() {
    state = light.lightState;
  }

  /// Updates the [sliderValue] and sets the light brightness to the indicated
  /// level. Does not update any values in the database.
  void onChanged(double value) {
    setState(() {
      sliderValue = value;
    });
    light.setLightBrightness(value);
  }

  /// Updates the value in the databse to value of the slider and resets the
  /// light state.
  void onChangeEnd(BuildContext context, double value) {
    light.setMaxLightBrightness(value, context: context);
    light.setLightState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, _) {
        this.light = lightProvider;

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
      },
    );
  }
}

/// Lets you switch the appeareance of the system.
class ThemeModeCard extends StatefulWidget {
  @override
  _ThemeModeCardState createState() => _ThemeModeCardState();
}

class _ThemeModeCardState extends State<ThemeModeCard> {
  AppearanceProvider appearance;
  ThemeMode themeMode;

  /// Returns true if [_themeMode] is set to light and false if dark.
  bool get lightMode => themeMode == ThemeMode.light ? true : false;

  /// The icon used in the ListTile based on the [themeMode].
  IconData get themeIcon => lightMode ? EvaIcons.sun : EvaIcons.moonOutline;

  /// The title used in the ListTile based on the [themeMode].
  String get themeTitle => lightMode ? Strings.lightMode : Strings.darkMode;

  /// Switches the theme mode based on value of the switch.
  void onThemeModeSwitched(BuildContext context, {bool lightMode}) {
    ThemeMode mode;
    if (lightMode == null) {
      mode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      mode = lightMode ? ThemeMode.light : ThemeMode.dark;
    }
    appearance.setThemeMode(mode, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceProvider>(
      builder: (context, appearanceProvider, _) {
        this.appearance = appearanceProvider;
        this.themeMode = appearance.themeMode;

        return CardWithTitle(
          title: Strings.appearance,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: CustomListTile(
              icon: Icon(themeIcon),
              title: themeTitle,
              subtitle: Strings.changeAppTheme,
              trailing: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSwitch(
                  value: lightMode,
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
      },
    );
  }
}
