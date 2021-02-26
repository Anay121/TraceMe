import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

var args;

class UserInfoPage extends StatefulWidget {
  UserInfoPage(String arg) {
    args = arg;
    print(args);
  }

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfoPage> {
  Future<dynamic> getParticipant() async {
    return http.get(Helper.url + '/get_participant/' + args);
  }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
    TextStyle keyStyle = TextStyle(
        color: Color.fromRGBO(255, 91, 53, 1), fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
    return Scaffold(
      body: Column(children: [
        ClipPath(
          // clipper: BezierClipper(),
          child: Container(
            color: Color.fromRGBO(255, 91, 53, 1),
            height: height,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 30),
          child: Container(
            height: 400,
            width: 400,
            child: Column(
              children: [
                Text(
                  'STAKEHOLDER INFORMATION',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 15),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                FutureBuilder(
                    future: getParticipant(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map data = json.decode(snapshot.data.body);
                        print(data);
                        return Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("FULL NAME", style: keyStyle),
                            Text("${data["fullname"]}", style: valueStyle)
                          ]),
                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("ROLE", style: keyStyle),
                            Text("${data["role"]}", style: valueStyle)
                          ]),
                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("RATING", style: keyStyle),
                            // new Text("${data["rating"]}", style: valueStyle)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                print(double.parse(
                                    data["rating"].substring(0, data["rating"].indexOf('#'))));
                                return index <
                                        double.parse(data["rating"]
                                            .substring(0, data["rating"].indexOf('#')))
                                    ? Icon(Icons.star, color: Colors.yellow[700])
                                    : Icon(Icons.star_border);
                              }),
                            ),
                          ]),
                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("RATED BY", style: keyStyle),
                            Text(data["rating"].substring(data["rating"].indexOf('#') + 1),
                                style: keyStyle)
                          ]),
                        ]);

                        // print("here");
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class BezierClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double _xScaling = size.width / 550;
    final double _yScaling = size.height / 250;
    path.lineTo(478.296 * _xScaling, 161.15699999999998 * _yScaling);
    path.cubicTo(
      407.956 * _xScaling,
      149.3021 * _yScaling,
      302.774 * _xScaling,
      107.2207 * _yScaling,
      214 * _xScaling,
      131 * _yScaling,
    );
    path.cubicTo(
      67 * _xScaling,
      170.376 * _yScaling,
      16.203999999999994 * _xScaling,
      86.2874 * _yScaling,
      16.203999999999994 * _xScaling,
      41 * _yScaling,
    );
    path.cubicTo(
      16.203999999999994 * _xScaling,
      -38.5 * _yScaling,
      325.21000000000004 * _xScaling,
      -56.843 * _yScaling,
      460.796 * _xScaling,
      -56.843 * _yScaling,
    );
    path.cubicTo(
      596.3820000000001 * _xScaling,
      -56.843 * _yScaling,
      554.5 * _xScaling,
      174 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
    );
    path.cubicTo(
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
      478.296 * _xScaling,
      161.15699999999998 * _yScaling,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
