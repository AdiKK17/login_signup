import 'package:flutter/material.dart';

import 'auth_page.dart';

class HomePage extends StatelessWidget {
  final String name;
  final String email;

  HomePage(this.name, this.email);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("name: " + name),
          SizedBox(
            height: 5,
          ),
          Text("email: " + email),
          SizedBox(
            height: 20,
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => AuthenticationPage()));
            },
            child: Text("logout"),
          ),
        ],
      )),
    );
  }
}
