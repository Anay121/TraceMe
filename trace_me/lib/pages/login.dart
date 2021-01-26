import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool _passwordShow = false;
  final unameController = TextEditingController();
  final passController = TextEditingController();
  bool _validateError = false;

  Future<dynamic> checkData(String uname, String pass) {
    return http.post(Helper.url + '/login',
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
                      errorText: _validateError
                          ? "Invalid username or password"
                          : null,
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
                ElevatedButton(
                  onPressed: () => {
                    checkData(unameController.text, passController.text)
                        .then((val) {
                      // check validation
                      print(val.statusCode);
                      if (val.statusCode == '401') {
                        setState(() {
                          _validateError = true;
                        });
                      }
                      // redirect with params
                      else {
                        dynamic data = json.decode(val.body);
                        print(data['userid']);
                        Session().setter(data);
                        Navigator.pushNamed(context, 'DisplayProductsPage');
                      }
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
