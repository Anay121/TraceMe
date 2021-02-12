import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
                        'Congratulations! \n\nThe deed is done!',
                        style: TextStyle(fontSize: 30),
                      ),
                      Text(
                        "Please Rate your experience",
                        style: TextStyle(fontSize: 20),
                      ),
                      Column(
                        children: [
                          RatingBar(
                            initialRating: 3,
                            direction: Axis.horizontal,
                            itemSize: 50,
                            allowHalfRating: true,
                            itemCount: 5,
                            ratingWidget: RatingWidget(
                              full: Icon(
                                Icons.star,
                                color: Colors.blue,
                              ),
                              half: Icon(
                                Icons.star_half,
                                color: Colors.blue,
                              ),
                              empty: Icon(
                                Icons.star_border,
                                color: Colors.blue,
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
                            child: RaisedButton(
                              onPressed: () {
                                rate().then((val) {
                                  print('kay done');
                                });
                              },
                              child: Text(
                                "Submit Rating",
                                style: TextStyle(fontSize: 17, color: Colors.white),
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