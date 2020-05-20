import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseService {
  final CollectionReference moneycollection = Firestore.instance.collection('brew');

}