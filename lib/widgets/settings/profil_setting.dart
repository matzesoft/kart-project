import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/custom_card.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:provider/provider.dart';


/// Lets you create, switch, edit and delete profiles.
class ProfilSetting extends StatefulWidget {
  @override
  _ProfilSettingState createState() => _ProfilSettingState();
}

class _ProfilSettingState extends State<ProfilSetting> {
  ProfilProvider _profilProvider;

  /// List of profiles without the current profil.
  List<Profil> _profiles;

  /// Profil which is currently used.
  Profil _currentProfil;

  Future _createProfil() async {
    // TODO: Create Dialog to change name when creating
    _profilProvider.createProfil(context, name: "Test Profil");
  }

  Future _setProfil(Profil profil) async {
    LoadingInterface.dialog(context, message: Strings.profilIsChanged);
    await _profilProvider.setProfil(context, profil.id);
    await Future.delayed(Duration(seconds: 5)); // TODO: Remove after testing
    Navigator.pop(context);
  }

  Future _editProfil(Profil profil) async {}

  Future _deleteProfil(Profil profil) async {}

  @override
  Widget build(BuildContext context) {
    _profilProvider = Provider.of<ProfilProvider>(context);
    _profiles = _profilProvider.profilesWithoutCurrentProfil;
    _currentProfil = _profilProvider.currentProfil;

    return Column(
      children: [
        CurrentProfil(
          _currentProfil,
          editProfil: _editProfil,
        ),
        CustomCard(
          child: GridView.builder(
            primary: false,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0,
              childAspectRatio: 3 / 2,
            ),
            itemBuilder: (context, index) {
              if (index == _profiles.length) return CreateProfil(_createProfil);
              return ProfilItem(
                _profiles[index],
                setProfil: _setProfil,
              );
            },
            itemCount: _profiles.length + 1,
          ),
        ),
      ],
    );
  }
}

/// Shows which profil is currently choosen and lets you delete and edit it.
class CurrentProfil extends StatelessWidget {
  final Profil profil;
  final Function(Profil profil) editProfil;
  final Function(Profil profil) deleteProfil;

  CurrentProfil(
    this.profil, {
    this.editProfil,
    this.deleteProfil,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).canvasColor,
                ),
                margin: EdgeInsets.all(12.0),
                padding: EdgeInsets.all(6.0),
                child: Text(
                  profil.name[0],
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 26,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.name,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      Strings.currentProfil,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  iconSize: AppTheme.iconButtonSize,
                  icon: Icon(EvaIcons.editOutline),
                  onPressed: () {
                    editProfil(profil);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  iconSize: AppTheme.iconButtonSize,
                  icon: Icon(EvaIcons.trash2Outline),
                  onPressed: () {
                    deleteProfil(profil);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Represents one Profil in the grid.
class ProfilItem extends StatelessWidget {
  final Profil profil;
  final Function(Profil profil) setProfil;

  ProfilItem(this.profil, {this.setProfil});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
        onTap: () {
          setProfil(profil);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).canvasColor,
                ),
                margin: EdgeInsets.all(12.0),
                padding: EdgeInsets.all(6.0),
                child: Text(
                  profil.name[0],
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Text(
                profil.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateProfil extends StatelessWidget {
  final Function createProfil;

  CreateProfil(this.createProfil);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.customBorderRadius),
        onTap: createProfil,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(EvaIcons.plus),
              Text(
                Strings.createProfil,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
