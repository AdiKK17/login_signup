import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loginsignup/home_page.dart';

import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'auth_provider.dart';

enum AuthMode { Login, SignUp }

class AuthenticationPage extends StatefulWidget {
  final bool againLogging;

  AuthenticationPage({this.againLogging = false});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthenticationPage();
  }
}

class _AuthenticationPage extends State<AuthenticationPage> {
  var _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    'profile',
//      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  GoogleSignInAccount _currentUser;
  String _contactText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.disconnect();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
        print(account.displayName);
        _shift(account.displayName);
      });
    });
  }

  _shift(name){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage(name)));
  }


  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }


  final Map<String, dynamic> _formData = {
    "email": null,
    "password": null,
    "username": null,
  };

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(hintText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(hintText: 'Full Name'),
      keyboardType: TextInputType.text,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['username'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(hintText: 'Password'),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password invalid';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildSubmitButton() {
    return RaisedButton(
        color: Colors.blue,
        child: Text(
          _authMode == AuthMode.Login ? "LOGIN" : "REGISTER",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _submitForm();
        });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

//    if (_authMode == AuthMode.Login) {
//       Provider.of<AuthProvider>(context,listen: false).login(context,_formData["email"], _formData["password"]).then((value) {
//         setState(() {_isLoading = false;});
//        if(value == "yes"){
//          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
//        } else if(value == "maybe") {
//          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OtpVerificationPage()));
//        }
//       });
//    } else {
//      Provider.of<AuthProvider>(context, listen: false)
//          .signUp(context,_formData["username"],_formData["email"], _formData["password"]).then((value) {
//        setState(() {_isLoading = false;});
//        if(value){
//          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OtpVerificationPage()));
//        }
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 80, left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _authMode == AuthMode.Login ? "Login" : "Register",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 35),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _authMode == AuthMode.Login
                        ? "Welcome back,\nplease login\nto your account"
                        : "Lets get\nyou on board",
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: _buildEmailTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                _authMode == AuthMode.SignUp
                    ? Container(
                        child: _buildUsernameTextField(),
                        width: deviceWidth * 0.85,
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: _buildPasswordTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                _authMode == AuthMode.Login
                    ? Container(
                        alignment: Alignment.centerRight,
                        child: FlatButton(
                          child: Text(
                            "Forget password?",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {},
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 25,
                ),
                _isLoading == true
                    ? CircularProgressIndicator()
                    : Container(
                        child: _buildSubmitButton(),
                        height: 50,
                        width: deviceWidth * 0.85,
                      ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 150,
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                        color: Colors.black,
                      )),
                      Text("  Or  "),
                      Expanded(
                          child: Divider(
                        color: Colors.black,
                      )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton.icon(
                        onPressed: () {
                          _handleSignIn();
                        },
                        icon: Icon(Icons.mail),
                        label: Text("Gmail")),
                    SizedBox(
                      width: 30,
                    ),
                    RaisedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.book),
                      label: Text("Facebook"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                _isLoading == false
                    ? FlatButton(
                        onPressed: () {
                          setState(() {
                            if (_authMode == AuthMode.Login) {
                              _authMode = AuthMode.SignUp;
                            } else {
                              _authMode = AuthMode.Login;
                            }
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                              text: _authMode == AuthMode.Login
                                  ? "Don't have an account?"
                                  : "Already have an account?",
                              style: TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                    text: _authMode == AuthMode.Login
                                        ? "  Sign Up"
                                        : "  Sign In",
                                    style: TextStyle(color: Colors.blue))
                              ]),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
