import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/models.dart';


import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  final VoidCallback onClickedMakeAcc;

  const LoginPage({Key? key,required this.onClickedMakeAcc}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;


  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('password', _passwordController.text.trim());
  }


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
      });
    }
  }


  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Image.asset(
                  Images.frontLogo1,
                  height: 300.0,
                  width: 300.0,
                ),
              ),
              const Center(child: Text('Log-in',style: TextStyle(fontSize: 32,),),),
              const SizedBox(height: 20.0),
              const Text('Email'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email){
                  return (email == '') ? 'Please enter email' : null;
                },
              ),
              const SizedBox(height: 20.0),
              const Text('Password'),

              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: GestureDetector(
                    onLongPressStart: (details) {
                      setState(() {
                        _passwordVisible = true;
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        _passwordVisible = false;
                      });
                    },


                    child: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (pass){
                  return (pass == '') ? 'Please enter password' : null;
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                        if (_rememberMe) {
                          _saveUserData();
                        }
                      });
                    },
                  ),
                  const Text('Remember me'),
                ],
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: ()async{
                    try {
                      signIn();
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black,),
                      text: 'No Account? ',
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = widget.onClickedMakeAcc,
                          text: 'Sign Up',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.green,
                          ),
                        ),
                      ]
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(),),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User is not authenticated, sign in with email and password
        var response = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        print(response);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully Logged In!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // User is already authenticated, no need to sign in again
        print('User already authenticated, skipping sign in');
      }

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password.'),
          backgroundColor: Colors.red,
        ),
      );
    }finally {
      // Remove the loading indicator after 5 seconds
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    }
  }

}
