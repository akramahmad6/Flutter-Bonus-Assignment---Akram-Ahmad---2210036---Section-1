import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';

class CoffeeStateManagement with ChangeNotifier {
  CoffeeStateManagement({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final _localRecordsController =
      StreamController<List<CoffeeRecordsModel>>.broadcast();
  final List<CoffeeRecordsModel> _localRecords = [];
  static const _collectionName = 'coffee_records';

  CollectionReference<Map<String, dynamic>> get _records =>
      (_firestore ?? FirebaseFirestore.instance).collection(_collectionName);

  /// Provides real-time updates whenever the Firestore collection changes.
  Stream<List<CoffeeRecordsModel>> get coffeeRecordsStream {
    if (kIsWeb) {
      return _localRecordsStream();
    }
    return _records.orderBy('date', descending: true).snapshots().map(
      (snapshot) {
        // Debug: print snapshot counts when in debug mode so running logs
        // show real-time updates during demo.
        if (!kReleaseMode) {
          // ignore: avoid_print
          print('Firestore snapshot: ${snapshot.docs.length} docs');
        }
        return snapshot.docs.map(CoffeeRecordsModel.fromFirestore).toList();
      },
    );
  }

  Stream<List<CoffeeRecordsModel>> _localRecordsStream() async* {
    yield List<CoffeeRecordsModel>.unmodifiable(_localRecords);
    yield* _localRecordsController.stream;
  }

  Future<void> addCoffeeRecord(CoffeeRecordsModel coffeeRecord) async {
    if (kIsWeb) {
      _localRecords.add(_withLocalId(coffeeRecord));
      _publishLocalRecords();
      return;
    }
    await _records.add(coffeeRecord.toJson());
  }

  Future<void> updateCoffeeRecord(CoffeeRecordsModel coffeeRecord) async {
    if (kIsWeb) {
      final index = _localRecords.indexWhere(
        (record) => record.documentId == coffeeRecord.documentId,
      );
      if (index == -1) throw ArgumentError('Coffee record was not found.');
      _localRecords[index] = coffeeRecord;
      _publishLocalRecords();
      return;
    }
    final id = coffeeRecord.documentId;
    if (id == null) {
      throw ArgumentError(
        'A Firestore document id is required to update a record.',
      );
    }
    await _records.doc(id).update(coffeeRecord.toJson());
  }

  Future<void> deleteCoffeeRecord(String documentId) async {
    if (kIsWeb) {
      _localRecords.removeWhere((record) => record.documentId == documentId);
      _publishLocalRecords();
      return;
    }
    await _records.doc(documentId).delete();
  }

  CoffeeRecordsModel _withLocalId(CoffeeRecordsModel record) =>
      CoffeeRecordsModel(
        documentId: record.documentId ?? record.id.toString(),
        id: record.id,
        title: record.title,
        des: record.des,
        amount: record.amount,
        date: record.date,
      );

  void _publishLocalRecords() {
    _localRecords.sort((a, b) => b.date.compareTo(a.date));
    _localRecordsController.add(List.unmodifiable(_localRecords));
  }

  @override
  void dispose() {
    _localRecordsController.close();
    super.dispose();
  }
}
