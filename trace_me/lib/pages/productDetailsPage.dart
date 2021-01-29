import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trace_me/helper.dart';

class ProductDetailsPage extends StatefulWidget {
  ProductDetailsPage(String args) {
    print(args);
    // String values = json.decode(args);
  }

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _prodName = "Sugarcane";

  String _quantity = "1000";

  String _prodId = "8";

  String _owner =
      "ad1b8786c138c0fbb3a68a3456b168f21cc81c6e16515db80172d500f6b6941a";
  bool _doGenerateQR = false;

  Future<dynamic> addTransaction() {
    return http.post(Helper.url + '/makeTransaction',
        body: json.encode({
          'username': _owner,
          'product_id': _prodId,
        }));
  }

  Future<dynamic> deleteTransaction() {
    return http.post(Helper.url + '/removeTransaction',
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
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 12),
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
                            height: MediaQuery.of(context).size.height / 3,
                            child: TabBarView(
                              children: [
                                Container(
                                  child: Text('Tab details'),
                                ),
                                Container(
                                  child: Text("QR for sharing"),
                                ),
                                _doGenerateQR
                                    ? FutureBuilder(
                                        future: addTransaction(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  QrImage(
                                                    data: json.encode({
                                                      "product": _prodName,
                                                      "quantity": _quantity,
                                                      "sender": _owner,
                                                      "prodid": _prodId,
                                                    }),
                                                    version: QrVersions.auto,
                                                    size: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2,
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
                                                            fontSize: 17,
                                                            color:
                                                                Colors.white),
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
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        },
                                      )
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
