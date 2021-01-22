import 'package:flutter/material.dart';

class MainHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height / 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to TraceMe',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 12),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 15),
                RaisedButton(
                  onPressed: () => {
                    // print(unameController.text + passController.text)
                    Navigator.pushNamed(context, 'LoginPage')
                  },
                  child: Text(
                    'Login',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 60),
                Row(children: <Widget>[
                  Expanded(
                      child: Divider(
                    thickness: 2,
                    endIndent: 10,
                  )),
                  Text("OR"),
                  Expanded(
                      child: Divider(
                    thickness: 2,
                    indent: 10,
                  )),
                ]),
                SizedBox(height: MediaQuery.of(context).size.height / 60),
                RaisedButton(
                  onPressed: () => {
                    // print(unameController.text + passController.text)
                    Navigator.pushNamed(context, 'RegisterPage')
                  },
                  child: Text(
                    'Register',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
