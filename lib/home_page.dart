import 'package:flutter/material.dart';

import 'auth_page.dart';

class HomePage extends StatelessWidget {

  final String name;
  HomePage(this.name);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: FlatButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AuthenticationPage()));
          },
          child: Text("logout"),
        ),
      ),
    );
  }
}
