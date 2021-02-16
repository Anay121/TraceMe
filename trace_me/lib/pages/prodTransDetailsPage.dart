import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trace_me/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

List<dynamic> args;

class ProdTransDetailsPage extends StatefulWidget {
  ProdTransDetailsPage(List arg) {
    args = arg;
    print("args");
    print(args[2]);
  }

  @override
  _ProdTransDetailsPageState createState() => _ProdTransDetailsPageState();
}

class _ProdTransDetailsPageState extends State<ProdTransDetailsPage> {
  Future<dynamic> getProps() {
    return http.post(
      Helper.url + '/getTransactionProps',
      body: json.encode({'product_id': args[0], 'transfer': 'true'}),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle keyStyle = TextStyle(
        color: Color.fromRGBO(255, 91, 53, 1),
        fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle =
        TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
    return Scaffold(
      body: Center(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height / 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Product Information",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 12),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(255, 91, 53, 1),
                  height: MediaQuery.of(context).size.height / 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        args[1],
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  // width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Container(
                            child: TabBar(
                              labelColor: Color.fromRGBO(255, 91, 53, 1),
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(
                                  text: "Product Details",
                                ),
                                Tab(
                                  text: "Transaction Details",
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: TabBarView(
                              children: [
                                Container(
                                  child: FutureBuilder(
                                    future: getProps(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        Map map = Map();
                                        map['KEY'] = 'VALUE';
                                        map.addAll(
                                            json.decode(snapshot.data.body));
                                        return SingleChildScrollView(
                                            child: Column(children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                new Text("MANUFACTURER",
                                                    style: keyStyle),
                                                new Text("${args[2][1]}",
                                                    style: valueStyle)
                                              ]),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                new Text("OWNER",
                                                    style: keyStyle),
                                                new Text("${args[3][1]}",
                                                    style: valueStyle)
                                              ]),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40),
                                          Table(
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  width: 1,
                                                  color: Color.fromRGBO(
                                                      255, 91, 53, 1),
                                                  style: BorderStyle.solid),
                                            ),
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            children: map.entries.map((entry) {
                                              return TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Text(
                                                          entry.key.toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        )),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      child: Text(
                                                        entry.value.toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ]));
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  child: Text("Transaction details"),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
