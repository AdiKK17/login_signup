import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  String _userId;
  String _email;
  String _name;

  final ngrokUrl = "https://silogin.herokuapp.com";

  String get email {
    return _email;
  }
  String get name {
    return _name;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An error Occured!"),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }



  Future<String> login(
      BuildContext context, String email, String password) async {
    final response = await http.post("$ngrokUrl/user/login",
        body: json.encode(
          {
            "email": email,
            "password": password,
          },
        ),
        headers: {"Content-type": "application/json"});

    final responseData = json.decode(response.body);
    print(responseData);

    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return "no";
    }

    _name = responseData["name"];
    _email = responseData["email"];

    return "yes";
  }

  Future<bool> signUp(
      BuildContext context, String name, String email, String password) async {
    final response = await http.post("$ngrokUrl/user/signup",
        body: json.encode(
          {
            "name": name,
            "email": email,
            "password": password,
          },
        ),
        headers: {"Content-type": "application/json"});

    final responseData = json.decode(response.body);
    print(responseData);

    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return false;
    }
    _userId = responseData["userId"];
    _name = responseData["name"];
    _email = responseData["email"];

    return true;
  }

  Future<bool> verifyWithOTP(BuildContext context, int enteredOtp) async {
    final url = "$ngrokUrl/user/otpVerify/$_userId";

    final response = await http.post(url,
        body: json.encode({"otp": enteredOtp.toString()}),
        headers: {'Content-Type': 'application/json'});

    final responseData = json.decode(response.body);
    print(responseData);

    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return false;
    }

    _userId = responseData["userId"];
    _name = responseData["name"];
    _email = responseData["email"];

    return true;
  }

  Future<void> resendOTP(context,email) async {
    final url = "$ngrokUrl/user/forgotPassword";
    final response = await http.post(url,
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
    final responseData = json.decode(response.body);
    print(json.decode(response.body));
    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
    }
    _userId = responseData["userId"];
  }

  Future<void> resetPassword(context,password) async {
    final url = "$ngrokUrl/user/resetPassword";
    final response = await http.post(url,
        body: json.encode({"email": _email,"password": password}),
        headers: {'Content-Type': 'application/json'});
    final responseData = json.decode(response.body);
    print(json.decode(response.body));
    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
    }
    _userId = responseData["userId"];
  }


}
