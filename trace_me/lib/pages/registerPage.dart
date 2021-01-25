import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trace_me/helper.dart';
import 'package:http/http.dart' as http;

class RegisterData {
  String uname, password, fullname, role;
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _roleValue;
  bool _passwordShow;
  RegisterData _data = RegisterData();

  Future<dynamic> checkData(
      String uname, String pass, String fullname, String role) {
    return http.post(Helper.url + '/register',
        body: json.encode({
          'username': uname,
          'password': pass,
          'role': role,
          'fullname': fullname,
        }));
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
                  'Register Page',
                  style: TextStyle(
                      height: 5,
                      fontSize: MediaQuery.of(context).size.width / 10),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                Form(
                    key: _formKey,
                    child: Expanded(
                      // padding: EdgeInsets.all(
                      // MediaQuery.of(context).size.height / 80),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              obscureText: false,
                              decoration: InputDecoration(
                                  hintText: 'Enter Username',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0))),
                              onSaved: (val) {
                                _data.uname = val;
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 40),
                            TextFormField(
                              obscureText: !_passwordShow,
                              decoration: InputDecoration(
                                  hintText: 'Enter Password',
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
                                  // errorText: "Invalid username or password",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0))),
                              onSaved: (val) {
                                _data.password = val;
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 40),
                            TextFormField(
                              obscureText: false,
                              decoration: InputDecoration(
                                  hintText: 'Enter Your name',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0))),
                              onSaved: (val) {
                                _data.fullname = val;
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 40),
                            DropdownButtonFormField(
                              value: _roleValue,
                              items: [
                                "Farmer",
                                "Transporter",
                                "Processor",
                                "Validator",
                                "Retailer",
                              ]
                                  .map((label) => DropdownMenuItem(
                                        child: Text(label.toString()),
                                        value: label,
                                      ))
                                  .toList(),
                              hint: Text("Select your role"),
                              onChanged: (value) {
                                setState(() {
                                  _roleValue = value;
                                });
                              },
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0))),
                              onSaved: (val) {
                                _data.role = val;
                              },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 40),
                            ElevatedButton(
                              child: Text("Submit"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  // print(_data.fullname);
                                  checkData(_data.uname, _data.password,
                                          _data.fullname, _data.role)
                                      .then((val) {
                                    // check validation

                                    // redirect with params

                                    print(val.body);
                                  });
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    )),
              ]),
        ),
      )),
    );
  }
}
