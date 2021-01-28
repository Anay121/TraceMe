import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

var args = List<int>();

class SplitProductPage extends StatefulWidget {
  SplitProductPage(List<int> arg) {
    args = arg;
    // print("here");
    print(args);
  }

  @override
  _SplitProductState createState() => _SplitProductState();
}

class _SplitProductState extends State<SplitProductPage> {
  final q1Controller = TextEditingController();
  final q2Controller = TextEditingController();
  bool _validateError = false;

  Future<dynamic> splitProduct(List quants) async {
    Future<dynamic> value;
    // Session().getter('userid').then((val) {
    //   return http.get(Helper.url + '/get_products/' + val);
    // });
    String val = await Session().getter('userid');
    return http.post(Helper.url + '/split',
        body: json.encode(
            {"product_id": args[0], "quantities": quants, "user_id": val}));
  }
  // Future<dynamic> splitProduct(int prodId, List quants, String userId) {
  //   return http.post(Helper.url + '/split',
  //       body: json.encode(
  //           {"product_id": prodId, "quantities": quants, "user_id": userId}));
  // }

  @override
  void initState() {
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
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
            child: Column(
              children: [
                Text(
                  'SPLIT PRODUCT',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: TextFormField(
                          decoration: InputDecoration(labelText: 'QUANTITY'),
                          controller: q1Controller),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      color: Colors.grey,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      color: Colors.grey,
                      onPressed: () {},
                    ),
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: TextFormField(
                            decoration: InputDecoration(labelText: 'QUANTITY'),
                            controller: q2Controller),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        color: Colors.grey,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        color: Colors.grey,
                        onPressed: () {},
                      ),
                    ]),
              ],
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              onPressed: () => {
                if (int.parse(q1Controller.text) +
                        int.parse(q2Controller.text) ==
                    args[1])
                  {
                    splitProduct([q1Controller.text, q2Controller.text])
                        .then((val) {
                      // check validation
                      print(val.statusCode);
                      if (val.statusCode == '401') {
                        setState(() {
                          _validateError = true;
                        });
                      }
                      // redirect with params
                      else {
                        Navigator.pushNamed(context, 'DisplayProductsPage');
                      }
                    }),
                  }
                else if (int.parse(q1Controller.text) +
                        int.parse(q2Controller.text) <
                    args[1])
                  {
                    splitProduct([
                      q1Controller.text,
                      q2Controller.text,
                      (args[1] -
                              (int.parse(q1Controller.text) +
                                  int.parse(q2Controller.text)))
                          .toString()
                    ]).then((val) {
                      // check validation
                      print(val.statusCode);
                      if (val.statusCode == '401') {
                        setState(() {
                          _validateError = true;
                        });
                      }
                      // redirect with params
                      else {
                        Navigator.pushNamed(context, 'DisplayProductsPage');
                      }
                    }),
                  }
                else
                  {
                    showAlertDialog(context),
                  }
              },
              child: Text("SPLIT PRODUCT"),
            ),
          ),
        ),
      ]),

      // bottomNavigationBar: BottomNavigationBar(
      //     currentIndex: 0, // this will be set when a new tab is tapped
      //     items: [
      //       BottomNavigationBarItem(
      //         icon: new Icon(Icons.add),
      //         label: 'Add Product',
      //       ),
      //     ]),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Error!"),
    content: Text("Quantities specified are greater! Please check once again."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
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
