import 'package:cloud_firestore/cloud_firestore.dart';

class BookPageResult {
  final List<Map<String, dynamic>> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  BookPageResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });
}

class BookRepository {
  BookRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Query<Map<String, dynamic>> _baseQuery() {
    return _firestore
        .collection('book')
        .where('nome', isNull: false)
        .orderBy('nome');
  }

  Future<BookPageResult> fetchBooksPage({
    int pageSize = 20,
    String? genre,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _baseQuery();

    if (genre != null && genre.isNotEmpty) {
      query = query.where('genero', isEqualTo: genre);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(pageSize + 1).get();
    final docs = snapshot.docs;
    final hasMore = docs.length > pageSize;
    final pageDocs = hasMore ? docs.take(pageSize).toList() : docs;

    final items = pageDocs
        .where((doc) => doc.data()['isDeleted'].toString() != 'true')
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();

    return BookPageResult(
      items: items,
      lastDocument: pageDocs.isNotEmpty ? pageDocs.last : startAfter,
      hasMore: hasMore,
    );
  }
}
