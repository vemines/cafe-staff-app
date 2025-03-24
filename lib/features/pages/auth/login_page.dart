// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';
import '../../../app/paths.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  late AuthCubit _authCubit;

  @override
  void initState() {
    _authCubit = sl<AuthCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (_username.text.length >= 6 && _password.text.length >= 6) {
      _authCubit.login(username: _username.text, password: _password.text);
    }
    // context.snakebar("username and password must have 6 characters");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (_, state) {
          if (state is AuthError) {
            context.snakebar(state.failure.message ?? 'Login Failed');
          } else if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.role == 'serve' || user.role == 'cashier')
              context.go(Paths.home);
            else if (user.role == 'admin')
              context.go(Paths.dashboard);
            else {
              context.snakebar("Role invalid");
            }
          }
        },
        builder: (_, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/bg.png'),
                  fit: context.isMobile ? BoxFit.fitHeight : BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: _loginForm(context),
            );
          }
        },
      ),
    );
  }

  Container _loginForm(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: 16.borderRadius,
      ),
      child: ClipRRect(
        borderRadius: 20.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sbH8,
                Center(child: _textWidget("Login", weight: FontWeight.w700, size: 30)),
                sbH6,
                _textWidget("Username"),
                _inputField(_username, "Enter Username"),
                sbH4,
                _textWidget("Password"),
                _inputField(_password, "Enter Password", obscureText: true),
                sbH8,
                GestureDetector(
                  onTap: () => _login(context),
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: 20.borderRadius),
                    alignment: Alignment.center,
                    child: _textWidget("Log In", color: Colors.black, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text _textWidget(String text, {Color? color, double? size, FontWeight? weight}) => Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? Colors.white,
    ),
  );

  Container _inputField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
  }) {
    return Container(
      height: 35,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white))),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        cursorColor: Colors.white70,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(hintText),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) => InputDecoration(
    suffixIcon: Icon(Icons.person, color: Colors.white),
    fillColor: Colors.white,
    border: InputBorder.none,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.white70),
    contentPadding: EdgeInsets.only(bottom: 10),
  );
}
