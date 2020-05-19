import 'package:flutter/material.dart';
import 'package:flutter_complete_app/model/user.dart';
import 'package:flutter_complete_app/screens/wrapper.dart';
import 'package:flutter_complete_app/services/auth.dart';
// import 'login_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Flutter App',
        theme: new ThemeData(primarySwatch: Colors.blue),
        home: Wrapper(),
      ),
    );
  }
}
