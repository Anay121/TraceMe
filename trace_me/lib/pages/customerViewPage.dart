import 'package:flutter/material.dart';
import 'package:trace_me/helper.dart';

String alertBoxMsg = "";

class CustomerViewPage extends StatefulWidget {
  @override
  _CustomerViewPageState createState() => _CustomerViewPageState();
}

class _CustomerViewPageState extends State<CustomerViewPage> {
  final codeController = TextEditingController();

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
                title: Text('Search top stakeholders'),
                trailing: Icon(Icons.people_rounded),
                onTap: () => Navigator.popAndPushNamed(context, 'RankingPage'),
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
        body: SingleChildScrollView(
          child: Column(children: [
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
                    height: MediaQuery.of(context).size.height,
                    width: 400,
                    child: Column(children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 10,
                        child: ElevatedButton(
                          onPressed: () => {
                            Navigator.pushNamed(context, 'QRScanPage'),
                          },
                          child: Text(
                            'Scan a Product',
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(darker),
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ))),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      Row(children: <Widget>[
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            endIndent: 10,
                          ),
                        ),
                        Text("OR"),
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            indent: 10,
                          ),
                        ),
                      ]),
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Enter product id...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            hintStyle: new TextStyle(color: Colors.grey[800]),
                          ),
                          controller: codeController),
                      TextButton(
                        onPressed: () => {
                          Navigator.popAndPushNamed(
                            context,
                            'TraceProductPage',
                            arguments: int.parse(codeController.text),
                          )
                        },
                        child: Text("OK"),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(darker),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                      ),
                    ]))),
          ]),
        ));
  }
}
