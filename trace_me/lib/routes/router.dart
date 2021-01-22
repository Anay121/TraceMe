import 'package:flutter/material.dart';
import 'package:trace_me/pages/homePage.dart';
import 'package:trace_me/pages/login.dart';
import 'package:trace_me/pages/mainHomePage.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print(settings.arguments);
  print(settings.name);
  final arguments = settings.arguments;
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => MainHomePage());
    case "LoginPage":
      return MaterialPageRoute(builder: (context) => LoginPage());
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
