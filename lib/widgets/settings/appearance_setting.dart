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
        LightStrip(),
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
  LightProvider controller;

  /// Holds the current value of the slider.
  double sliderValue;

  /// Holds the state of the light before moving the [Slider]. When finishing
  /// moving him, the light state will be reset to this value.
  LightState state;

  /// Sets the [sliderValue] to the current maximumm light brightness.
  @override
  void initState() {
    sliderValue = context.read<LightProvider>().frontLight.maxBrightness;
    super.initState();
  }

  /// Sets [state] to the current light state.
  void onChangeStart() {
    state = controller.lightState;
  }

  /// Updates the [sliderValue] and sets the light brightness to the indicated
  /// level. Does not update any values in the database.
  void onChanged(double value) {
    setState(() {
      sliderValue = value;
    });
    controller.frontLight.animateLight(value);
  }

  /// Updates the value in the databse to value of the slider. Waits a short time
  /// to show the user his current settings and resets to the [state] after it.
  void onChangeEnd(BuildContext context, double value) {
    controller.frontLight.maxBrightness = value;
    Future.delayed(Duration(seconds: 2), () {
      controller.setLightState(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, _) {
        this.controller = lightProvider;

        return Slider(
          value: sliderValue,
          min: FRONT_DIMMED_BRIGHTNESS,
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
    appearance.themeMode = mode;
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

class LightStrip extends StatefulWidget {
  @override
  _LightStripState createState() => _LightStripState();
}

class _LightStripState extends State<LightStrip> {
  final _colors = LIGHT_STRIP_COLORS;
  LightStripController _controller;

  void onTap(Color color) {
    _controller.color = color;
  }

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: "Bodenbeleuchtung",
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<LightProvider>(
              builder: (context, lightProvider, child) {
                this._controller = lightProvider.lightStrip;
                final selectedColor = _controller.color;

                return GridView(
                  primary: false,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  children: List.generate(_colors.length, (int index) {
                    final color = _colors[index];
                    final selected = color == selectedColor;
                    return LightStripColor(color, selected, onTap);
                  }),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Wähle die Farbe der Bodenbeleuchtung."),
            ),
          ],
        ),
      ),
    );
  }
}

class LightStripColor extends StatelessWidget {
  final bool selected;
  final Color color;
  final Function(Color color) onTap;

  LightStripColor(this.color, this.selected, this.onTap);

  Color get iconColor =>
      color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      width: 55,
      height: 55,
      child: Material(
        borderRadius: BorderRadius.circular(90.0),
        color: color,
        elevation: 6.0,
        shadowColor: color.withOpacity(0.2),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: selected
              ? Icon(
                  EvaIcons.checkmarkOutline,
                  color: iconColor,
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(90.0),
                  onTap: () {
                    onTap(color);
                  },
                ),
        ),
      ),
    );
  }
}
