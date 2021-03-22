import 'package:flutter/material.dart';
import 'package:trace_me/helper.dart';

String alertBoxMsg = "";

class CustomerViewPage extends StatefulWidget {
  @override
  _CustomerViewPageState createState() => _CustomerViewPageState();
}

class _CustomerViewPageState extends State<CustomerViewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.2;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Home'),
              trailing: Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                Navigator.popAndPushNamed(context, 'CustomerViewPage');
              },
            ),
            ListTile(
              title: Text('Exit from Customer View'),
              trailing: Icon(Icons.logout),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (router) => false);
              },
            )
          ],
        ),
      ),
      body: Column(children: [
        ClipPath(
          clipper: BezierClipper(),
          child: Container(
            color: orange,
            height: height,
          ),
        ),
        Text(
          'Welcome Customer!',
          style: TextStyle(
            fontSize: 30,
            color: Colors.brown,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height / 50),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.24,
            width: 400,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 13,
          child: ElevatedButton(
            onPressed: () => {
              Navigator.pushNamed(context, 'QRScanPage'),
            },
            child: Text(
              'Scan a Product',
            ),
          ),
        ),
      ]),
    );
  }
}
