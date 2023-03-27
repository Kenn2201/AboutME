

import 'package:aboutme/auth/login.dart';
import 'package:flutter/material.dart';


import 'signup.dart';
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin ?
  LoginPage(onClickedMakeAcc: toggle,) : SignUpPage(onClickedSignIn: toggle,);
  void toggle() => setState(() => isLogin = !isLogin);
}
