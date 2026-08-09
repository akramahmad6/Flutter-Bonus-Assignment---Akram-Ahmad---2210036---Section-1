import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model generated in the same style as quicktype's Dart output.
class CoffeeRecordsModel {
  final String? documentId;
  final int id;
  final String title;
  final String des;
  double? amount;
  final DateTime date;

  CoffeeRecordsModel({
    this.documentId,
    required this.id,
    required this.title,
    required this.des,
    this.amount,
    required this.date,
  });

  factory CoffeeRecordsModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    final rawDate = json['date'];
    return CoffeeRecordsModel(
      documentId: documentId,
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      des: json['des'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
      date:
          rawDate is Timestamp
              ? rawDate.toDate()
              : rawDate is DateTime
              ? rawDate
              : DateTime.now(),
    );
  }

  factory CoffeeRecordsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return CoffeeRecordsModel.fromJson(
      document.data() ?? {},
      documentId: document.id,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'des': des,
    'amount': amount,
    'date': Timestamp.fromDate(date),
  };
}
