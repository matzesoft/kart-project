import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/profil_setting.dart';
import 'package:provider/provider.dart';

List<Setting> get settings {
  return [
    Setting(
      name: Strings.profiles,
      content: ProfilSetting(),
    ),
    Setting(
      name: Strings.drive,
      icon: EvaIcons.navigationOutline,
      activeIcon: EvaIcons.navigation,
      content: DriveSetting(),
    ),
    Setting(
      name: Strings.lightAndDisplay,
      icon: EvaIcons.bulbOutline,
      activeIcon: EvaIcons.bulb,
      content: LightAndDisplaySetting(),
    ),
    Setting(
      name: Strings.about,
      icon: EvaIcons.infoOutline,
      activeIcon: EvaIcons.info,
      content: AboutSetting(),
    ),
  ];
}

class Setting {
  /// Indicates the title of the setting.
  final String name;

  /// Icon when not selected.
  final IconData icon;

  /// Icon when selected.
  final IconData activeIcon;

  /// Widget with the controls.
  final Widget content;

  Setting({this.name, this.icon, this.activeIcon, this.content});
}

/// Menu which lets you switch between Profiles, change settings
/// or get information about the system. Consists of a [Drawer]
/// on the left side and of the content on the right side.
class Settings extends StatefulWidget {
  static String route = "/profil_menu";

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  /// The currently selected setting. `settings.elementAt(_currentIndex)`
  /// gives more information.
  int _currentIndex = 1;

  /// Gets called when the user taps on a setting.
  void _onSettingChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Drawer(
              currentIndex: _currentIndex,
              onTap: _onSettingChanged,
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: settings[_currentIndex].content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List of settings.
class Drawer extends StatelessWidget {
  final int currentIndex;

  /// Called when the user taps on one setting while the [index] discribes
  /// which setting.
  final Function(int index) onTap;

  Drawer({this.currentIndex: 0, @required this.onTap});

  /// Color used by the title of the setting.
  Color _textColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1.color;

  /// Color used by the icon and the letter in the profil picture.
  Color _iconColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1.color;

  /// Color used by the subtile and background of the profile picture.
  Color _profilPictureColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor.withOpacity(0.4)
      : Theme.of(context).canvasColor;

  /// Background color when the setting is selcted.
  Color _backgroundColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor.withOpacity(0.2)
      : Colors.transparent;

  Widget _item(BuildContext context, int itemIndex) {
    bool active = (itemIndex == currentIndex);
    return Padding(
      padding: EdgeInsets.all(6.0),
      child: Material(
        color: _backgroundColor(context, active),
        borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
          onTap: () {
            onTap(itemIndex);
          },
          child: ListTile(
            leading: Icon(
              settings[itemIndex].icon,
              color: _iconColor(context, active),
            ),
            title: Text(
              settings[itemIndex].name,
              style: TextStyle(color: _textColor(context, active)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profilItem(BuildContext context, int itemIndex) {
    bool active = (itemIndex == currentIndex);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Material(
            color: _backgroundColor(context, active),
            borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
              onTap: () {
                onTap(itemIndex);
              },
              child: Selector<ProfilProvider, String>(
                selector: (context, profilProvider) {
                  return profilProvider.currentProfil.name;
                },
                builder: (context, profilName, child) {
                  String profilLetter = profilName[0];
                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _profilPictureColor(context, active),
                      ),
                      margin: EdgeInsets.all(4.0),
                      padding: EdgeInsets.all(2.0),
                      child: Text(
                        profilLetter,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: _iconColor(context, active),
                            ),
                      ),
                    ),
                    title: Text(
                      profilName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _textColor(context, active)),
                    ),
                    subtitle: Text(Strings.profil),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 16.0),
          child: Container(
            height: 3.0,
            width: double.infinity,
            decoration: ShapeDecoration(
              color: Theme.of(context).canvasColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.customBorderRadius),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Material(
        color: Theme.of(context).backgroundColor,
        elevation: AppTheme.customElevation,
        shadowColor: AppTheme.customShadowColor(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: IconButton(
                    icon: Icon(EvaIcons.closeOutline),
                    iconSize: AppTheme.iconButtonSize,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Column(
                  children: List.generate(
                    settings.length,
                    (itemIndex) {
                      if (itemIndex == 0)
                        return _profilItem(context, itemIndex);
                      return _item(context, itemIndex);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriveSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Remove after testing
    return Text("Drive Setting");
  }
}

class LightAndDisplaySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Light And Display Setting");
  }
}

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("About Setting");
  }
}
