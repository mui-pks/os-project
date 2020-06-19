import 'package:cloud_firestore/cloud_firestore.dart';

/// Used to named import because Transaction class exists in firestore too.
/// This caused ambigous_import_error
import '../model/transaction.dart' as myTransaction;

/// The data is stored in list(array) containing JSON objects
/// For ex.
/// ```
/// "transactions":[
/// {
/// "amount": "200.0",
/// "date":2020-06-16T00:00:00.000,
/// "id":2020-06-19 16:49:19.297581
/// "title":"expense 1"
/// },
/// {
/// "amount": "100.0",
/// "date":2020-06-18T00:00:00.000,
/// "id":2020-06-19 16:50:10.88082
/// "title":"expense 2"
/// },
/// ]
/// ```
/// Amount is stored as a string and when parsed, double.parse() is used to convert
/// the string back to double after retrieving
///
/// Date is also stored a string in the ISO8601 format since it can be directly parsed
/// by the DateTime class using the DateTime.parse() function

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  static final CollectionReference moneycollection =
      Firestore.instance.collection('Expenses');

  Future<List> get allTransactions async {
    List transactionMap;
    try {
      await moneycollection.document(uid).get().then((documentSnapshot) =>
          transactionMap = documentSnapshot.data["transactions"]);
    } catch (e) {
      transactionMap = [
        {"error": e.toString()}
      ];
    }
    return transactionMap;
  }

  Future<List<myTransaction.Transaction>> get allTransactionAsObjects async {
    List transactionMap = await allTransactions;
    List<myTransaction.Transaction> transactionObjectMap = [];

    for (var transaction in transactionMap) {
      var title = transaction["title"];
      var amount = transaction["amount"];
      var date = transaction["date"];
      var dateTimeObj = DateTime.parse(date);
      var id = transaction["id"];
      var newTransactionObject = myTransaction.Transaction(
          id: id, amount: amount, title: title, date: dateTimeObj);
      transactionObjectMap.add(newTransactionObject);
    }

    return transactionObjectMap;
  }

  Stream get allTransactionsAsStream {
    return moneycollection.document(uid).snapshots();
  }

  Future addTransaction(
      {String title, String amount, DateTime chosenDate, String id}) async {
    List transactionMap = await allTransactions;
    if (transactionMap != null) {
      transactionMap.add({
        "title": title,
        "amount": amount,
        "date": chosenDate.toIso8601String(),
        "id": id
      });
    } else {
      transactionMap = [
        {
          "title": title,
          "amount": amount,
          "date": chosenDate.toIso8601String(),
          "id": id
        }
      ];
    }
    return await moneycollection
        .document(uid)
        .setData({"transactions": transactionMap});
  }

  Future deleteTransaction({String id}) async {
    List transactionMap = await allTransactions;
    List newTransactionMap = [];
    for (var transaction in transactionMap) {
      if (transaction["id"] == id) {
        continue;
      } else {
        newTransactionMap.add(transaction);
      }
    }
    return await moneycollection
        .document(uid)
        .setData({"transactions": newTransactionMap});
  }

  Future registerUser() async {
    return await moneycollection.document(uid).setData({"transactions": []});
  }
}
