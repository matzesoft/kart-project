import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/user_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/info_setting.dart';
import 'package:kart_project/widgets/settings/appearance_setting.dart';
import 'package:kart_project/widgets/settings/audio_setting.dart';
import 'package:kart_project/widgets/settings/dev_setting.dart';
import 'package:kart_project/widgets/settings/drive_setting.dart';
import 'package:kart_project/widgets/settings/safety_setting.dart';
import 'package:kart_project/widgets/settings/user_picture.dart';
import 'package:kart_project/widgets/settings/user_setting.dart';
import 'package:provider/provider.dart';

class Setting {
  final String title;
  final IconData? icon;
  final Widget content;

  Setting({required this.title, this.icon, required this.content});
}

List<Setting> settings = [
  Setting(
    title: Strings.users,
    content: UserSetting(),
  ),
  Setting(
    title: Strings.motorAndBattery,
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
    title: Strings.safety,
    icon: EvaIcons.shieldOutline,
    content: SafetySetting(),
  ),
  Setting(
    title: Strings.about,
    icon: EvaIcons.infoOutline,
    content: InfoSetting(),
  ),
  // The last setting is hidden when dev options are disabled.
  Setting(
    title: Strings.developer,
    icon: EvaIcons.codeOutline,
    content: DevSetting(),
  ),
];

/// Menu which lets you switch between Profiles, change settings
/// or get information about the system. Consists of a [Drawer]
/// on the left side and of the content on the right side.
class Settings extends StatefulWidget {
  static String route = "/profil_menu";

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _currentIndex = 1;
  bool _checkedArguments = false;

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
    if (_checkedArguments != true) {
      final dynamic arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) _currentIndex = arguments;
      _checkedArguments = true;
    }

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

  Drawer({this.currentIndex: 0, required this.onTap});

  /// Color used by the title and the icon of the setting.
  Color? _textColor(BuildContext context, bool active) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1!.color;

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
          onTap: currentIndex != itemIndex ? () => onTap(itemIndex) : null,
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
  /// [UserPicture] instead of a icon.
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
              onTap: currentIndex != itemIndex ? () => onTap(itemIndex) : null,
              child: Selector<UserProvider, String>(
                selector: (context, profilProvider) {
                  return profilProvider.currentUser.name;
                },
                builder: (context, profilName, child) {
                  return ListTile(
                    leading: UserPicture(
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
                    subtitle: Text(Strings.user),
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
                Selector<SystemProvider, bool>(
                  selector: (context, p) => p.devOptionsEnabled,
                  builder: (context, devOptionsEnabled, _) {
                    // Hides the developer settings from options when not enabled.
                    final length = devOptionsEnabled
                        ? settings.length
                        : settings.length - 1;

                    return Column(
                      children: List.generate(
                        length,
                        (itemIndex) {
                          if (itemIndex == 0)
                            return _profilItem(context, itemIndex);
                          return _item(context, itemIndex);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
