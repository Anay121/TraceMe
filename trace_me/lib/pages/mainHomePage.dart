import 'package:flutter/material.dart';
import 'package:trace_me/helper.dart';

class MainHomePage extends StatelessWidget {
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
                  Text(
                    'TraceMe',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 12,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Text(
                    'A BLOCKCHAIN POWERED AGRICULTURAL SUPPLY CHAIN TRACING SYSTEM',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 28),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 25),
                  SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 13,
                      child: TextButton(
                          onPressed: () => {
                                // print(unameController.text + passController.text)
                                Navigator.pushNamed(context, 'LoginPage')
                              },
                          child: Text(
                            'LOG IN',
                          ),
                          style: myOrangeButtonStyle)),
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
                  SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 13,
                      child: RaisedButton(
                        onPressed: () => {
                          // print(unameController.text + passController.text)
                          Navigator.pushNamed(context, 'RegisterPage')
                        },
                        child: Text(
                          'REGISTER',
                        ),
                      )),
                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
