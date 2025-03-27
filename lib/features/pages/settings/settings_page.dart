import '../../../core/extensions/build_content_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/locale.dart';
import '/app/cubits/cubits.dart';
import '/core/widgets/dialog.dart';
import '/configs/configs.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/user/user_cubit.dart';
import '../admin/widgets/admin_appbar.dart';
import '../admin/widgets/admin_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _password = TextEditingController();
  late String _selectedTheme;
  late String _selectedLanguage;

  late AuthCubit _authCubit;
  late UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _userCubit = sl<UserCubit>();
    _selectedTheme = ThemeCubit.currentTheme;
    _selectedLanguage = context.read<LocaleCubit>().state.languageCode;
  }

  @override
  void dispose() {
    _userCubit.close();
    _password.dispose();
    super.dispose();
  }

  bool isAdmin() {
    final state = _authCubit.state;
    if (state is AuthAuthenticated) {
      return state.user.role == 'admin';
    }
    return false;
  }

  void _showChangePasswordDialog() {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.changePassword),
      actionText: context.tr(I18nKeys.changePassword),
      content: TextFormField(
        controller: _password,
        obscureText: true,
        decoration: InputDecoration(hintText: context.tr(I18nKeys.enterNewPassword)),
        validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
      ),
      onAction: () {
        final state = _authCubit.state;
        if (_password.text.length >= 6 && state is AuthAuthenticated) {
          _userCubit.updateUser(id: state.user.id, password: _password.text);
          Navigator.of(context).pop();
        } else {
          context.snakebar(context.tr(I18nKeys.passwordLengthError));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedLanguage = sl<LocaleCubit>().state.languageCode;

    return Scaffold(
      key: _scaffoldKey,
      appBar:
          isAdmin()
              ? adminAppBar(_scaffoldKey, context.tr(I18nKeys.settings))
              : AppBar(
                forceMaterialTransparency: true,
                title: Text(context.tr(I18nKeys.settings)),
                leading: BackButton(),
              ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: ListView(
          children: [
            _themeTile(context),
            const Divider(),
            _languageTile(context),
            const Divider(),
            ListTile(
              title: Text(context.tr(I18nKeys.changePassword)),
              leading: const Icon(Icons.key),
              onTap: _showChangePasswordDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(BuildContext context) {
    return _optionTile(
      context,
      title: context.tr(I18nKeys.selectTheme),
      icon: const Icon(Icons.color_lens_outlined),
      selectedOption: _selectedTheme,
      options: themeOptions,
      displayOptions: themeOptions,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedTheme = value);
          sl<ThemeCubit>().toggleTheme(value);
        }
      },
    );
  }

  Widget _languageTile(BuildContext context) {
    return _optionTile(
      context,
      title: context.tr(I18nKeys.selectLanguage),
      icon: const Icon(Icons.language),
      selectedOption: _selectedLanguage,
      options: supportedLocaleCode,
      displayOptions: supportedLocaleName,
      onChanged: (value) {
        if (value != null) {
          sl<LocaleCubit>().setLocale(Locale(value));
        }
      },
    );
  }

  Widget _optionTile(
    BuildContext context, {
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
        _showDropdownDialog(context, title, selectedOption, options, displayOptions, onChanged);
      },
    );
  }

  String? _getDisplayValue(String value, List<String> values, List<String> displayValues) {
    int index = values.indexOf(value);
    if (index == -1 || index >= displayValues.length) return null;
    return displayValues[index];
  }

  void _showDropdownDialog(
    BuildContext context,
    String title,
    String? currentValue,
    List<String> values,
    List<String> displayOptions,
    ValueChanged<String?>? onChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(values.length, (index) {
                final value = values[index];
                final display = displayOptions[index];
                return ListTile(
                  title: Text(display),
                  onTap: () {
                    if (onChanged != null) {
                      onChanged(value);
                      Navigator.of(context).pop();
                    }
                  },
                  trailing: currentValue == value ? const Icon(Icons.check) : null,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
