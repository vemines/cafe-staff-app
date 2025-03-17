import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Text _textWidget(String text, {Color? color, double? size, FontWeight? weight}) => Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color ?? Colors.white,
    ),
  );

  void _login(BuildContext context) {
    // 'serve' , 'cashier', 'admin'
    // final user = MockData.staff.where((u) => u.role == 'serve').first;

    context.pushNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/bg.png'), fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 400),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sbH8(),
                    Center(child: _textWidget("Login", weight: FontWeight.w700, size: 30)),
                    sbH6(),
                    _textWidget("Username"),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white)),
                      ),
                      child: TextFormField(
                        cursorColor: Colors.white70,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.person, color: Colors.white),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Enter Username",
                          hintStyle: TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                    sbH4(),
                    _textWidget("Password"),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white)),
                      ),
                      child: TextFormField(
                        obscureText: true,
                        cursorColor: Colors.white70,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.lock, color: Colors.white),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Enter Password",
                          hintStyle: TextStyle(color: Colors.white70),
                          contentPadding: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                    sbH8(),
                    GestureDetector(
                      onTap: () => _login(context),
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: _textWidget("Log In", color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
