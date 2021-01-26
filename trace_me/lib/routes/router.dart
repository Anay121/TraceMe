import 'package:flutter/material.dart';
import 'package:trace_me/pages/login.dart';
import 'package:trace_me/pages/mainHomePage.dart';
import 'package:trace_me/pages/registerPage.dart';
import 'package:trace_me/pages/transferPage.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  print(settings.arguments);
  print(settings.name);
  final arguments = settings.arguments;
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (context) => MainHomePage());
    case "LoginPage":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case 'RegisterPage':
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case 'TransferPage':
      return MaterialPageRoute(builder: (context) => TransferPage(arguments));
    default:
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}
