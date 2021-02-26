import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trace_me/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

int args;

class ProductDetailsPage extends StatefulWidget {
  final String args;
  ProductDetailsPage(this.args);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState(args);
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _prodName;
  String _quantity;
  String _prodId;
  String _owner;
  bool _doGenerateQR = false;
  bool flag = true;

  _ProductDetailsPageState(String args) {
    Map values = json.decode(args);
    _prodName = values['product_name'];
    _quantity = values['qty'];
    _prodId = values['product_id'];
    _owner = values['owner'];
  }

  Future<dynamic> addTransaction() {
    return http.post(Helper.url + '/makeTransaction',
        body: json.encode({
          'username': _owner,
          'product_id': _prodId,
        }));
  }

  Future<dynamic> getProps() {
    return http.post(
      Helper.url + '/getTransactionProps',
      body: json.encode({'product_id': _prodId, 'transfer': 'false'}),
    );
  }

  Future<dynamic> deleteTransaction() {
    if (flag) {
      flag = !flag;
      return Future<String>.value('This is a string');
      // return Future.delayed(Duration.zero);
    } else {
      return http.post(Helper.url + '/removeTransaction',
          body: json.encode({
            'username': _owner,
            'product_id': _prodId,
          }));
    }
  }

  Future<dynamic> getStatus() async {
    return http.post(Helper.url + '/transactionInfo',
        body: json.encode({
          'username': _owner,
          'product_id': _prodId,
        }));
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.blue[100],
                  height: MediaQuery.of(context).size.height / 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        _prodName,
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(
                        "Quantity: " + _quantity,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  // width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          Container(
                            child: TabBar(
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(
                                  text: "Details",
                                ),
                                Tab(
                                  text: "QR Code",
                                ),
                                Tab(
                                  text: "Transfer",
                                )
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
                                        print(map);
                                        return SingleChildScrollView(
                                          child: Table(
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  width: 1,
                                                  color: Colors.blue,
                                                  style: BorderStyle.solid),
                                            ),
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment.middle,
                                            children: Map.fromEntries(map.entries.expand((e) => [
                                                  if (e.key != 'transfer') MapEntry(e.key, e.value)
                                                ])).entries.map((entry) {
                                              // if (entry.key != 'transfer') {
                                              return TableRow(
                                                children: [
                                                  TableCell(
                                                    child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        child: Text(
                                                          entry.key.toString(),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(fontSize: 20),
                                                        )),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      child: Text(
                                                        entry.value.toString(),
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                              // }
                                            }).toList(),
                                          ),
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  child: QrImage(
                                    data: json.encode({
                                      "type": "display",
                                      "product_id": _prodId,
                                    }),
                                    version: QrVersions.auto,
                                    size: MediaQuery.of(context).size.width / 2.5,
                                  ),
                                ),
                                _doGenerateQR
                                    ? FutureBuilder(
                                        future: addTransaction(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  QrImage(
                                                    data: json.encode({
                                                      "type": "transfer",
                                                      "product": _prodName,
                                                      "quantity": _quantity,
                                                      "sender": _owner,
                                                      "product_id": _prodId,
                                                    }),
                                                    version: QrVersions.auto,
                                                    size: MediaQuery.of(context).size.width / 2.5,
                                                  ),
                                                  ButtonTheme(
                                                    minWidth: 100,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _doGenerateQR = false;
                                                        });
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            fontSize: 17, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  ButtonTheme(
                                                    minWidth: 100,
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        getStatus().then((value) {
                                                          if (json.decode(value.body)['status'] ==
                                                                  0 ||
                                                              json.decode(value.body)['status'] ==
                                                                  1) {
                                                            // make toast
                                                            Fluttertoast.showToast(
                                                              msg:
                                                                  "Waiting for Receiver Confirmation",
                                                              toastLength: Toast.LENGTH_LONG,
                                                              gravity: ToastGravity.BOTTOM,
                                                            );
                                                          } else {
                                                            //redirect
                                                            Navigator.pushNamed(
                                                              context,
                                                              'StatusSenderPage',
                                                              arguments: json.encode({
                                                                'status': json
                                                                    .decode(value.body)['status'],
                                                                'productId': _prodId,
                                                                'owner': _owner,
                                                              }),
                                                            );
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        "Check Status",
                                                        style: TextStyle(
                                                            fontSize: 17, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      )
                                    : FutureBuilder(
                                        future: deleteTransaction(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return ButtonTheme(
                                              // minWidth: 100,
                                              // height: 10,
                                              child: RaisedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _doGenerateQR = true;
                                                  });
                                                },
                                                child: Text(
                                                  "Generate a QR",
                                                  style:
                                                      TextStyle(fontSize: 17, color: Colors.white),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      ),
                              ],
                            ),
                          )
                        ],
                      )),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      onPressed: () => {
                        Navigator.pushNamed(context, 'TraceProductPage',
                            arguments: int.parse(_prodId)),
                      },
                      child: Text("DISPLAY TRACE"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
