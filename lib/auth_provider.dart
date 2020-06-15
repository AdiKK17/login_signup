import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'auth_page.dart';

class AuthProvider extends ChangeNotifier {
  String _token;
  String _userId;
  String _email;
  String _name;

  String _sessionId;
  String _openViduToken;
  String _sessionRole;

  DateTime _expiryDate;
  Timer _authTimer;

  final ngrokUrl = "https://join-chat.herokuapp.com";

  String get email {
    return _email;
  }
  String get name {
    return _name;
  }

  String get sessionId {
    return _sessionId;
  }
  String get openViduToken {
    return _openViduToken;
  }
  String get sessionRole{
    return _sessionRole;
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

  Future<void> setVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey("isLogged")){
      return;
    }

    final expiryDate = DateTime.parse(prefs.getString("expiryDate"));
    if(expiryDate != null) {
      if (expiryDate.isBefore(DateTime.now())) {
        logout();
        return;
      }
    }

    _expiryDate = expiryDate;
    _token = prefs.getString("token");
    _userId = prefs.getString("userId");
    _email = prefs.getString("email");
    _name = prefs.getString("name");
    autoLogout();
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
      if (responseData["error"] == 'User is not verified') {
        _userId = responseData["userId"];
        return "maybe";
      }
      _showErrorDialog(context, responseData["error"]);
      return "no";
    }

    _token = responseData["token"];
    _name = responseData["name"];
    _email = responseData["email"];
    _expiryDate = DateTime.now().add(Duration(hours: 12));

    final prefs = await SharedPreferences.getInstance();

    prefs.setString("token", _token);
    prefs.setString("userId", _userId);
    prefs.setString("name", _name);
    prefs.setString("email", _email);
    prefs.setString("expiryDate", _expiryDate.toIso8601String());
    prefs.setBool("isLogged", true);
    autoLogout();
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
    _userId = responseData["userId"];

    if (responseData["error"] != null) {
      _showErrorDialog(context, responseData["error"]);
      return false;
    }
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

    _token = responseData["token"];
    _userId = responseData["userId"];
    _name = responseData["name"];
    _email = responseData["email"];
    _expiryDate = DateTime.now().add(Duration(hours: 12));

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", _token);
    prefs.setString("userId", _userId);
    prefs.setString("name", _name);
    prefs.setString("email", _email);
    prefs.setString("expiryDate", _expiryDate.toIso8601String());
    prefs.setBool("isLogged", true);
    autoLogout();
    return true;
  }

  Future<void> resendOTP() async {
    final url = "$ngrokUrl/user/otpResend/$_userId";
    final response = await http.get(url);
    print(json.decode(response.body));
  }

  Future<bool> logout() async {
    _userId = null;
    _token = null;
    _email = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    return true;
  }

  void autoLogout(){
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

  Future<bool> createSession() async {
    final response = await http.get(
      "$ngrokUrl/user/getSession",
      headers: {
        "Authorization": "Basic $_token",
        "Content-Type": "application/json"
      },
    );

    print(response.statusCode);
    if(response.statusCode == 400 || response.statusCode == 409){
      return false;
    }
    final responseData = json.decode(response.body);
    _sessionId = responseData["id"];
    notifyListeners();
    return true;
  }

  Future<int> createToken(int num,String session) async {
    final response = await http.post(
      "$ngrokUrl/user/getToken",
      headers: {
        "Authorization": "Basic $_token",
        "Content-Type": "application/json"
      },
      body: json.encode({
        "sessionName": session,
        "role": num == 0 ? "MODERATOR" : "PUBLISHER"
      }),
    );

    if(response.statusCode == 400 || response.statusCode == 404){
        return response.statusCode;
    }
    final responseData = json.decode(response.body);
    print(responseData["role"]);
    _sessionId = session;
    _openViduToken = responseData["token"];
    _sessionRole = responseData["role"];
    return response.statusCode;
  }

}
