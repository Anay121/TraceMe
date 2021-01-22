import 'package:flutter/material.dart';

class MainHomePage extends StatelessWidget {
  final unameController = TextEditingController();
  final passController = TextEditingController();

  Map<String, String> getVal() {
    Map<String, String> val = Map<String, String>();
    val['uname'] = unameController.text;
    val['pass'] = passController.text;
    return val;
  }

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
                    Navigator.pushNamed(context, 'LoginPage',
                        arguments: getVal())
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
                    Navigator.pushNamed(context, 'HomePage',
                        arguments: getVal())
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
