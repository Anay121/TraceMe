import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool _passwordShow = false;
  final unameController = TextEditingController();
  final passController = TextEditingController();

  Future<dynamic> checkData(String uname, String pass) {
    return http.post('http://6aba66bd897b.ngrok.io/login',
        body: json.encode({
          'username': uname,
          'password': pass,
        }));
  }

  Map<String, String> getVal() {
    Map<String, String> val = Map<String, String>();
    val['uname'] = unameController.text;
    val['pass'] = passController.text;
    return val;
  }

  @override
  void initState() {
    _passwordShow = false;
    super.initState();
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
                  obscureText: !_passwordShow,
                  decoration: InputDecoration(
                      hintText: 'Enter Password',
                      errorText: "Invalid username or password",
                      suffixIcon: IconButton(
                        icon: Icon(_passwordShow
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordShow = !_passwordShow;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0))),
                  controller: passController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                RaisedButton(
                  onPressed: () => {
                    checkData(unameController.text, passController.text)
                        .then((val) {
                      print(val.body);
                    })
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
