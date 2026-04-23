import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationRepository {
  ReservationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getActiveReservationDoc({
    required String bookCode,
    String? userId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('reservation')
        .where('bookReservedId', isEqualTo: bookCode)
        .where('statusBook', isEqualTo: 'Solicitado');

    if (userId != null) {
      query = query.where('reservationList', arrayContains: userId);
    }

    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first;
  }

  Future<bool> hasActiveReservation({
    required String bookCode,
    String? userId,
  }) async {
    final doc =
        await getActiveReservationDoc(bookCode: bookCode, userId: userId);
    return doc != null;
  }
}
