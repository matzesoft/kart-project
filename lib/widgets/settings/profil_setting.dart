import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/profil_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/profil_picture.dart';
import 'package:provider/provider.dart';

/// Lets you create, switch, edit and delete profiles. Consists of a header
/// which shows the [_CurrentProfil] and a [GridView] with a list of all profiles.
class ProfilSetting extends StatefulWidget {
  @override
  _ProfilSettingState createState() => _ProfilSettingState();
}

class _ProfilSettingState extends State<ProfilSetting> {
  ProfilProvider? profilProvider;
  List<Profil> profiles = [];
  Profil? currentProfil;

  /// Opens up the [CreateProfilDialog].
  Future _createProfil() async {
    showDialog(
      context: context,
      builder: (context) => _CreateProfilDialog(profilProvider!),
    );
  }

  /// Switches the profil. Shows an [LoadingInterface] as long as processing.
  Future _setProfil(Profil profil) async {
    LoadingInterface.dialog(context, message: Strings.profilIsSwitched);
    await profilProvider!.switchProfil(context, profil.id);
    Navigator.pop(context);
  }

  /// Opens the [EditProfilDialog].
  Future _editProfil(Profil profil) async {
    showDialog(
      context: context,
      builder: (context) => _EditProfilDialog(currentProfil!),
    );
  }

  /// Opens the [DeleteProfilDialog].
  Future _deleteProfil(Profil profil) async {
    showDialog(
      context: context,
      builder: (context) => _DeleteProfilDialog(profilProvider!),
    );
  }

  @override
  Widget build(BuildContext context) {
    profilProvider = context.watch<ProfilProvider>();
    profiles = profilProvider!.profiles;
    currentProfil = profilProvider!.currentProfil;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CurrentProfil(
            currentProfil!,
            enableDeletion: profiles.length > 1,
            editProfil: _editProfil,
            deleteProfil: _deleteProfil,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: GridView.builder(
              primary: false,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250.0,
                childAspectRatio: 3 / 2,
              ),
              itemBuilder: (context, index) {
                if (index == profiles.length)
                  return _CreateProfilItem(_createProfil);
                return _ProfilItem(
                  profiles[index],
                  active: profiles[index].id == currentProfil!.id,
                  setProfil: _setProfil,
                );
              },
              itemCount: profiles.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows which profil is currently choosen and lets you delete and edit it.
/// Set [enableDeletion] to false to disable the delete button.
class _CurrentProfil extends StatelessWidget {
  final Profil profil;
  final bool enableDeletion;
  final Function(Profil profil) editProfil;
  final Function(Profil profil) deleteProfil;

  _CurrentProfil(
    this.profil, {
    this.enableDeletion: true,
    required this.editProfil,
    required this.deleteProfil,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProfilPicture(name: profil.name),
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
                    onPressed: enableDeletion
                        ? () {
                            deleteProfil(profil);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Represents one profil in the grid.  If [active] is true the profil will be
/// highlighted and the [setProfil] function disabled to prevent user from
/// resetting the current profil.
class _ProfilItem extends StatelessWidget {
  final Profil profil;
  final bool active;
  final Function(Profil profil) setProfil;

  _ProfilItem(this.profil, {this.active: false, required this.setProfil});

  /// Color used by the title and the icon of the setting.
  Color? _textColor(BuildContext context) => active
      ? Theme.of(context).accentColor
      : Theme.of(context).textTheme.subtitle1!.color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        onTap: active
            ? null
            : () {
                setProfil(profil);
              },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfilPicture(
                active: active,
                name: profil.name,
                size: 42,
              ),
              Text(
                profil.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: _textColor(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Always the last item in the [GridView]. Calls [createProfil] when tapped on.
class _CreateProfilItem extends StatelessWidget {
  final Function() createProfil;

  _CreateProfilItem(this.createProfil);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
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

/// Interface for creating a new profil. If no name for the new profil is given
/// an automatic generated name will be used.
class _CreateProfilDialog extends StatefulWidget {
  final ProfilProvider profilProvider;

  _CreateProfilDialog(this.profilProvider);

  @override
  State<StatefulWidget> createState() => _CreateProfilDialogState();
}

class _CreateProfilDialogState extends State<_CreateProfilDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  /// Set to true when work is in progress. Normaly used to check wether to show
  /// a [LoadingInterface] or not.
  bool _processing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Creates a new profil. Sets [_processing] to true while processing.
  Future _createProfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _processing = true;
      });
      await widget.profilProvider.createProfil(
        context,
        name: _controller.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.profilIsCreated,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      title: Text(Strings.createProfil),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: Strings.typeInTheName,
              ),
              autocorrect: false,
              controller: _controller,
              validator: (value) {
                if (value == null) value = "";
                return value.length > 30 ? Strings.maxLengthOfName : null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              Strings.leaveEmptyToUseDefaultName,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        FlatButton(
          onPressed: () {
            _createProfil();
          },
          child: Text(Strings.create),
        ),
      ],
    );
  }
}

/// Interface to edit the profil.
class _EditProfilDialog extends StatefulWidget {
  final Profil profil;

  _EditProfilDialog(this.profil);

  @override
  State<StatefulWidget> createState() => _EditProfilDialogState();
}

class _EditProfilDialogState extends State<_EditProfilDialog> {
  final _formKey = GlobalKey<FormState>();
  Profil? _profil;
  TextEditingController? _controller;

  @override
  void initState() {
    _profil = widget.profil;
    _controller = TextEditingController(text: _profil!.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  /// Updates the [_profil].
  void _updateProfil() {
    if (_formKey.currentState!.validate()) {
      _profil!.setName(
        context,
        _controller!.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedAlertDialog(
      title: Text(Strings.editProfil),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: Strings.typeInTheName,
            ),
            autocorrect: false,
            controller: _controller,
            validator: (value) {
              if (value == null) value = "";
              if (value.isEmpty) return Strings.giveName;
              if (value.length > 30) return Strings.maxLengthOfName;
              return null;
            },
          ),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        FlatButton(
          onPressed: () {
            _updateProfil();
          },
          child: Text(Strings.safe),
        ),
      ],
    );
  }
}

/// Interface for deleting a profil.
class _DeleteProfilDialog extends StatefulWidget {
  final ProfilProvider profilProvider;

  _DeleteProfilDialog(this.profilProvider);

  @override
  _DeleteProfilDialogState createState() => _DeleteProfilDialogState();
}

class _DeleteProfilDialogState extends State<_DeleteProfilDialog> {
  Profil? _profil;

  /// Set to true when work is in progress. Normaly used to check wether to show
  /// a [LoadingInterface] or not.
  bool _processing = false;

  @override
  void initState() {
    _profil = widget.profilProvider.currentProfil;
    super.initState();
  }

  /// Deletes the [_profil]. Sets [_processing] to true while processing.
  Future _deleteProfil() async {
    setState(() {
      _processing = true;
    });
    await widget.profilProvider.deleteProfil(context, _profil!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.profilIsDeleted,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      title: Text(Strings.deleteProfilQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.deleteProfilMessage1 +
                _profil!.name +
                Strings.deleteProfilMessage2,
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        FlatButton(
          onPressed: () {
            _deleteProfil();
          },
          child: Text(Strings.delete),
        ),
      ],
    );
  }
}
