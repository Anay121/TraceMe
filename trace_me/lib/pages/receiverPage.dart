import 'package:flutter/material.dart';
import 'dart:convert';

// ignore: must_be_immutable
class ReceiverPage extends StatefulWidget {
  String qrJson;

  ReceiverPage(args) {
    qrJson = args;
  }

  @override
  _ReceiverPageState createState() => _ReceiverPageState(qrJson);
}

class _ReceiverPageState extends State<ReceiverPage> {
  Map _data;
  final _formKey = GlobalKey<FormState>();
  _ReceiverPageState(args) {
    _data = json.decode(args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Receiver Hub",
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
                        _data['product'],
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(
                        "Quantity: " + _data['quantity'],
                        style: TextStyle(fontSize: 15),
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
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.black,
                            tabs: [
                              Tab(
                                text: "Add props",
                              ),
                              Tab(
                                text: "Sender Info",
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: MediaQuery.of(context).size.width,
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    DataRow(),
                                    ButtonTheme(
                                      minWidth: 100,
                                      child: RaisedButton(
                                        onPressed: () {
                                          _formKey.currentState.validate();
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(fontSize: 17, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Text("Senders stufff"),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class DataRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            // flex: 3,
            // fit: FlexFit.loose,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
          Flexible(
            // flex: 3,
            // fit: FlexFit.loose,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text(
//                 "Receiver Hub",
//                 style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12),
//               ),
//               Container(
//                 alignment: Alignment.center,
//                 color: Colors.blue[100],
//                 height: MediaQuery.of(context).size.height / 8,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Text(
//                       _data['product'],
//                       style: TextStyle(fontSize: 25),
//                     ),
//                     Text(
//                       "Quantity: " + _data['quantity'],
//                       style: TextStyle(fontSize: 15),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height / 2,
//                 // width: MediaQuery.of(context).size.width,
//                 child: DefaultTabController(
//                   length: 2,
//                   child: Column(
//                     children: [
//                       Container(
//                         child: TabBar(
//                           labelColor: Colors.blue,
//                           unselectedLabelColor: Colors.black,
//                           tabs: [
//                             Tab(
//                               text: "Add props",
//                             ),
//                             Tab(
//                               text: "Sender Info",
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         height: MediaQuery.of(context).size.height / 2.5,
//                         width: MediaQuery.of(context).size.width,
//                         child: TabBarView(
//                           children: [
//                             Column(
//                               children: [
//                                 SingleChildScrollView(
//                                   padding: EdgeInsets.symmetric(vertical: 10),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       DataRow(),
//                                       // DataRow(),
//                                       // DataRow(),
//                                       // DataRow(),
//                                       // DataRow(),
//                                       // DataRow(),
//                                       ButtonTheme(
//                                         minWidth: 100,
//                                         child: RaisedButton(
//                                           onPressed: () {
//                                             // setState(() {
//                                             //   _doGenerateQR = false;
//                                             // });
//                                           },
//                                           child: Text(
//                                             "Confirm",
//                                             style: TextStyle(fontSize: 17, color: Colors.white),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               child: Text("Senders stufff"),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
