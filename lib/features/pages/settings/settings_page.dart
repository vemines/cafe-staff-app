import 'package:cafe_staff_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _newPassword = TextEditingController();
  String _selectedTheme = 'light';
  String _selectedLanguage = 'en';

  final List<String> _themeOptions = ['light', 'dark', 'system'];
  final List<String> _themeDisplayOptions = ['Light', 'Dark', 'System'];

  final List<String> _languageOptions = ['en', 'vi'];
  final List<String> _languageDisplayOptions = ['English', 'Vietnamese'];

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: SizedBox(
            width: 400,
            child: TextFormField(
              controller: _newPassword,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Enter New Password"),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            sbW2(),
            FilledButton(
              onPressed: () {
                // Placeholder for password update logic.
                Navigator.of(context).pop();
              },
              child: const Text("Change Password"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, title: const Text("Settings")),
      body: ListView(
        children: [
          _buildThemeTile(context),
          const Divider(),
          _buildLanguageTile(context),
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
            onTap: () {
              // Placeholder for logout logic.
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return _buildOptionTile(
      title: "Theme",
      icon: const Icon(Icons.color_lens_outlined),
      selectedOption: _selectedTheme,
      options: _themeOptions,
      displayOptions: _themeDisplayOptions,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedTheme = value;
          });
        }
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return _buildOptionTile(
      title: "Language",
      icon: const Icon(Icons.language),
      selectedOption: _selectedLanguage,
      options: _languageOptions,
      displayOptions: _languageDisplayOptions,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedLanguage = value;
          });
        }
      },
    );
  }

  Widget _buildOptionTile({
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
