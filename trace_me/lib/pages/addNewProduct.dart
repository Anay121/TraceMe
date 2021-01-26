import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNewProductPage extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProductPage> {
  final pnameController = TextEditingController();
  final quantController = TextEditingController();
  final key1Controller = TextEditingController();
  final value1Controller = TextEditingController();

  Future<dynamic> addProduct(String productName, Map prodProps, String userId) {
    return http.post('http://6aba66bd897b.ngrok.io/add_product',
        body: json.encode({
          "product_name": productName,
          "product_properties": prodProps,
          "user_id": userId
        }));
  }

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
                  'ADD PRODUCT',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 15),
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Product Name..'),
                    controller: pnameController),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: TextFormField(
                          decoration: InputDecoration(labelText: 'Quantity..'),
                          controller: quantController),
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
                            decoration: InputDecoration(labelText: 'KEY'),
                            controller: key1Controller),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Flexible(
                        child: TextFormField(
                            decoration: InputDecoration(labelText: 'VALUE'),
                            controller: value1Controller),
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
                print("here"),
                print(pnameController.text),
                addProduct(
                    pnameController.text,
                    {
                      "quantity": quantController.text,
                      key1Controller.text: value1Controller.text
                    },
                    "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8")
              },
              child: Text("ADD PRODUCT"),
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
