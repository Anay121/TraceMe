import 'dart:convert';

import 'package:flutter/material.dart';

class MainHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.50;
    return Scaffold(
        body: Column(children: [
      ClipPath(
        clipper: BezierClipper(),
        child: Container(
          color: Color.fromRGBO(255, 91, 53, 1),
          height: height,
        ),
      ),
      Center(
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
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12),
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
                Row(
                  children: [
                    RaisedButton(
                      child: Text('rcvr'),
                      onPressed: () => {
                        Navigator.pushNamed(
                          context,
                          "QRScanPage",
                          // arguments: jsonEncode({
                          //   "product": "Juice",
                          //   "quantity": "1000",
                          //   "sender":
                          //       "ad1b8786c138c0fbb3a68a3456b168f21cc81c6e16515db80172d500f6b6941a",
                          //   "product_id": "1"
                          // }),
                        ),
                      },
                    ),
                    RaisedButton(
                      child: Text('sndr'),
                      onPressed: () => {Navigator.pushNamed(context, 'ProductPage')},
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double _xScaling = size.width / 414;
    final double _yScaling = size.height / 390;
    path.lineTo(544 * _xScaling, 145.848 * _yScaling);
    path.cubicTo(
      544 * _xScaling,
      243.139 * _yScaling,
      426.574 * _xScaling,
      402.21 * _yScaling,
      242.836 * _xScaling,
      351.132 * _yScaling,
    );
    path.cubicTo(
      135.564 * _xScaling,
      321.311 * _yScaling,
      103.997 * _xScaling,
      257.246 * _yScaling,
      -137.763 * _xScaling,
      165.793 * _yScaling,
    );
    path.cubicTo(
      -228.251 * _xScaling,
      83.582 * _yScaling,
      19.6796 * _xScaling,
      -111 * _yScaling,
      206.227 * _xScaling,
      -111 * _yScaling,
    );
    path.cubicTo(
      392.774 * _xScaling,
      -111 * _yScaling,
      544 * _xScaling,
      23.748 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
    );
    path.cubicTo(
      544 * _xScaling,
      145.848 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
      544 * _xScaling,
      145.848 * _yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
