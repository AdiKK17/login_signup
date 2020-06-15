import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'password_page.dart';

enum AuthMode { email, otp }

class OtpVerificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OtpVerificationPage();
  }
}

class _OtpVerificationPage extends State<OtpVerificationPage> {
  int _VerifiedOTP;
  String _email;
  bool _isLoading = false;

  AuthMode _authMode = AuthMode.email;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  Widget _buildOTPTextField() {
    return TextFormField(
      maxLength: 4,
      initialValue: "",
      decoration: InputDecoration(
          counterText: "",
          hintText: 'Enter Verification Code',
          ),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter the code';
        }
        return null;
      },
      onSaved: (String value) {
        _VerifiedOTP = int.parse(value);
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(hintText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      initialValue: "",
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

  void _submitForm() async {
    if (!_formkey.currentState.validate()) {
      return;
    }
    _formkey.currentState.save();

     if(_authMode == AuthMode.email){
       Provider.of<AuthProvider>(context, listen: false).resendOTP(context, _email);
       setState(() {
         _authMode = AuthMode.otp;
       });
     } else {
       setState(() {
         _isLoading = true;
       });
       Provider.of<AuthProvider>(context, listen: false)
           .verifyWithOTP(context, _VerifiedOTP)
           .then((value) {
         setState(() {
           _isLoading = false;
         });
         if (value) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PasswordPage()));
         }
       });
     }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: Form(
            key: _formkey,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.cyanAccent,
              child: Card(
                elevation: 10,
                child: _isLoading
                    ? LinearProgressIndicator()
                    : Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 250,
                      child: _authMode == AuthMode.otp ? _buildOTPTextField() : Container(),
                    ),
                    Container(
                      width: 250,
                      child: _authMode == AuthMode.email ? _buildEmailTextField() : Container(),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.tealAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () {
                            _submitForm();
                            },
                          child: _authMode == AuthMode.otp ? Text("Verify") : Text("Send"),
                        ),
                      ],
                    )
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
