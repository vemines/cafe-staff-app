import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/active_checkbox.dart';
import '../widgets/dialog_info_row.dart';
import '../widgets/header_row_with_create_button.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/string_extensions.dart';
import '/features/entities/user_entity.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/core/widgets/dialog.dart';
import '/injection_container.dart';
import '../../../blocs/user/user_cubit.dart';
import '../widgets/action_icon.dart';
import '../widgets/admin_appbar.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final UserCubit _userCubit; // Instance variable

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
      appBar: adminAppBar(_scaffoldKey, "User Management"),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: BlocProvider.value(
          value: _userCubit,
          child: Column(
            children: [
              headerRowWithCreateButton(
                title: "User",
                onPressed: () => _showCreateOrEditUserDialog(context, null),
                buttonText: "Create User",
                belowTabbar: false,
              ),
              Expanded(
                child: BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is UserError) {
                      return Center(child: Text("Error: ${state.failure.message}"));
                    } else if (state is UserLoaded) {
                      final users = state.users;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _userListTile(user, context);
                        },
                      );
                    }
                    return const Center(child: Text('No users found'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _userListTile(UserEntity user, BuildContext context) {
    return ListTile(
      title: Text(user.fullname),
      subtitle: Text(user.role.upperCaseFirstLetter),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.key,
            text: "Change Password",
            onPressed: () => _showChangePasswordDialog(context, user),
          ),
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit User",
            onPressed: () => _showCreateOrEditUserDialog(context, user),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete User",
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
      title: 'User Detail: (${user.fullname})',
      actionText: "Edit user",
      content: DefaultTextStyle(
        style: context.textTheme.bodyMedium!,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoRow(context, 'Fullname:', user.fullname),
              infoRow(context, 'UserName:', user.username),
              infoRow(context, 'Role:', user.role),
              infoRow(context, 'Email:', user.email),
              infoRow(context, 'Phone Number:', user.phoneNumber),
              infoRow(context, 'Created At:', user.createdAt.toFormatTime),
              infoRow(context, 'Updated At:', user.updatedAt.toFormatTime),
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
    final title = isCreate ? 'Create User' : 'Edit User';

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
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: fullname,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: role,
                onChanged: (value) => role = value,
                items: const [
                  DropdownMenuItem(value: 'serve', child: Text('Serve')),
                  DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                ],
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              if (isCreate)
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => value!.isEmpty ? "Required" : null,
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
      title: 'Change Password',
      actionText: "Change Password",
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter new password'),
          validator: (value) => value!.isEmpty ? "Required" : null,
        ),
      ),
      onAction: () {
        _userCubit.updateUser(id: user.id, password: password.text);
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserEntity user) {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete User',
      actionText: "Delete User",
      content: Text('Are you sure you want to delete this user (${user.fullname})?'),
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
