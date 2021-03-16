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
        color: darker, fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle =
        TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
    return Scaffold(
      drawer: MenuDrawer(),
      body: Column(children: [
        ClipPath(
          clipper: BezierClipper(),
          child: Container(
            color: orange,
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
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                FutureBuilder(
                    future: getParticipant(), //of userid 1
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map data = json.decode(snapshot.data.body);
                        print(data);
                        return Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("FULL NAME", style: keyStyle),
                                Text("${data["fullname"]}", style: valueStyle)
                              ]),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 40),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ROLE", style: keyStyle),
                                Text("${data["role"]}", style: valueStyle)
                              ]),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 40),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("RATING", style: keyStyle),
                                // new Text("${data["rating"]}", style: valueStyle)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    print(double.parse(data["rating"].substring(
                                        0, data["rating"].indexOf('#'))));
                                    return index <
                                            double.parse(data["rating"]
                                                .substring(
                                                    0,
                                                    data["rating"]
                                                        .indexOf('#')))
                                        ? Icon(Icons.star,
                                            color: Colors.yellow[700])
                                        : Icon(Icons.star_border);
                                  }),
                                ),
                              ]),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 40),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("RATED BY", style: keyStyle),
                                Text(
                                    data["rating"].substring(
                                        data["rating"].indexOf('#') + 1),
                                    style: valueStyle)
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
