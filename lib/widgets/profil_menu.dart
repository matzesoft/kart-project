import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/strings.dart';

List<Setting> settings(BuildContext context) {
  return [
    Setting(
      name: Strings.profiles,
      icon: EvaIcons.personOutline,
      activeIcon: EvaIcons.person,
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
  final String name;
  final IconData icon;
  final IconData activeIcon;
  final Widget content;

  Setting({this.name, this.icon, this.activeIcon, this.content});
}

/// Menu which lets you switch between Profils, change settings
/// or get information about the system. Consists of a [Drawer]
/// on the left side and of the content on the right side.
class ProfilMenu extends StatefulWidget {
  static String route = "/profil_menu";

  @override
  _ProfilMenuState createState() => _ProfilMenuState();
}

class _ProfilMenuState extends State<ProfilMenu> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Drawer(
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: Text("Settings"),
          ),
        ],
      ),
    );
  }
}

/// List of settings. [currentIndex] is the setting in which you are
/// currently in. [onTap] is called when the user taps on one setting while
/// the index discribes which setting.
class Drawer extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;

  Drawer({this.currentIndex: 0, @required this.onTap});

  Widget _item(BuildContext context, int itemIndex) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 250),
      crossFadeState: itemIndex != currentIndex
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Padding(
        padding: EdgeInsets.all(6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: () {
            onTap(itemIndex);
          },
          child: ListTile(
            title: Text(
              settings(context).elementAt(itemIndex).name,
            ),
            leading: Icon(
              settings(context).elementAt(itemIndex).icon,
            ),
          ),
        ),
      ),
      secondChild: Padding(
        padding: EdgeInsets.all(6.0),
        child: Material(
          color: Theme.of(context).accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              onTap(itemIndex);
            },
            child: ListTile(
              title: Text(
                settings(context).elementAt(itemIndex).name,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              leading: Icon(
                settings(context).elementAt(itemIndex).activeIcon,
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
      ),
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
                    iconSize: 34,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Column(
                  children: List.generate(
                    settings(context).length,
                    (itemIndex) => _item(context, itemIndex),
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

class ProfilSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class DriveSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class LightAndDisplaySetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class AboutSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
