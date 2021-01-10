import 'package:flutter/material.dart';
import 'package:trace_me/pages/homePage.dart';
import 'package:trace_me/pages/login.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print(settings.arguments);
  print(settings.name);
  final arguments = settings.arguments;
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case "HomePage":
      return MaterialPageRoute(
          builder: (context) => MyHomePage(
                title: 'This is a title',
                arguments: arguments,
              ));
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
