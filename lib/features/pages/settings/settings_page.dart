import 'package:cafe_staff_app/features/pages/admin/widgets/admin_appbar.dart';
import 'package:cafe_staff_app/features/pages/admin/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/paths.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/user/user_cubit.dart';
import '/core/widgets/dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _password = TextEditingController();
  String _selectedTheme = 'light';
  String _selectedLanguage = 'en';
  final List<String> _themeOptions = ['light', 'dark'];
  final List<String> _themeDisplayOptions = ['Light', 'Dark'];
  final List<String> _languageOptions = ['en', 'vi'];
  final List<String> _languageDisplayOptions = ['English', 'Vietnamese'];

  late AuthCubit _authCubit;
  late UserCubit _userCubit;

  @override
  void initState() {
    _authCubit = sl<AuthCubit>();
    _userCubit = sl<UserCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _userCubit.close();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showCustomizeDialog(
      context,
      title: "Change Password",
      actionText: "Change Password",
      content: TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(hintText: "Enter New Password"),
      ),
      onAction: () {
        final user = (_authCubit.state as AuthAuthenticated).user;
        _userCubit.updateUser(id: user.id, password: _password.text);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          (_authCubit.state as AuthAuthenticated).user.role == 'admin'
              ? adminAppBar(_scaffoldKey, "Settings")
              : AppBar(forceMaterialTransparency: true, title: const Text("Settings")),
      drawer: AdminDrawer(),
      body: SafeArea(
        child: ListView(
          children: [
            _themeTile(context),
            const Divider(),
            _languageTile(context),
            const Divider(),
            ListTile(
              title: const Text("Change Password"),
              leading: const Icon(Icons.key),
              onTap: _showChangePasswordDialog,
            ),
            const Divider(),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context) {
    return _optionTile(
      title: "Theme",
      icon: const Icon(Icons.color_lens_outlined),
      selectedOption: _selectedTheme,
      options: _themeOptions,
      displayOptions: _themeDisplayOptions,
      onChanged: (value) {
        if (value != null) setState(() => _selectedTheme = value);
      },
    );
  }

  Widget _languageTile(BuildContext context) {
    return _optionTile(
      title: "Language",
      icon: const Icon(Icons.language),
      selectedOption: _selectedLanguage,
      options: _languageOptions,
      displayOptions: _languageDisplayOptions,
      onChanged: (value) {
        if (value != null) setState(() => _selectedLanguage = value);
      },
    );
  }

  Widget _optionTile({
    required String title,
    required Icon icon,
    required String selectedOption,
    required List<String> options,
    required List<String> displayOptions,
    required ValueChanged<String?>? onChanged,
  }) {
    return ListTile(
      title: Text(title),
      leading: icon,
      subtitle: Text(_getDisplayValue(selectedOption, options, displayOptions) ?? ''),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () {
        _showDropdownDialog(title, selectedOption, options, displayOptions, onChanged);
      },
    );
  }

  void _logout() {
    _authCubit.logout();
    context.pushReplacement(Paths.login);
  }

  String? _getDisplayValue(String value, List<String> values, List<String> displayValues) {
    int index = values.indexOf(value);
    if (index == -1 || index >= displayValues.length) return null;
    return displayValues[index];
  }

  void _showDropdownDialog(
    String title,
    String? currentValue,
    List<String> values,
    List<String> displayValues,
    ValueChanged<String?>? onChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(values.length, (index) {
                return ListTile(
                  title: Text(displayValues[index]),
                  onTap: () {
                    if (onChanged != null) {
                      onChanged(values[index]);
                      Navigator.of(context).pop();
                    }
                  },
                  trailing: currentValue == values[index] ? const Icon(Icons.check) : null,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
