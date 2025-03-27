import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/locale.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/string_extensions.dart';
import '/core/widgets/dialog.dart';
import '/features/entities/user_entity.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/injection_container.dart';
import '../../../blocs/user/user_cubit.dart';
import '../widgets/action_icon.dart';
import '../widgets/active_checkbox.dart';
import '../widgets/admin_appbar.dart';
import '../widgets/dialog_info_row.dart';
import '../widgets/header_row_with_create_button.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _userCubit = sl<UserCubit>();
    _userCubit.getAllUsers();
  }

  @override
  void dispose() {
    _userCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(_scaffoldKey, context.tr(I18nKeys.userManagement)),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: BlocProvider.value(
          value: _userCubit,
          child: Column(
            children: [
              headerRowWithCreateButton(
                title: context.tr(I18nKeys.userManagement),
                onPressed: () => _showCreateOrEditUserDialog(context, null),
                buttonText: context.tr(I18nKeys.createUser),
                belowTabbar: false,
              ),
              Expanded(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (state is UserInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is UserError) {
                      return Center(
                        child: Text(
                          context.tr(I18nKeys.errorWithMessage, {
                            'message': state.failure.message ?? 'Unknown error',
                          }),
                        ),
                      );
                    } else if (state is UserLoaded) {
                      final users = state.users;
                      return users.isEmpty
                          ? Center(child: Text(context.tr(I18nKeys.noUsersFound)))
                          : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return _userListTile(context, user);
                            },
                          );
                    }
                    return Center(child: Text(context.tr(I18nKeys.noUsersFound)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _userListTile(BuildContext context, UserEntity user) {
    return ListTile(
      title: Text(user.fullname),
      subtitle: Text(user.role.upperCaseFirstLetter),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.key,
            text: context.tr(I18nKeys.changePassword),
            onPressed: () => _showChangePasswordDialog(context, user),
          ),
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editUser),
            onPressed: () => _showCreateOrEditUserDialog(context, user),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteUser),
            onPressed: () => _showDeleteUserDialog(context, user),
          ),
          activeCheckbox(
            isActive: user.isActive,
            textColor: user.isActive ? Colors.green : Colors.grey,
            onChanged: (value) => _updateUserStatus(user, value),
          ),
        ],
      ),
      onTap: () => _showUserDetail(context, user),
    );
  }

  void _showUserDetail(BuildContext context, UserEntity user) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.userDetail, {'userName': user.fullname}),
      actionText: context.tr(I18nKeys.editUser),
      content: DefaultTextStyle(
        style: context.textTheme.bodyMedium!,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow(context, context.tr(I18nKeys.fullname), user.fullname),
              infoRow(context, context.tr(I18nKeys.username), user.username),
              infoRow(context, context.tr(I18nKeys.role), user.role),
              infoRow(context, context.tr(I18nKeys.email), user.email),
              infoRow(context, context.tr(I18nKeys.phoneNumber), user.phoneNumber),
              infoRow(context, context.tr(I18nKeys.createdAt), user.createdAt.toFormatTime),
              infoRow(context, context.tr(I18nKeys.updatedAt), user.updatedAt.toFormatTime),
            ],
          ),
        ),
      ),
      onAction: () {
        Navigator.pop(context);
        _showCreateOrEditUserDialog(context, user);
      },
    );
  }

  void _showCreateOrEditUserDialog(BuildContext context, UserEntity? user) {
    final formKey = GlobalKey<FormState>();
    final username = TextEditingController(text: user?.username);
    final fullname = TextEditingController(text: user?.fullname);
    final email = TextEditingController(text: user?.email);
    final phoneNumber = TextEditingController(text: user?.phoneNumber);
    final password = TextEditingController();
    String? role = user?.role ?? 'serve';

    bool isCreate = user == null;
    final title = isCreate ? context.tr(I18nKeys.createUser) : context.tr(I18nKeys.editUser);

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: username,
                decoration: InputDecoration(labelText: context.tr(I18nKeys.username)),
                validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
              ),
              TextFormField(
                controller: fullname,
                decoration: InputDecoration(labelText: context.tr(I18nKeys.fullname)),
                validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
              ),
              DropdownButtonFormField<String>(
                value: role,
                onChanged: (value) => role = value,
                items: [
                  DropdownMenuItem(value: 'serve', child: Text(context.tr(I18nKeys.serve))),
                  DropdownMenuItem(value: 'cashier', child: Text(context.tr(I18nKeys.cashier))),
                ],
                decoration: InputDecoration(labelText: context.tr(I18nKeys.role)),
              ),
              TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: context.tr(I18nKeys.email)),
                validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
              ),
              TextFormField(
                controller: phoneNumber,
                decoration: InputDecoration(labelText: context.tr(I18nKeys.phoneNumber)),
                validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
              ),
              if (isCreate)
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: context.tr(I18nKeys.password)),
                  validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
                ),
            ],
          ),
        ),
      ),
      onAction: () {
        if (formKey.currentState?.validate() ?? false) {
          if (isCreate) {
            _userCubit.createUser(
              username: username.text,
              fullname: fullname.text,
              role: role!,
              email: email.text,
              phoneNumber: phoneNumber.text,
              password: password.text,
              isActive: false,
            );
          } else {
            _userCubit.updateUser(
              id: user.id,
              username: username.text,
              fullname: fullname.text,
              role: role,
              email: email.text,
              phoneNumber: phoneNumber.text,
              isActive: user.isActive,
            );
          }
          Navigator.pop(context);
        }
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, UserEntity user) {
    final formKey = GlobalKey<FormState>();
    final password = TextEditingController();

    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.changePassword),
      actionText: context.tr(I18nKeys.changePassword),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: password,
          obscureText: true,
          decoration: InputDecoration(hintText: context.tr(I18nKeys.enterNewPassword)),
          validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
        ),
      ),
      onAction: () {
        if (formKey.currentState?.validate() ?? false) {
          _userCubit.updateUser(id: user.id, password: password.text);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserEntity user) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteUser),
      content: Text(context.tr(I18nKeys.confirmDeleteUserMessage, {'userName': user.fullname})),
      onAction: () {
        _userCubit.deleteUser(id: user.id);
        Navigator.pop(context);
      },
    );
  }

  void _updateUserStatus(UserEntity user, bool isActive) {
    _userCubit.updateUser(id: user.id, isActive: isActive);
  }
}
