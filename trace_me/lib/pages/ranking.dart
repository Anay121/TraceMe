import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

String alertBoxMsg = "";

class RankingPage extends StatefulWidget {
  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<RankingPage> {
  String _roleValue;
  List roleList = [];

  Future<dynamic> getRoleParticipants() async {
    return http.get(Helper.url + '/get_all_participants/' + _roleValue);
  }

  callFunction() async {
    var data = await getRoleParticipants();
    print("heree");
    print(json.decode(data.body)["participants"].runtimeType);
    List parts = json.decode(data.body)["participants"];
    for (var k in parts) {
      setState(() {
        roleList.add(Card(
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  print("tapping");
                  print('Go to sender page ${k[0]}');
                  Navigator.pushNamed(context, 'UserInfoPage', arguments: k[0]);
                },
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 5,
                      color: Color(0xFFE98D39),
                    ),
                    Container(
                      child: Column(children: [
                        Container(
                            // width: MediaQuery.of(context).size.width * 0.6,
                            margin: EdgeInsets.all(10),
                            child: Text(k[1])),
                        Container(
                            // width: MediaQuery.of(context).size.width * 0.6,
                            margin: EdgeInsets.all(10),
                            child: Text("Rating - ${k[2]}"))
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
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
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
          // child: FractionallySizedBox(
          //   widthFactor: 1,
          //   heightFactor: 0.7,
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).size.height * 0.24,
            width: 400,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'View Ranks:',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 15,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 20),
                    DropdownButton(
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
                          print(_roleValue);
                          roleList.clear();
                          callFunction();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 50),
                Expanded(
                    child: new ListView.builder(
                        itemCount: roleList.length,
                        itemBuilder: (ctxt, index) {
                          return new ListTile(
                            title: roleList[index],
                          );
                        }))
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [],
                // ),
                // FutureBuilder(
                //     // future: getProducts(), //of userid 1
                //     builder: (context, snapshot) {
                //   if (snapshot.hasData) {
                //     Map data = json.decode(snapshot.data.body);
                //     // print(data["product_dict"]);
                //     // print("here");

                //   } else {
                //     return CircularProgressIndicator();
                //   }
                // }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
