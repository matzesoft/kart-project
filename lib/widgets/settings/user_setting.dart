import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/design/loading_interface.dart';
import 'package:kart_project/design/sized_alert_dialog.dart';
import 'package:kart_project/design/theme.dart';
import 'package:kart_project/providers/user_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/user_picture.dart';
import 'package:provider/provider.dart';

/// Lets you create, switch, edit and delete users. Consists of a header
/// which shows the [_CurrentUser] and a [GridView] with a list of all users.
class UserSetting extends StatefulWidget {
  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  UserProvider? userProvider;
  List<User> users = [];
  User? currentUser;

  /// Opens up the [CreateUserDialog].
  Future _createUser() async {
    showDialog(
      context: context,
      builder: (context) => _CreateUserDialog(userProvider!),
    );
  }

  /// Switches the user. Shows an [LoadingInterface] as long as processing.
  Future _setUser(User user) async {
    LoadingInterface.dialog(context, message: Strings.userIsSwitched);
    await userProvider!.switchUser(context, user.id);
    Navigator.pop(context);
  }

  /// Opens the [EditUserDialog].
  Future _editUser(User user) async {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(currentUser!),
    );
  }

  /// Opens the [DeleteUserDialog].
  Future _deleteUser(User user) async {
    showDialog(
      context: context,
      builder: (context) => _DeleteUserDialog(userProvider!),
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = context.watch<UserProvider>();
    users = userProvider!.users;
    currentUser = userProvider!.currentUser;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CurrentUser(
            currentUser!,
            enableDeletion: users.length > 1,
            editUser: _editUser,
            deleteUser: _deleteUser,
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
                if (index == users.length)
                  return _CreateUserItem(_createUser);
                return _UserItem(
                  users[index],
                  active: users[index].id == currentUser!.id,
                  setUser: _setUser,
                );
              },
              itemCount: users.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows which user is currently choosen and lets you delete and edit it.
/// Set [enableDeletion] to false to disable the delete button.
class _CurrentUser extends StatelessWidget {
  final User user;
  final bool enableDeletion;
  final Function(User user) editUser;
  final Function(User user) deleteUser;

  _CurrentUser(
    this.user, {
    this.enableDeletion: true,
    required this.editUser,
    required this.deleteUser,
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
                UserPicture(name: user.name),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        Strings.currentUser,
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
                      editUser(user);
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
                            deleteUser(user);
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

/// Represents one user in the grid.  If [active] is true the user will be
/// highlighted and the [setUser] function disabled to prevent user from
/// resetting the current user.
class _UserItem extends StatelessWidget {
  final User user;
  final bool active;
  final Function(User user) setUser;

  _UserItem(this.user, {this.active: false, required this.setUser});

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
                setUser(user);
              },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserPicture(
                active: active,
                name: user.name,
                size: 42,
              ),
              Text(
                user.name,
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

/// Always the last item in the [GridView]. Calls [createUser] when tapped on.
class _CreateUserItem extends StatelessWidget {
  final Function() createUser;

  _CreateUserItem(this.createUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        onTap: createUser,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(EvaIcons.plus),
              Text(
                Strings.createUser,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interface for creating a new user. If no name for the new user is given
/// an automatic generated name will be used.
class _CreateUserDialog extends StatefulWidget {
  final UserProvider userProvider;

  _CreateUserDialog(this.userProvider);

  @override
  State<StatefulWidget> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
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

  /// Creates a new user. Sets [_processing] to true while processing.
  Future _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _processing = true;
      });
      await widget.userProvider.createUser(
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
        message: Strings.userIsCreated,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      title: Text(Strings.createUser),
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
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        TextButton(
          onPressed: () {
            _createUser();
          },
          child: Text(Strings.create),
        ),
      ],
    );
  }
}

/// Interface to edit the user.
class _EditUserDialog extends StatefulWidget {
  final User user;

  _EditUserDialog(this.user);

  @override
  State<StatefulWidget> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  User? _user;
  TextEditingController? _controller;

  @override
  void initState() {
    _user = widget.user;
    _controller = TextEditingController(text: _user!.name);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  /// Updates the [_user].
  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      _user!.setName(
        context,
        _controller!.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedAlertDialog(
      title: Text(Strings.editUser),
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
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        TextButton(
          onPressed: () {
            _updateUser();
          },
          child: Text(Strings.safe),
        ),
      ],
    );
  }
}

/// Interface for deleting a user.
class _DeleteUserDialog extends StatefulWidget {
  final UserProvider userProvider;

  _DeleteUserDialog(this.userProvider);

  @override
  _DeleteUserDialogState createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<_DeleteUserDialog> {
  User? _user;

  /// Set to true when work is in progress. Normaly used to check wether to show
  /// a [LoadingInterface] or not.
  bool _processing = false;

  @override
  void initState() {
    _user = widget.userProvider.currentUser;
    super.initState();
  }

  /// Deletes the [_user]. Sets [_processing] to true while processing.
  Future _deleteUser() async {
    setState(() {
      _processing = true;
    });
    await widget.userProvider.deleteUser(context, _user!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_processing) {
      return LoadingInterface(
        message: Strings.userIsDeleted,
      ).dialogInterface();
    }
    return SizedAlertDialog(
      title: Text(Strings.deleteuserQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.deleteUserMessage1 +
                _user!.name +
                Strings.deleteUserMessage2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(Strings.cancel),
        ),
        TextButton(
          onPressed: () {
            _deleteUser();
          },
          child: Text(Strings.delete),
        ),
      ],
    );
  }
}
