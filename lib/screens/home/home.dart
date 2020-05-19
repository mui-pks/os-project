import 'package:flutter/material.dart';

//my own imports
import 'package:flutter_complete_app/services/auth.dart';
import 'package:flutter_complete_app/screens/home/components.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    
//    this code is going to give us the width of the screen
    final mediaQuerydata = MediaQuery.of(context);
    final size = mediaQuerydata.size.width;

    return Scaffold(
      appBar: AppBar(
        title: new Text("OS Personal Budget App"),
        backgroundColor: Colors.blue,
        centerTitle: false,
        elevation: 1.0,
        actions: <Widget>[
          FlatButton.icon(onPressed: () async{await _auth.signOut();}, icon: Icon(Icons.person), label: Text('logout'))
        ],
        
      ),
      

      body: new Stack(
        children: <Widget>[
          Center(
            child: ListTile(
              title: new Icon(Icons.account_balance_wallet, size: 64.0, color: Colors.grey,),
              subtitle: new Padding(padding: EdgeInsets.only(left: size / 2.9),
                  child: new Text("Spend Wisely!", style: TextStyle(fontSize: 16.0),)),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){showDialog(context: context,
      builder:(context)=>new AlertDialog(
        title:new Text("Add"),
        content:new Container(height:200.0,child:AlertComponents(),
        ),
        ));},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,),

      


      bottomNavigationBar: new Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: new Text("Balance:"),
                subtitle: new Text(
                    "\$720",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: new Text("Expense:"),
                subtitle: new Text(
                  "\$230",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Expanded(
                child: new IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {})),
          ],
        ),
      ),
    );
  }
}
