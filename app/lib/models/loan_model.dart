class LoanModel {
  String bookBorrowed;
  String loanDate;
  int renovations;
  String? returnDate;
  String status;
  String? userAllowing;
  String userLoan;

  LoanModel({
    required this.bookBorrowed,
    required this.loanDate,
    required this.renovations,
    required this.returnDate,
    required this.status,
    required this.userAllowing,
    required this.userLoan,
  });

  LoanModel copyWith({
    String? bookBorrowed,
    String? loanDate,
    int? renovations,
    String? returnDate,
    String? status,
    String? userAllowing,
    String? userLoan,
  }) {
    return LoanModel(
      bookBorrowed: bookBorrowed ?? this.bookBorrowed,
      loanDate: loanDate ?? this.loanDate,
      renovations: renovations ?? this.renovations,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      userAllowing: userAllowing ?? this.userAllowing,
      userLoan: userLoan ?? this.userLoan,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bookBorrowed': bookBorrowed,
      'loanDate': loanDate,
      'renovations': renovations,
      'returnDate': returnDate,
      'status': status,
      'userAllowing': userAllowing,
      'userLoan': userLoan,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      bookBorrowed: map['bookBorrowed']?.toString() ?? '',
      loanDate: map['loanDate']?.toString() ?? '',
      renovations: map['renovations'] is int
          ? map['renovations'] as int
          : int.tryParse(map['renovations']?.toString() ?? '') ?? 0,
      returnDate: map['returnDate']?.toString(),
      status: map['status']?.toString() ?? '',
      userAllowing: map['userAllowing']?.toString(),
      userLoan: map['userLoan']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'LoanModel(bookBorrowed: $bookBorrowed, loanDate: $loanDate, renovations: $renovations, returnDate: $returnDate, status: $status, userAllowing: $userAllowing, userLoan: $userLoan)';
  }
}
