import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRepository {
  LoanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findLoan({
    required String bookBorrowed,
    required String status,
    String? userLoan,
    dynamic returnDate,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('loan')
        .where('bookBorrowed', isEqualTo: bookBorrowed)
        .where('status', isEqualTo: status);

    if (userLoan != null) {
      query = query.where('userLoan', isEqualTo: userLoan);
    }

    if (returnDate != null) {
      query = query.where('returnDate', isEqualTo: returnDate);
    }

    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first;
  }
}
