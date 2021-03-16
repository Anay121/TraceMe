import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:trace_me/helper.dart';

class StatusReceiver extends StatefulWidget {
  final String args;

  StatusReceiver(this.args);

  @override
  _StatusReceiverState createState() => _StatusReceiverState(args);
}

class _StatusReceiverState extends State<StatusReceiver> {
  String _owner;
  int _statusCode;
  String _productId;
  double _rating;

  _StatusReceiverState(String args) {
    Map val = json.decode(args);
    _owner = val['sender'];
    _statusCode = val['status'];
    _productId = val['product_id'];
    _rating = 3.5;
    if (_statusCode == 4) {
      transact();
    }
  }

  void transact() async {
    String receiver = await Session().getter('userid');
    http.post(
      Helper.url + '/transfer',
      body: json.encode({
        'senderId': _owner,
        'productId': _productId,
        'receiverId': receiver
      }),
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

  Future<dynamic> rate() {
    return http.post(
      Helper.url + '/rate',
      body: json.encode({
        'owner': _owner,
        'rating': _rating,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: _statusCode == 4
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Congratulations! \n\nProduct successfully transferred',
                        style: TextStyle(fontSize: 30, color: darker),
                      ),
                      Text(
                        "Please rate your experience",
                        style: TextStyle(fontSize: 20),
                      ),
                      Column(
                        children: [
                          RatingBar(
                            initialRating: 2.5,
                            direction: Axis.horizontal,
                            itemSize: 50,
                            allowHalfRating: true,
                            itemCount: 5,
                            ratingWidget: RatingWidget(
                              full: Icon(
                                Icons.star,
                                color: Colors.yellow[700],
                              ),
                              half: Icon(
                                Icons.star_half,
                                color: Colors.yellow[700],
                              ),
                              empty: Icon(
                                Icons.star_border,
                                color: Colors.yellow[700],
                              ),
                            ),
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            onRatingUpdate: (rating) {
                              _rating = rating;
                              print(rating);
                            },
                          ),
                          ButtonTheme(
                            minWidth: 100,
                            buttonColor: darker,
                            child: RaisedButton(
                              onPressed: () {
                                rate().then((val) {
                                  Fluttertoast.showToast(
                                    msg:
                                        "Rating Submitted. Redirecting you back to the products page.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                });
                                Future.delayed(Duration(seconds: 2), () => 1)
                                    .then(
                                  (_) => Navigator.pushReplacementNamed(
                                      context, 'DisplayProductsPage'),
                                );
                              },
                              child: Text(
                                "Submit Rating",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
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
                            Navigator.pop(context);
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
