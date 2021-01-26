import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class TransferPage extends StatelessWidget {
  String prodName = "Banana";
  String quantity = "100";
  String owner = "Person1";
  String receiver = "Person2";

  TransferPage(String args) {
    print(args);
    // String values = json.decode(args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height / 20),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Transfer Product",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 10),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.blue[100],
                  height: MediaQuery.of(context).size.height / 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        prodName,
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(
                        "Quantity: " + quantity,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                QrImage(
                  data: json.encode({
                    "product": prodName,
                    "quantity": quantity,
                    "sender": owner,
                    "receiver": receiver
                  }),
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width / 2,
                ),
                ButtonTheme(
                  minWidth: 100,
                  child: RaisedButton(
                    onPressed: () => {Navigator.pop(context)},
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
