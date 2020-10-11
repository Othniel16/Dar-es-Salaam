import 'package:dar_es_salaam/services/authService.dart';
import 'package:dar_es_salaam/shared/barrier.dart';
import 'package:dar_es_salaam/shared/constants.dart';
import 'package:dar_es_salaam/shared/progressDialog.dart';
import 'package:dar_es_salaam/shared/toast.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp({this.toggleView});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  bool _obscureText = true;
  bool _obscureText1 = true;

  // text field states
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';

  final Icon mailIcon = Icon(Icons.mail_outline, color: Colors.grey);
  final Icon lockIcon = Icon(Icons.lock_open, color: Colors.grey);
  final Icon closedLockIcon = Icon(Icons.lock_outline, color: Colors.grey);

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var signUpForm = Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // vector illustration
              Container(
                child: Image.asset(
                  'assets/images/signup_bg.png',
                ),
              ),

              SizedBox(height: 10.0),

              Container(
                child: Text(
                  "Let's Go!",
                  style: TextStyle(fontSize: 30.0, fontFamily: fontFamily),
                ),
              ),

              SizedBox(height: 40.0),

              // email field
              TextFormField(
                cursorColor: Colors.red[300],
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
                controller: _password,
                cursorColor: Colors.red[300],
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
                validator: (value) => value.length < 6
                    ? 'Password must be more than 6 characters long'
                    : null,
                obscureText: _obscureText,
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),

              SizedBox(height: 40.0),

              // confirm password field
              TextFormField(
                controller: _confirmPassword,
                cursorColor: Colors.red[300],
                decoration: textInputDecoration.copyWith(
                  hintText: 'Confirm Password',
                  prefixIcon: closedLockIcon,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText1 = !_obscureText1;
                      });
                    },
                    child: _obscureText1
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  if (value.length < 6)
                    return 'Password must be more than 6 characters long';
                  if (value != _password.text) return 'Passwords do not match';
                  return null;
                },
                obscureText: _obscureText1,
                onChanged: (value) {
                  setState(() => confirmPassword = value);
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
                    color: Colors.red[300],
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
                            .signUpWithEmailAndPassword(email, confirmPassword);
                        await _authService
                            .signUpWithEmailAndPassword(email, confirmPassword)
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
    return signUpForm;
  }
}
