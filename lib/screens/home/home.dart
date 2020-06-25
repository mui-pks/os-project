import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_complete_app/model/transaction.dart';
import 'package:flutter_complete_app/screens/home/chart.dart';
import 'package:flutter_complete_app/screens/home/new_transaction.dart';
import 'package:flutter_complete_app/screens/home/transaction_list.dart';
import 'package:flutter_complete_app/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/transaction.dart';
import '../../model/user.dart';
import '../../services/database.dart';
import '../../services/database.dart';
import '../../services/database.dart';

class Home extends StatefulWidget {
  //String titleInput;
  //String amountInput;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  FirebaseUser user;

  List parseJSONintoTransactionObject(List transactionMap) {
    List<Transaction> transactionObjectMap = [];
    if (transactionMap == null) return [];

    for (var transaction in transactionMap) {
      var title = transaction["title"];
      var amount = double.parse(transaction["amount"]);
      var date = transaction["date"];
      var dateTimeObj = DateTime.parse(date);
      var id = transaction["id"];
      var newTransactionObject =
          Transaction(id: id, amount: amount, title: title, date: dateTimeObj);
      transactionObjectMap.add(newTransactionObject);
    }

    return transactionObjectMap;
  }

  List<Transaction> _recentTransactions(List _usertransactions) {
    return _usertransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txtitle, double txamount, DateTime chosenDate) {
    var id = DateTime.now().toString();
    // final newTx = Transaction(
    //   title: txtitle,
    //   amount: txamount,
    //   date: chosenDate,
    //   id: id,
    // );
    DatabaseService(uid: user.uid).addTransaction(
        title: txtitle,
        amount: txamount.toString(),
        chosenDate: chosenDate,
        id: id);
    // setState(() {
    //   _usertransactions.add(newTx);
    // });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    DatabaseService(uid: user.uid).deleteTransaction(id: id);
  }

  List<Transaction> userTransactionsFromSMS = [];

  Future fetchFromSMS() async {
    SmsQuery query = SmsQuery();
    List<SmsMessage> messageList =
        await query.querySms(kinds: [SmsQueryKind.Inbox]);
    // int count = 0;
    for (var message in messageList) {
      if (RegExp(r"^Acct").hasMatch(message.body)) {
        var date = message.date;
        RegExp filterForAmount =
            RegExp(r" debited with INR( )?((\d)+((,)?(\d)+)?.\d\d)");
        RegExp filterForTitle = RegExp(r" and (\S*)");
        String title;
        try {
          title = filterForTitle.firstMatch(message.body).group(1);
        } catch (e) {
          title = message.address;
        }
        var amountInString = filterForAmount.firstMatch(message.body).group(2);
        var amount =
            NumberFormat.decimalPattern().parse(amountInString).toDouble();
        var id = message.dateSent.toString();
        Transaction newTransactionObject =
            Transaction(amount: amount, title: title, date: date, id: id);
        print(amount);
        userTransactionsFromSMS.add(newTransactionObject);
      }
      // count += 1;
      // if (count == 10) return true;
      // print(count);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Expenses',
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('logout'))
        ],
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
              future: fetchFromSMS(),
              builder: (context, snapshotfromSMS) {
                if (snapshotfromSMS.hasData) {
                  return StreamBuilder(
                      stream: DatabaseService(uid: user.uid)
                          .allTransactionsAsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Transaction> userTransactions = [];
                          List<Transaction> downloadedUserTransactions =
                              parseJSONintoTransactionObject(
                                  snapshot.data["transactions"]);
                          userTransactions
                              .addAll(downloadedUserTransactions.reversed);
                          userTransactions.addAll(userTransactionsFromSMS);
                          return Column(
                            //mainAxisAlignment : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Chart(_recentTransactions(userTransactions)),
                              TransactionList(
                                  userTransactions, _deleteTransaction),
                            ],
                          );
                        } else if (snapshot.hasError) {}
                        return CircularProgressIndicator();
                      });
                } else if (snapshotfromSMS.hasError) {
                  return Text("Error ${snapshotfromSMS.error}");
                }
                return CircularProgressIndicator();
              })),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

/*
StreamBuilder(
              stream: DatabaseService(uid: user.uid).allTransactionsAsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Transaction> downloadedUserTransactions =
                      parseJSONintoTransactionObject(
                          snapshot.data["transactions"]);
                  userTransactions.addAll(downloadedUserTransactions);
                  // print(snapshot.data.toString());
                  // if (snapshot.data != null)
                  //   for (var transaction in snapshot.data["transactions"]) {
                  //     var title = transaction["title"];
                  //     var amount = transaction["amount"];
                  //     var date = transaction["date"];
                  //     var dateTimeObj = DateTime.parse(date);
                  //     var id = transaction["id"];
                  //     var newTransactionObject = Transaction(
                  //         id: id,
                  //         amount: amount,
                  //         title: title,
                  //         date: dateTimeObj);
                  //     userTransactions.add(newTransactionObject);
                  //   }
                  return Column(
                    //mainAxisAlignment : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Chart(_recentTransactions(userTransactions)),
                      TransactionList(userTransactions, _deleteTransaction),
                    ],
                  );
                } else if (snapshot.hasError) {}
                return CircularProgressIndicator();
              })
*/
