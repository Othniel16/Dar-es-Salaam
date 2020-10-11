import 'package:dar_es_salaam/services/authService.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:dar_es_salaam/shared/constants.dart';
import 'package:dar_es_salaam/shared/progressDialog.dart';
import 'package:dar_es_salaam/shared/toast.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  // text field states
  String email = '';
  String password = '';
  String error = '';

  final Icon mailIcon = Icon(Icons.mail_outline, color: Colors.grey);
  final Icon lockIcon = Icon(Icons.lock_open, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    var signInForm = Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // vector illustration
              Container(
                child: Image.asset(
                  'assets/images/login_bg.png',
                ),
              ),

              SizedBox(height: 10.0),

              Container(
                child: Text(
                  'Welcome Back,',
                  style: TextStyle(fontSize: 30.0, fontFamily: fontFamily),
                ),
              ),

              SizedBox(height: 40.0),

              //email field
              TextFormField(
                cursorColor: Colors.greenAccent,
                decoration: textInputDecoration.copyWith(
                    hintText: 'Email', prefixIcon: mailIcon),
                validator: (value) =>
                    value.isEmpty ? 'Email cannot be empty' : null,
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),

              SizedBox(height: 40.0),

              // password field
              TextFormField(
                cursorColor: Colors.greenAccent,
                decoration: textInputDecoration.copyWith(
                  hintText: 'Password',
                  prefixIcon: lockIcon,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: _obscureText
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) => value.length < 6
                    ? 'Password must be more than 6 characters long'
                    : null,
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),

              SizedBox(height: 40.0),

              // sign up button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  RaisedButton(
                    elevation: 0.0,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    color: Colors.greenAccent,
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        // show a loading widget to let the user know what is happening
                        showProgress(context);
                        // The second calling of signInWithEmail gives us a way to close the dialog
                        dynamic result = await _authService
                            .signInWithEmailAndPassword(email, password);
                        await _authService
                            .signInWithEmailAndPassword(email, password)
                            .then((value) {
                          // dismiss the loading dialog when book has been added to db
                          dismissProgressDialog();
                        });

                        if (result.toString().isNotEmpty) {
                          setState(() {
                            error = result;
                            showSnackBar(context: context, message: error);
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
    return signInForm;
  }
}
