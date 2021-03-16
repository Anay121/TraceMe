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
    final double height = MediaQuery.of(context).size.height * 0.50;
    return Scaffold(
      body: Column(children: [
        ClipPath(
          clipper: mainPageBezierClipper(),
          child: Container(
            color: orange,
            height: height,
          ),
        ),
        Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height / 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: 'Enter Username',
                    ),
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
                        )),
                    controller: passController,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                  SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 13,
                      child: ElevatedButton(
                        onPressed: () => {
                          checkData(unameController.text, passController.text)
                              .then((val) {
                            // check validation
                            print(val.statusCode);
                            if (val.statusCode != 200) {
                              setState(() {
                                _validateError = true;
                              });
                            }
                            // redirect with params
                            else {
                              dynamic data = json.decode(val.body);
                              print(data);
                              print(data['userid']);
                              Session().setter(data);
                              Navigator.popAndPushNamed(
                                  context, 'DisplayProductsPage');
                            }
                          })
                        },
                        child: Text(
                          'LOG IN',
                        ),
                        style: myOrangeButtonStyle,
                      )),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}
