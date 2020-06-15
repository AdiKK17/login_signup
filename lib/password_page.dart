import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'auth_page.dart';

class PasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PasswordPage();
  }
}

class _PasswordPage extends State<PasswordPage> {
  var _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }


  final Map<String, dynamic> _formData = {
    "password": null,
  };

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
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

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords do not match.';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return RaisedButton(
        color: Colors.black87,
        child: Text(
           "Change Password",
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

    await Provider.of<AuthProvider>(context,listen: false).resetPassword(context, _formData["password"]);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AuthenticationPage()), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                ),
                SizedBox(height: 10,),
                Container(
                  child: _buildPasswordTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: _buildPasswordConfirmTextField(),
                  width: deviceWidth * 0.85,
                ),
                SizedBox(
                  height: 25,
                ),
                _isLoading == true
                    ? CircularProgressIndicator()
                    : Container(
                  child: _buildSubmitButton(),
                  width: 200,
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}