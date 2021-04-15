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

  Future<dynamic> checkData(String uname, String pass, String fullname, String role) {
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                      height: MediaQuery.of(context).size.height / 200,
                      fontSize: MediaQuery.of(context).size.width / 12,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                Form(
                    key: _formKey,
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Enter Username',
                                suffixText: '*',
                                suffixStyle: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onSaved: (val) {
                                _data.uname = val;
                              },
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 40),
                            TextFormField(
                              obscureText: !_passwordShow,
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                suffixText: '*',
                                suffixStyle: TextStyle(
                                  color: Colors.red,
                                ),
                                suffixIcon: IconButton(
                                  icon:
                                      Icon(_passwordShow ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _passwordShow = !_passwordShow;
                                    });
                                  },
                                ),
                                // errorText: "Invalid username or password",
                              ),
                              onSaved: (val) {
                                _data.password = val;
                              },
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 40),
                            TextFormField(
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Enter organization name',
                                suffixText: '*',
                                suffixStyle: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onSaved: (val) {
                                _data.fullname = val;
                              },
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 40),
                            DropdownButtonFormField(
                              value: _roleValue,
                              items: [
                                "Farmer",
                                "Transporter",
                                "Processor",
                                "Distributor",
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
                                suffixText: '*',
                                suffixStyle: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onSaved: (val) {
                                _data.role = val;
                              },
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height / 20),
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 13,
                              child: ElevatedButton(
                                  child: Text("SIGN UP"),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      // print(_data.fullname);
                                      checkData(_data.uname, _data.password, _data.fullname,
                                              _data.role)
                                          .then((val) {
                                        // check validation
                                        print(val.statusCode);
                                        if (val.statusCode != 200) {
                                          print('something went wrong');
                                        }
                                        // redirect with params
                                        else {
                                          dynamic data = json.decode(val.body);
                                          // print(data);
                                          print(data['userid']);
                                          Session().setter(data);
                                          Navigator.popAndPushNamed(context, 'DisplayProductsPage');
                                        }

                                        print(val.body);
                                      });
                                    }
                                  },
                                  style: myOrangeButtonStyle),
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
