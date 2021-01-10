import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
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
                  'Login Page',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 10),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                      hintText: 'Enter Username',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                  controller: unameController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                TextField(
                  obscureText: false,
                  decoration: InputDecoration(
                      hintText: 'Enter Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                  controller: passController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                RaisedButton(
                  onPressed: () => {
                    // print(unameController.text + passController.text)
                    Navigator.pushNamed(context, 'HomePage',
                        arguments: getVal())
                  },
                  child: Text(
                    'Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
