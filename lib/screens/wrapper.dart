import 'package:flutter/material.dart';
import 'package:flutter_complete_app/model/user.dart';
import 'package:flutter_complete_app/screens/authenticate/authenticate.dart';
import 'package:flutter_complete_app/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);
    //return either home or authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
