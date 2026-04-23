import 'dart:convert';

import 'package:app/models/book_model.dart';
import 'package:app/models/loan_model.dart';
import 'package:app/models/log_model.dart';
import 'package:app/models/reservation_model.dart';
import 'package:app/models/validation_model.dart';
import 'package:app/pages/home_final_user.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/register_validation_help.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../configs/app_settings.dart';
import 'firestore_date_utils.dart';
import 'repositories/loan_repository.dart';
import 'repositories/reservation_repository.dart';
import '../pages/home_ca.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final Map<String, String> _bookIdByCodeCache = {};
  final Map<String, String> _registrationByUserIdCache = {};
  final ReservationRepository _reservationRepository = ReservationRepository();
  final LoanRepository _loanRepository = LoanRepository();
  User? usuario;
  // String? nickname;
  late bool isAdm;
  bool isLoading = true;

  List<String> genreList = [
    "Empreendedorismo",
    "Arte e educação",
    "Comics e HQs",
    "Html/xml",
    "Redes e informática",
    "Java",
    "C++",
    "Outras linguagens",
    "Design",
    "Cultura digital",
    "Web",
    "Computação gráfica",
    "Programação de jogos",
    "Mangá",
    "N.D.A"
  ];

  List<String> genreListAcronym = [
    'EMP',
    'AED',
    'CHQ',
    'HML',
    'RDI',
    'JVA',
    'CPP',
    'OLI',
    'DSN',
    'CDG',
    'WEB',
    'CGR',
    'PJG',
    'MGS',
    'NDA'
  ];

  AuthService() {
    _authCheck();
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _firstOrNull(
      Query<Map<String, dynamic>> query) async {
    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.first;
  }

  void _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  void _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  Future<void> registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha é muito fraca!');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Este email já está cadastrado');
      } else {
        AuthException('e.code');
      }
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente');
      } else {
        AuthException('e.code');
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth
        .signOut()
        .then((value) => {
              Fluttertoast.showToast(msg: "Deslogado com sucesso"),
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              ),
            })
        .catchError((error) {
      Fluttertoast.showToast(msg: error!.message);
      return error;
    });
    _getUser();
    removeSaveLogin(context);
  }

  // other wat ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss

  Future<dynamic> getHttpImage(String isbn) async {
    // Colocar no cadastrar Obra e rodar, Fazer lógica para caso não encontre a imagem de colocar outra coisa como imagem

    if (isbn.trim().isEmpty) {
      return 'null';
    }

    var url = 'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn';
    var response = await http.get(Uri.parse(url));
    var json = jsonDecode((response.body));
    return (json['totalItems'] == 0 ||
            json['items'][0]['volumeInfo']['imageLinks'].toString() == 'null')
        ? 'null'
        : json['items'][0]['volumeInfo']['imageLinks']['thumbnail'];
  }

  Future<void> createLog({
    String? time,
    String? userId,
    String? userAdmId,
    String? action,
    String? codBook,
  }) async {
    final now = DateTime.now();
    await firebaseFirestore.collection("log").add(LogModel(
          time: time ?? now.millisecondsSinceEpoch.toString(),
          action: action ?? '',
          userId: userId ?? await getRegistrationById(usuario!.uid),
          userAdmId: userAdmId,
          codBook: codBook,
        ).toMap()
          ..addAll({'timeTs': Timestamp.fromDate(now)}));
  }

  List<dynamic> listBorrowNow(List userLoans) {
    List books = [];
    for (int i = 0; i < userLoans.length; i++) {
      // print(userLoans[i]['loan'].toString());
      if (!(userLoans[i]['loan'] == null)) {
        books.add(userLoans[i]['loan']['codBook']);
      }
    }
    return books;
  }

  bool checkOverdue(List userLoans) {
    if (userLoans.isEmpty) {
      return false;
    }
    for (int i = 0; i < userLoans.length; i++) {
      // print(userLoans[i]['loan'].toString());
      if (!(userLoans[i]['loan'] == null)) {
        if (DateTime.now().isAfter(DateTime.parse(userLoans[i]['loan']
                ['dataDevolucao']
            .toString()
            .substring(0, 10)
            .replaceAll('/', '-')
            .split('-')
            .reversed
            .join()))) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> renewLoan(dynamic book) async {
    final dueDate = FirestoreDateUtils.parse(
      book['dataDisponibilidadeTs'] ?? book['dataDisponibilidade'],
    );

    if (dueDate == null) {
      Fluttertoast.showToast(msg: 'Data de devolução inválida');
      return;
    }

    // mudar numero de renovações nos empréstimos e loans do usuário
    await firebaseFirestore
        .collection('loan')
        .where('bookBorrowed', isEqualTo: await getIdByCod(book["codigo"]))
        .where('returnDate', isEqualTo: book['dataDisponibilidade'])
        .where('status', isEqualTo: 'Em dia')
        .get()
        .then((value) async {
      int numRenovations =
          value.docs.first.data()['renovations'] - 1; // Não pode ser 0
      bool reservated = await hasReservation(book['codigo']);
      if (numRenovations > -1 &&
          (!reservated) &&
          !DateTime.now().isAfter(dueDate)) {
        final newDueDate = DateTime.now().add(const Duration(days: 15));
        await firebaseFirestore
            .collection("loan")
            .doc(value.docs.first.id)
            .update({
          "renovations": numRenovations,
          "returnDate": FirestoreDateUtils.toLegacyString(newDueDate),
          "returnDateTs": Timestamp.fromDate(newDueDate),
        });
        await firebaseFirestore
            .collection('user')
            .where('uId', isEqualTo: usuario!.uid)
            .get()
            .then((value) async {
          List userloans = value.docs.first.data()['userLoans'];
          for (int i = 0; i < userloans.length; i++) {
            if (userloans[i]["loan"]['codBook'] == book["codigo"]) {
              userloans[i]["loan"]['renovacoes'] =
                  userloans[i]["loan"]['renovacoes'] - 1;
              userloans[i]["loan"]['dataDevolucao'] =
                  FirestoreDateUtils.toLegacyString(newDueDate);
            }
          }
          await firebaseFirestore
              .collection("user")
              .doc(usuario!.uid)
              .update({"userLoans": userloans});
        });
        await firebaseFirestore
            .collection("book")
            .doc(await getIdByCod(book['codigo']))
            .update({
          "dataDisponibilidade": FirestoreDateUtils.toLegacyString(newDueDate),
          "dataDisponibilidadeTs": Timestamp.fromDate(newDueDate),
        });
        Fluttertoast.showToast(msg: 'Renovado');
      } else if (await hasReservation(book['codigo'])) {
        Fluttertoast.showToast(msg: 'Obra Reservada, impossível renovar');
      } else if (DateTime.now().isAfter(dueDate)) {
        Fluttertoast.showToast(msg: 'Obra atrasada, Por favor Devolva !');
      } else {
        Fluttertoast.showToast(msg: 'Limite atingido, impossível renovar');
      }
    });
  }

  Future<void> finishReservation(String bookCod) async {
    final reservationDoc = await _firstOrNull(firebaseFirestore
        .collection('reservation')
        .where('bookReservedId', isEqualTo: bookCod)
        .where('statusBook', isEqualTo: 'Solicitado')
        .where('reservationList', arrayContains: usuario!.uid));

    if (reservationDoc == null) {
      return;
    }

    await firebaseFirestore
        .collection('reservation')
        .doc(reservationDoc.id)
        .update({"statusBook": "Encerrada"});
  }

  Future<void> cancelReservation(String bookCod) async {
    final reservationDoc = await _firstOrNull(firebaseFirestore
        .collection('reservation')
        .where('bookReservedId', isEqualTo: bookCod)
        .where('statusBook', isEqualTo: 'Solicitado')
        .where('reservationList', arrayContains: usuario!.uid));

    if (reservationDoc == null) {
      return;
    }

    await firebaseFirestore
        .collection('reservation')
        .doc(reservationDoc.id)
        .update({"statusBook": "Cancelada"});
    await createLog(
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      action: "Cancelamento", // de reserva
      userId: await getRegistrationById(usuario!.uid),
      codBook: bookCod,
    );
  }

  Future<void> doReservation(dynamic book) async {
    // Por enquanto não deixar um tempo limite para pegar depois de reservar
    final now = DateTime.now();
    await firebaseFirestore.collection("reservation").add(ReservationModel(
            bookReservedId: book['codigo'],
            reservationDate: FirestoreDateUtils.toLegacyString(now),
            reservationList: [usuario!.uid],
            statusBook: 'Solicitado' // bookBorrowed: await getIdByCod(bookCod),
            )
        .toMap()
      ..addAll({'reservationDateTs': Timestamp.fromDate(now)}));
    await createLog(
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      action: "Reserva", // de reserva
      userId: await getRegistrationById(usuario!.uid),
      codBook: book['codigo'],
    );
  }

  Future<bool> isReservationUser(String bookCod) async {
    return _reservationRepository.hasActiveReservation(
      bookCode: bookCod,
      userId: usuario!.uid,
    );
  }

  Future<bool> hasReservation(String bookCod) async {
    return _reservationRepository.hasActiveReservation(bookCode: bookCod);
  }

  Future<bool> hasRequest(String bookCod) async {
    // Por enquanto devolver um Bool dizendo se tem o alguma solicitação sua lá
    final requestDoc = await _firstOrNull(firebaseFirestore
        .collection('loan')
        .where('bookBorrowedId', isEqualTo: await getIdByCod(bookCod))
        .where('userLoan', isEqualTo: usuario!.uid)
        .where('status', isEqualTo: 'Solicitado'));

    return requestDoc != null;
  }

  Future<void> sendBorrowRequest(String bookCod) async {
    final now = DateTime.now();
    await firebaseFirestore.collection("loan").add(LoanModel(
          bookBorrowed: await getIdByCod(bookCod),
          loanDate: FirestoreDateUtils.toLegacyString(now) ?? '',
          renovations: 3,
          returnDate: null,
          status: "Solicitado",
          userAllowing: null,
          userLoan: usuario!.uid,
        ).toMap()
          ..addAll(
              {'loanDateTs': Timestamp.fromDate(now), 'returnDateTs': null}));
  }

  Future<void> confirmReturn(Map book) async {
    final bookDoc = await _firstOrNull(
      firebaseFirestore
          .collection('book')
          .where('codigo', isEqualTo: book['codigo']),
    );

    if (bookDoc == null) {
      Fluttertoast.showToast(msg: 'Obra não encontrada');
      return;
    }

    final loanDoc = await _loanRepository.findLoan(
      bookBorrowed: bookDoc.id,
      status: 'Em dia',
      userLoan: usuario!.uid,
    );

    if (loanDoc == null) {
      Fluttertoast.showToast(msg: 'Empréstimo não encontrado');
      return;
    }

    final userRef = firebaseFirestore.collection('user').doc(usuario!.uid);
    final bookRef = firebaseFirestore.collection('book').doc(bookDoc.id);

    await firebaseFirestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentLoans =
          List.from((userSnapshot.data()?['userLoans'] as List?) ?? []);

      final updatedLoans = currentLoans
          .where((item) => item['loan']?['codBook'] != book['codigo'])
          .toList();

      transaction.update(loanDoc.reference, {"status": 'Devolvido'});
      transaction.update(bookRef, {
        "userloan": null,
        "dataDisponibilidade": null,
        "dataDisponibilidadeTs": null,
      });
      transaction.update(userRef, {"userLoans": updatedLoans});
    });

    await createLog(
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      action: "Devolução",
      userAdmId: await getRegistrationById(usuario!.uid),
      userId: await getRegistrationById(usuario!.uid),
      codBook: book['codigo'],
    );

    Fluttertoast.showToast(msg: 'Obra devolvida');
  }

  Future<String> getRegistrationById(String userId) async {
    if (_registrationByUserIdCache.containsKey(userId)) {
      return _registrationByUserIdCache[userId]!;
    }

    final value = await firebaseFirestore.collection('user').doc(userId).get();
    final registration = (value.data()?['matriculaSIAPE'] ?? '') as String;
    _registrationByUserIdCache[userId] = registration;
    return registration;
  }

  Future<String> getCodById(String bookId) async {
    return await firebaseFirestore
        .collection('book')
        .doc(bookId)
        .get()
        .then((value) {
      return value.data()?['codigo'];
    });
  }

  Future<String> getIdByCod(String bookCod) async {
    if (_bookIdByCodeCache.containsKey(bookCod)) {
      return _bookIdByCodeCache[bookCod]!;
    }

    final bookDoc = await _firstOrNull(
      firebaseFirestore.collection('book').where('codigo', isEqualTo: bookCod),
    );

    if (bookDoc == null) {
      throw AuthException('Livro não encontrado para o código informado');
    }

    _bookIdByCodeCache[bookCod] = bookDoc.id;
    return bookDoc.id;
  }

  Future<void> registerLoan(
      String userRegistration, String bookCod, String dataDevolucao) async {
    // Realizar a Efetuação do empréstimo
    // Usuário :
    //    Colocar map loan com infomrações no UserLoans (Com a referencia de quem permitiu esse empréstimo)                       V
    //    Referenciar esse usuário no livro (Id provavelmente) e mudar a data de Disponibilidade
    //    Colocar um novo LoanModel no database
    final borrowerDoc = await _firstOrNull(firebaseFirestore
        .collection('user')
        .where('matriculaSIAPE', isEqualTo: userRegistration));

    if (borrowerDoc == null) {
      Fluttertoast.showToast(msg: 'Matrícula não encontrada');
      return;
    }

    if (borrowerDoc.id == usuario!.uid) {
      Fluttertoast.showToast(msg: 'Não pode emprestar para você mesmo');
      return;
    }

    final now = DateTime.now();
    final dueDate = FirestoreDateUtils.parse(dataDevolucao) ??
        now.add(const Duration(days: 15));
    final dueDateLegacy =
        FirestoreDateUtils.toLegacyString(dueDate) ?? dataDevolucao;
    final bookId = await getIdByCod(bookCod);

    final pendingRequestDoc = await _loanRepository.findLoan(
      bookBorrowed: bookId,
      status: 'Solicitado',
      userLoan: borrowerDoc.id,
    );

    final borrowerRef =
        firebaseFirestore.collection('user').doc(borrowerDoc.id);
    final bookRef = firebaseFirestore.collection('book').doc(bookId);

    await firebaseFirestore.runTransaction((transaction) async {
      final borrowerSnapshot = await transaction.get(borrowerRef);
      final currentLoans =
          List.from((borrowerSnapshot.data()?['userLoans'] as List?) ?? []);

      currentLoans.add({
        'loan': {
          'codBook': bookCod,
          'dataDevolucao': dueDateLegacy,
          'renovacoes': 3,
          'status': 'Em dia',
          'admAllowing': usuario!.uid,
        }
      });

      transaction.update(borrowerRef, {'userLoans': currentLoans});
      transaction.update(bookRef, {
        'userloan': borrowerDoc.id,
        'dataDisponibilidade': dueDateLegacy,
        'dataDisponibilidadeTs': Timestamp.fromDate(dueDate),
      });

      final loanPayload = LoanModel(
        bookBorrowed: bookId,
        loanDate: FirestoreDateUtils.toLegacyString(now) ?? '',
        renovations: 3,
        returnDate: dueDateLegacy,
        status: 'Em dia',
        userAllowing: usuario!.uid,
        userLoan: borrowerDoc.id,
      ).toMap()
        ..addAll({
          'loanDateTs': Timestamp.fromDate(now),
          'returnDateTs': Timestamp.fromDate(dueDate),
        });

      if (pendingRequestDoc == null) {
        final newLoanRef = firebaseFirestore.collection('loan').doc();
        transaction.set(newLoanRef, loanPayload);
      } else {
        transaction.update(pendingRequestDoc.reference, loanPayload);
      }
    });

    Fluttertoast.showToast(msg: 'Empréstimo realizado');
    await createLog(
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      action: "Empréstimo",
      userAdmId: await getRegistrationById(usuario!.uid),
      userId: await getRegistrationById(borrowerDoc.id),
      codBook: bookCod,
    );
  }

  Future<void> getIdByRegistration(String registration) async {
    await firebaseFirestore
        .collection('user')
        .where('matriculaSIAPE', isEqualTo: registration)
        .get()
        .then((value) {
      return value.docs.first.id;
    });
  }

  Future<String?> getEmailByRegistration(String registration) async {
    String? resp;
    await _firstOrNull(firebaseFirestore
            .collection('user')
            .where('matriculaSIAPE', isEqualTo: registration))
        .then(
      (docSnapshot) {
        if (docSnapshot == null) {
          Fluttertoast.showToast(msg: 'Matrícula não encontrada');
          return null;
        }

        if (!docSnapshot.data()['validated']) {
          resp = 'Matrícula não validada';
          return null;
        }

        resp = docSnapshot.data()['email'];
      },
    ).catchError(
      (e) {
        Fluttertoast.showToast(msg: e!.message);
        return null;
      },
    );
    return resp;
  }

  Future<Map<String, dynamic>> getBookData(String code) async {
    Map<String, dynamic> resp = {
      "nome": 'Null',
      "autor": 'Null',
      "edicao": 'Null',
      "tipo": 'Null',
    };
    await firebaseFirestore
        .collection('book')
        .where('codigo', isEqualTo: code)
        .where('isDeleted', isEqualTo: false)
        .get()
        .then(
      (value) {
        if (value.docs.isEmpty) {
          Fluttertoast.showToast(msg: 'Obra não encontrada');
          return null;
        } else if (!(value.docs.first.data()['userloan'].toString() ==
            'null')) {
          Fluttertoast.showToast(msg: 'Obra indisponível');
          return null;
        }
        for (var docSnapshot in value.docs) {
          resp = {
            "nome": docSnapshot.data()['nome'],
            "autor": docSnapshot.data()['autor'],
            "edicao": docSnapshot.data()['edicao'].toString(),
            "tipo": docSnapshot.data()['tipo'],
          };
        }
      },
    ).catchError(
      (e) {
        Fluttertoast.showToast(msg: e!.message);
        return null;
      },
    );
    return resp;
  }

  Future<void> updateValidate(Map<String, dynamic> rV,
      String readerRegistration, String? userRegistration) async {
    // TODO Fiz uma solução não legal, atualizar quando tiver tempo
    DateFormat date = DateFormat('dd/MM/yyyy HH:mm');

    await firebaseFirestore
        .collection('validation')
        .where('userReaderId', isEqualTo: readerRegistration)
        .get()
        .then((value) async {
      await firebaseFirestore
          .collection("validation")
          .doc(value.docs.first.id)
          .update(
        {
          "status": true,
          "userAllowingId": userRegistration,
          "dateValidationTs": Timestamp.fromDate(DateTime.now()),
          "dateValidation": date.format(DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch))
        },
      );
    });
    await createLog(
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      action: "Validação",
      userAdmId: userRegistration,
      userId: readerRegistration,
    );
  }

  Future<void> confirmValidation(
      String registration, Map<String, dynamic> requestValidate) async {
    await firebaseFirestore
        .collection('user')
        .where('matriculaSIAPE', isEqualTo: registration)
        .get()
        .then(
      (value) async {
        if (value.docs.isEmpty) {
          Fluttertoast.showToast(msg: 'Matrícula não encontrada');
          return false;
        }
        for (var docSnapshot in value.docs) {
          var usermap = docSnapshot.data();
          usermap['validated'] = true;
          firebaseFirestore
              .collection("user")
              .doc(usermap['uId'])
              .update({"validated": true});
        }
        Fluttertoast.showToast(msg: 'Validado com Sucesso');
      },
    ).catchError(
      (e) {
        Fluttertoast.showToast(msg: e!.message);
        return false;
      },
    );
    updateValidate(requestValidate, registration, usuario?.uid);
  }

  Future<void> sendValidationRequest(String registration) async {
    final now = DateTime.now();
    ValidationModel validationRequest = ValidationModel(
        dateRequest: FirestoreDateUtils.toLegacyString(now),
        dateValidation: FirestoreDateUtils.toLegacyString(now),
        status: false,
        userAllowingId: null,
        userReaderId: registration);
    await firebaseFirestore
        .collection("validation")
        .add(validationRequest.toMap()
          ..addAll({
            'dateRequestTs': Timestamp.fromDate(now),
            'dateValidationTs': Timestamp.fromDate(now),
          }));
  }

  Future<void> saveLogin(
      BuildContext context, String registration, String password) async {
    // Salvar
    await context.read<AppSettings>().setData(registration, password);
  }

  Future<void> removeSaveLogin(BuildContext context) async {
    await context.read<AppSettings>().setData('', '');
  }

  void signInWithRegistration(
    BuildContext context,
    String registration,
    String password,
    bool rememberPass,
  ) async {
    bool succesSignIn = false;
    final normalizedRegistration = registration.trim();
    final rawPassword = password;

    await _firstOrNull(firebaseFirestore
            .collection('user')
            .where('matriculaSIAPE', isEqualTo: normalizedRegistration))
        .then(
      (docSnapshot) async {
        if (docSnapshot == null) {
          Fluttertoast.showToast(msg: 'Matrícula não encontrada');
          return false;
        }

        if (docSnapshot.data()['validated']) {
          String email = docSnapshot.data()['email'];
          succesSignIn = await signIn(
            context,
            email,
            rawPassword,
            docSnapshot.data()['typeAdmin'],
          );
        } else {
          Fluttertoast.showToast(msg: 'Matrícula não validada');
        }

        _getUser();
      },
    ).catchError(
      (e) {
        Fluttertoast.showToast(msg: e!.message);
        _getUser();
        return false;
      },
    );
    _getUser();
    if (rememberPass && succesSignIn) {
      saveLogin(context, normalizedRegistration, rawPassword);
    }
  }

  Future<bool> signIn(
    BuildContext context,
    String email,
    String senha,
    bool isAdm,
  ) async {
    bool resp = false;

    final normalizedEmail = email.trim().toLowerCase();
    await _auth
        .signInWithEmailAndPassword(email: normalizedEmail, password: senha)
        .then((uid) {
      Fluttertoast.showToast(msg: "Logado com sucesso");
      if (isAdm) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeCa(),
          ),
        );
        this.isAdm = true;
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeFinalUse(),
          ),
        );
        this.isAdm = false;
      }
      resp = true; // sucesso ao logar
    }).catchError((e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-credential':
          case 'wrong-password':
          case 'INVALID_LOGIN_CREDENTIALS':
            Fluttertoast.showToast(
                msg: 'Credenciais inválidas. Verifique matrícula e senha.');
            break;
          case 'user-not-found':
            Fluttertoast.showToast(
                msg: 'Usuário não encontrado no Firebase Auth.');
            break;
          case 'invalid-email':
            Fluttertoast.showToast(
                msg: 'E-mail inválido vinculado à matrícula.');
            break;
          case 'operation-not-allowed':
            Fluttertoast.showToast(
                msg:
                    'Login por e-mail/senha desativado no Firebase Authentication.');
            break;
          case 'too-many-requests':
            Fluttertoast.showToast(
                msg: 'Muitas tentativas. Tente novamente em alguns minutos.');
            break;
          case 'network-request-failed':
            Fluttertoast.showToast(
                msg: 'Falha de rede. Verifique sua conexão.');
            break;
          default:
            Fluttertoast.showToast(
              msg: 'Falha no login (${e.code}). ${e.message ?? ''}',
            );
            break;
        }
      } else {
        Fluttertoast.showToast(msg: 'Falha no login.');
      }
      _getUser();
    });
    _getUser();
    return resp; // sucesso ao logar
  }

  Future<void> signUp(
    BuildContext context,
    String nick,
    String email,
    String senha,
    GlobalKey<FormState> formKey,
    TextEditingController? texMatriculaController,
    TextEditingController? texEmailController,
    TextEditingController? texSenhaController,
    TextEditingController? texConfSenhaController,
  ) async {
    if (formKey.currentState!.validate()) {
      await _firstOrNull(firebaseFirestore
              .collection('user')
              .where('matriculaSIAPE', isEqualTo: texMatriculaController!.text))
          .then(
        (docSnapshot) async {
          if (docSnapshot == null) {
            await _auth
                .createUserWithEmailAndPassword(email: email, password: senha)
                .then((value) => {
                      postDetailsToFirestore(
                        context,
                        nick,
                        texMatriculaController,
                        texEmailController,
                        texSenhaController,
                        texConfSenhaController,
                      ),
                    })
                .catchError((e) {
              Fluttertoast.showToast(msg: e!.message);
              return e;
            });
          } else {
            Fluttertoast.showToast(msg: 'Matrícula já Registrada!');
          }
        },
      ).catchError(
        (e) {
          Fluttertoast.showToast(msg: e!.message);
        },
      );
      _getUser();
    }
  }

  Future<void> postDetailsToFirestore(
    BuildContext context,
    String nickname,
    TextEditingController? texMatriculaController,
    TextEditingController? texEmailController,
    TextEditingController? texSenhaController,
    TextEditingController? texConfSenhaController,
  ) async {
    // * Calling Firestore
    // * Calling User Model
    // * Sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel(
      uId: user!.uid,
      nickname: nickname,
      matriculaSIAPE: texMatriculaController!.text,
      email: texEmailController!.text,
      pass: texSenhaController!.text,
      typeAdmin: false,
      validated: false,
      userLoans: [],
    );

    // * Writing all the values

    await firebaseFirestore
        .collection("user")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Conta criada com sucesso");
    sendValidationRequest(texMatriculaController.text);

    // Não sei corrigir
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              const RegisterValidationHelpPageWidget()),
      (route) => false,
    );
  }

  Future<bool> checkIfExist(String nome, String autor, String edicao) async {
    // TODO: Fazer uma função de retorno do _value_
    // depois trocar pra chave de identificação
    bool resp = false;
    await _firstOrNull(firebaseFirestore
            .collection('book')
            .where('nome', isEqualTo: nome)
            .where('autor', isEqualTo: autor)
            .where('edicao', isEqualTo: int.tryParse(edicao)))
        .then(
      (docSnapshot) {
        if (docSnapshot == null ||
            docSnapshot.data()['isDeleted'].toString() == 'true') {
          resp = false;
        } else {
          resp = true;
        }
      },
    );
    return resp;
  }

  Future<void> postBookDetailsToFirestore(
    // separar em 2 funções
    TextEditingController? codController,
    TextEditingController? nomeController,
    TextEditingController? autorController,
    TextEditingController? anoController,
    TextEditingController? edicaoController,
    String? tipo,
    String? genero,
    TextEditingController? editoraController,
    bool isUpdating,
    //TextEditingController? fotoController, Por enquanto não vou colocar foto
  ) async {
    final nome = nomeController?.text ?? '';
    final autor = autorController?.text ?? '';
    final editora = editoraController?.text ?? '';
    final isbn = codController?.text ?? '';
    final generoSelecionado =
        (genero?.trim().isNotEmpty ?? false) ? genero! : 'N.D.A';
    final tipoSelecionado =
        (tipo?.trim().isNotEmpty ?? false) ? tipo! : 'N.D.A';

    if (!await checkIfExist(nome, autor, edicaoController?.text ?? '') ||
        isUpdating) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final genreIndex = genreList.indexOf(generoSelecionado);
      final genreAcronym =
          genreIndex >= 0 ? genreListAcronym[genreIndex] : 'NDA';
      BookModel bookModel = BookModel(
          // tem como otimizar a edição
          nome: nome,
          autor: autor,
          ano: int.tryParse(anoController?.text ?? ''),
          edicao: int.tryParse(edicaoController?.text ?? ''),
          tipoMidia: tipoSelecionado,
          genero: generoSelecionado,
          foto: await getHttpImage(isbn),
          dataCadastro: FirestoreDateUtils.toLegacyString(now) ?? '',
          editora: editora,
          dataDisponibilidade: null,
          isDeleted: false,
          userloan: null,
          admRecorder: usuario?.uid,
          codigo: await firebaseFirestore
              .collection('book')
              .where('genero', isEqualTo: generoSelecionado)
              .get()
              .then((value) {
            return '$genreAcronym-${value.size.toString().padLeft(3, '0')}';
          }),
          isbn: isbn);
      await createLog(
        time: DateTime.now().millisecondsSinceEpoch.toString(),
        action: "Cadastro",
        userAdmId: await getRegistrationById(usuario!.uid),
        codBook: bookModel.codigo,
      );
      (!isUpdating)
          ? await firebaseFirestore.collection("book").add(bookModel.toMap()
            ..addAll({'dataCadastroTs': Timestamp.fromDate(now)}))
          : null;
      Fluttertoast.showToast(msg: "Obra salva no sistema!");
      if (isUpdating) {
        // edição
        await firebaseFirestore
            .collection('book')
            .where('nome', isEqualTo: bookModel.nome)
            .where('autor', isEqualTo: bookModel.autor)
            .where('edicao', isEqualTo: bookModel.edicao)
            .get()
            .then(
          (value) async {
            firebaseFirestore.collection("book").doc(value.docs.first.id).set(
                bookModel.toMap()
                  ..addAll({'dataCadastroTs': Timestamp.fromDate(now)}));
            await createLog(
              time: DateTime.now().millisecondsSinceEpoch.toString(),
              action: "Edição",
              userAdmId: await getRegistrationById(usuario!.uid),
              codBook: await getCodById(value.docs.first.id),
            );
          },
        );
      }
    } else {
      Fluttertoast.showToast(msg: 'Livro já Cadastrado');
    }
  }

  Future<void> deleteBook(
    // reduzir pedindo o id pra fazer a mudança
    Map<String, dynamic> obra,
  ) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    obra['isDeleted'] = true;
    await firebaseFirestore
        .collection('book')
        .where('nome', isEqualTo: obra['nome'])
        .where('autor', isEqualTo: obra['autor'])
        .where('edicao', isEqualTo: int.tryParse(obra['nome']))
        .get()
        .then(
      (value) async {
        if (value.docs.isEmpty) {
          Fluttertoast.showToast(msg: "Obra não existe no sistema");
        } else {
          await firebaseFirestore
              .collection("book")
              .doc(value.docs.first.id)
              .set(obra);
          Fluttertoast.showToast(msg: "Obra deletada do sistema!");
          await createLog(
            time: DateTime.now().millisecondsSinceEpoch.toString(),
            action: "Remoção",
            userAdmId: await getRegistrationById(usuario!.uid),
            codBook: await getCodById(value.docs.first.id),
          );
        }
      },
    );
  }
}
