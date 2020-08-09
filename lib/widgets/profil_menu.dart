import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/custom_card.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';

List<Setting> get settings {
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
class ProfilMenu extends StatefulWidget {
  static String route = "/profil_menu";

  @override
  _ProfilMenuState createState() => _ProfilMenuState();
}

class _ProfilMenuState extends State<ProfilMenu> {
  /// The currently selected setting. `settings.elementAt(_currentIndex)`
  /// gives more information.
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
            flex: 3,
            child: SingleChildScrollView(
              child: CustomCard(
                margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: settings.elementAt(_currentIndex).content,
                ),
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
  /// Is the setting in which you are currently in.
  final int currentIndex;

  /// Called when the user taps on one setting while the [index] discribes
  /// which setting.
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
              settings.elementAt(itemIndex).name,
            ),
            leading: Icon(
              settings.elementAt(itemIndex).icon,
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
                settings.elementAt(itemIndex).name,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).accentColor,
                    ),
              ),
              leading: Icon(
                settings.elementAt(itemIndex).activeIcon,
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
                    settings.length,
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

/// Lets you create, switch, edit and delete profiles.
class ProfilSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                EvaIcons.personOutline,
                size: 40,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Duvi (Skrepi)",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  "Aktuelles Profil",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class DriveSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // TODO: Remove after testing
    return Consumer<ProfilProvider>(
      builder: (context, profilProvider, child) {
        return Column(
          children: [
            Column(
              children: List.generate(
                profilProvider.profiles.length,
                (index) => Column(
                  children: [
                    Text(
                      "id: " +
                          profilProvider.profiles
                              .elementAt(index)
                              .id
                              .toString(),
                    ),
                    Text(
                      "name: " + profilProvider.profiles.elementAt(index).name,
                    ),
                    Text(
                      "themeMode: " +
                          profilProvider.profiles
                              .elementAt(index)
                              .themeMode
                              .toString(),
                    ),
                    Text(
                      "maxSpeed: " +
                          profilProvider.profiles
                              .elementAt(index)
                              .maxSpeed
                              .toString(),
                    ),
                    Text(
                      "light: " +
                          profilProvider.profiles
                              .elementAt(index)
                              .lightBrightness
                              .toString(),
                    ),
                  ],
                ),
              ),
            ),
            Text("Current profil: " + profilProvider.currentProfil.toString()),
            MaterialButton(
              onPressed: () {
                profilProvider.createProfil(context, name: "Test Profil");
              },
              child: Text("Create Profil"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setProfil(context, 4);
              },
              child: Text("Set Profil to 4"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setName(4, "Duvi");
              },
              child: Text("Set Name to Duvi"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setThemeMode(4, 2);
              },
              child: Text("Set themeMode to Dark"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setThemeMode(4, 2);
              },
              child: Text("Set themeMode to Dark"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setMaxSpeed(4, 30);
              },
              child: Text("Set maxSpeed to 30"),
            ),
            MaterialButton(
              onPressed: () {
                profilProvider.setLightBrightness(4, 0.6);
              },
              child: Text("Set lightBrightness to 0.6"),
            ),
          ],
        );
      },
    );

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
