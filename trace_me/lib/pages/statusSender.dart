import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

// ignore: must_be_immutable
class StatusSender extends StatefulWidget {
  int _statusCode;
  String _productId;
  String _owner;
  StatusSender(args) {
    // print(json.decode(args));
    Map value = json.decode(args);
    _statusCode = value['status'];
    _productId = value['productId'];
    _owner = value['owner'];
  }

  @override
  StatusSenderState createState() =>
      StatusSenderState(_statusCode, _productId, _owner);
}

class StatusSenderState extends State<StatusSender> {
  final int _statusCode;
  final String _productId;
  final String _owner;
  StatusSenderState(this._statusCode, this._productId, this._owner);

  Future<dynamic> getTransactionProps() {
    return http.post(
      Helper.url + '/getTransactionProps',
      body: json.encode({'product_id': _productId, 'transfer': 'true'}),
    );
  }

  Future<dynamic> deleteTransaction() {
    return http.post(
      Helper.url + '/removeTransaction',
      body: json.encode({
        'username': _owner,
        'product_id': _productId,
      }),
    );
  }

  Future<dynamic> rejection() {
    return http.post(
      Helper.url + '/reject',
      body: json.encode(
        {
          'owner': _owner,
          'product_id': _productId,
          'person': 'sender',
        },
      ),
    );
  }

  Future<dynamic> acceptance() {
    return http.post(
      Helper.url + '/ownerAccept',
      body: json.encode(
        {
          'owner': _owner,
          'product_id': _productId,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle keyStyle = TextStyle(
        color: darker, fontSize: MediaQuery.of(context).size.width / 23);
    TextStyle valueStyle =
        TextStyle(fontSize: MediaQuery.of(context).size.width / 23);
    return Scaffold(
      body: Center(
        child: Container(
          child: _statusCode == 2
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'They Have Accepted!',
                      style: TextStyle(fontSize: 30),
                    ),
                    //
                    FutureBuilder(
                      future: getTransactionProps(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map map = Map();
                          map['KEY'] = 'VALUE';
                          map.addAll(json.decode(snapshot.data.body));
                          return SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: SingleChildScrollView(
                              child: Table(
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                      width: 1,
                                      color: darker,
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
                                              entry.key,
                                              textAlign: TextAlign.center,
                                              style: keyStyle,
                                            )),
                                      ),
                                      TableCell(
                                        child: Container(
                                          child: Text(
                                            entry.value,
                                            textAlign: TextAlign.center,
                                            style: valueStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ButtonTheme(
                          child: RaisedButton.icon(
                            onPressed: () {
                              acceptance().then((val) {
                                Fluttertoast.showToast(
                                  msg: "Acceptance Sent!",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                );

                                Navigator.pop(context);
                              });
                            },
                            label: Text(
                              "Accept",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                            icon: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ButtonTheme(
                          buttonColor: Colors.red,
                          child: RaisedButton.icon(
                            onPressed: () {
                              rejection().then((val) {
                                Fluttertoast.showToast(
                                  msg: "Rejection Sent",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                );
                                Navigator.pop(context);
                              });
                            },
                            label: Text(
                              "Reject",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white),
                            ),
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'They Have Rejected!',
                      style: TextStyle(fontSize: 30),
                    ),
                    ButtonTheme(
                      minWidth: 100,
                      child: RaisedButton(
                        onPressed: () {
                          // call api endpoint for removal
                          deleteTransaction().then((val) {
                            // TODO
                            // redirect to display page
                            Navigator.popAndPushNamed(
                                context, 'DisplayProductsPage');
                          });
                        },
                        child: Text(
                          "Abort",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
