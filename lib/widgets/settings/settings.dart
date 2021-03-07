import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/about_setting.dart';
import 'package:kart_project/widgets/settings/appearance_setting.dart';
import 'package:kart_project/widgets/settings/audio_setting.dart';
import 'package:kart_project/widgets/settings/dev_settings.dart';
import 'package:kart_project/widgets/settings/drive_setting.dart';
import 'package:kart_project/widgets/settings/profil_picture.dart';
import 'package:kart_project/widgets/settings/profil_setting.dart';
import 'package:provider/provider.dart';

class Setting {
  final String title;
  final IconData icon;
  final Widget content;

  Setting({this.title, this.icon, this.content});
}

List<Setting> get settings {
  return [
    Setting(
      title: Strings.profiles,
      content: ProfilSetting(),
    ),
    Setting(
      title: Strings.drive,
      icon: EvaIcons.navigationOutline,
      content: DriveSetting(),
    ),
    Setting(
      title: Strings.lightAndDisplay,
      icon: EvaIcons.bulbOutline,
      content: AppearanceSetting(),
    ),
    Setting(
      title: Strings.audio,
      icon: EvaIcons.musicOutline,
      content: AudioSetting(),
    ),
    Setting(
      title: Strings.about,
      icon: EvaIcons.infoOutline,
      content: AboutSetting(),
    ),
    Setting(
      title: Strings.developer,
      icon: EvaIcons.codeOutline,
      content: DevSetting(), // TODO: Only show when in SystemProvider
    ),
  ];
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
  /// The currently selected setting.
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
                padding: EdgeInsets.all(8.0),
                child: settings[_currentIndex].content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Drawer extends StatelessWidget {
  /// The currently selected setting.
  final int currentIndex;

  /// Called when the user taps on one setting while the [index] discribes
  /// which setting.
  final Function(int index) onTap;

  Drawer({this.currentIndex: 0, @required this.onTap});

  /// Color used by the title and the icon of the setting.
  Color _textColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1.color;

  /// Background color when the setting is selcted.
  Color _backgroundColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor.withOpacity(0.2)
      : Colors.transparent;

  /// Indicates one setting in the list.
  Widget _item(BuildContext context, int itemIndex) {
    bool active = (itemIndex == currentIndex);
    return Padding(
      padding: EdgeInsets.all(6.0),
      child: Material(
        color: _backgroundColor(context, active),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          onTap: () {
            onTap(itemIndex);
          },
          child: ListTile(
            leading: Icon(
              settings[itemIndex].icon,
              color: _textColor(context, active),
            ),
            title: Text(
              settings[itemIndex].title,
              style: TextStyle(color: _textColor(context, active)),
            ),
          ),
        ),
      ),
    );
  }

  /// Shown on top of the list. Shows the current profil and contains of a
  /// [ProfilPicture] instead of a icon.
  Widget _profilItem(BuildContext context, int itemIndex) {
    bool active = (itemIndex == currentIndex);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(6.0),
          child: Material(
            color: _backgroundColor(context, active),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              onTap: () {
                onTap(itemIndex);
              },
              child: Selector<ProfilProvider, String>(
                selector: (context, profilProvider) {
                  return profilProvider.currentProfil.name;
                },
                builder: (context, profilName, child) {
                  return ListTile(
                    leading: ProfilPicture(
                      active: active,
                      name: profilName,
                      size: 38,
                      margin: EdgeInsets.all(0.0),
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
          child: Divider(),
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
        elevation: AppTheme.elevation,
        shadowColor: AppTheme.shadowColor(context),
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
