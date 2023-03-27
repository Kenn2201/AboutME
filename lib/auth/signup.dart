
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/models.dart';

class SignUpPage extends StatefulWidget {
  final Function() onClickedSignIn;
  const SignUpPage({Key? key,required this.onClickedSignIn}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  Images.frontLogo2,
                  height: 300.0,
                  width: 300.0,
                ),
              ),
              const Center(child: Text('Sign-Up',style: TextStyle(fontSize: 32,),),),
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
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (pass){
                  return (pass == '') ? 'Please enter password' : null;
                },
              ),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: ()async{
                    signUp();
                  },
                  child: const Text('Sign-Up'),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                      style: const TextStyle(color: Colors.black,),
                      text: 'Have an Existing Account? ',
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignIn,
                          text: 'Log-in',
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
  Future signUp() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),)
    );
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Created an Account!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The Email is already used by Another user!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
