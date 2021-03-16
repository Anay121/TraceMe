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
      body: json.encode({'product_id': args[0], 'transfer': 'false'}),
    );
  }

  Future<dynamic> getTransactions() {
    return http.get(Helper.url + '/get_transactions/' + args[0].toString());
  }

  @override
  Widget build(BuildContext context) {
    TextStyle keyStyle = TextStyle(
        color: Color.fromRGBO(255, 91, 53, 1), fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
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
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12),
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
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        Map map = Map();
                                        map['KEY'] = 'VALUE';
                                        map.addAll(json.decode(snapshot.data.body));
                                        print("MAPP TYPE  ${map.runtimeType}");
                                        return SingleChildScrollView(
                                            child: Column(children: [
                                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                new Text("MANUFACTURER", style: keyStyle),
                                                new Text("${args[2][1]}", style: valueStyle)
                                              ]),
                                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                new Text("OWNER", style: keyStyle),
                                                new Text("${args[3][1]}", style: valueStyle)
                                              ]),
                                          SizedBox(height: MediaQuery.of(context).size.height / 40),
                                          Table(
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  width: 1,
                                                  color: Color.fromRGBO(255, 91, 53, 1),
                                                  style: BorderStyle.solid),
                                            ),
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment.middle,
                                            children: map.entries.map((entry) {
                                              return TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        child: Text(
                                                          entry.key.toString(),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(fontSize: 15),
                                                        )),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      child: Text(
                                                        entry.value.toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 15),
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
                                    child: FutureBuilder(
                                        future: getTransactions(),
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            var d = json.decode(snapshot.data.body);
                                            List<Map> data = List<Map>();
                                            for (var i = 0; i < d.length; i++) {
                                              Map map = Map();
                                              map['KEY'] = 'VALUE';
                                              print(d[i].runtimeType);
                                              map.addAll((d[i]));
                                              map["Sender"] = d[i]["Sender"][1];
                                              map["Receiver"] = d[i]["Receiver"][1];
                                              print("map i is : $map");
                                              data.add(map);
                                            }
                                            print(data);
                                            return SingleChildScrollView(
                                                child: Column(children: [
                                              for (var i = 0; i < data.length; i++)
                                                Column(children: [
                                                  SizedBox(
                                                      height:
                                                          MediaQuery.of(context).size.height / 40),
                                                  Text("Transaction ${(i + 1)}",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(255, 91, 53, 1),
                                                          fontWeight: FontWeight.bold)),
                                                  Table(
                                                    border: TableBorder(
                                                      horizontalInside: BorderSide(
                                                          width: 1,
                                                          color: Color.fromRGBO(255, 91, 53, 1),
                                                          style: BorderStyle.solid),
                                                    ),
                                                    defaultVerticalAlignment:
                                                        TableCellVerticalAlignment.middle,
                                                    children: data[i].entries.map((entry) {
                                                      return TableRow(
                                                        children: [
                                                          TableCell(
                                                            child: Container(
                                                                padding: EdgeInsets.all(10),
                                                                child: Text(
                                                                  entry.key.toString(),
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(fontSize: 15),
                                                                )),
                                                          ),
                                                          TableCell(
                                                            child: Container(
                                                              child: Text(
                                                                entry.value.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(fontSize: 10),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                  Container(
                                                    height: 3,
                                                    width: MediaQuery.of(context).size.width,
                                                    color: Color(0xFFE98D39),
                                                  )
                                                ])
                                            ]));
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        })),
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
