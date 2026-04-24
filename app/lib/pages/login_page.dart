import 'package:app/configs/app_settings.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/pages/cadastro_page.dart';
import 'package:app/pages/reset_pass_page.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:app/services/connectivity_service.dart';

import '/assets/theme/flutter_flow_theme.dart';
import 'package:app/widgets/offline_warning_widget.dart';
import 'help_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // * Firebase User Autentication
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> setLoginData() async {
    if (!mounted) {
      return;
    }

    Map<String, String> datalogin =
        Provider.of<AppSettings>(context, listen: false).logindata;
    texMatriculaController.text = datalogin['registration'] ?? '';
    final savedPassword = datalogin['password'] ?? '';
    texSenhaController.text = (savedPassword.length > 3) ? savedPassword : '';
    checkboxValue = (datalogin['registration'] == '') ? false : true;
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((s) {
      setLoginData();
    });

    if (user != null) {
      FirebaseFirestore.instance
          .collection("user")
          .doc(user!.uid)
          .get()
          .then((value) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((_) {});
    }
    passwordVisibility = false;
  }

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  final TextEditingController texMatriculaController = TextEditingController();
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  final TextEditingController texSenhaController = TextEditingController();
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? texSenhaControllerValidator;
  // State field(s) for Checkbox widget.
  bool checkboxValue = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    texMatriculaController.dispose();
    texSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          actions: [
            Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpPage()));
                  },
                  child: FaIcon(
                    // ignore: deprecated_member_use
                    FontAwesomeIcons.questionCircle,
                    color: FlutterFlowTheme.of(context).onBackground,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            const OfflineWarningBanner(
              message: 'Sem internet. Login e cadastro indisponiveis.',
            ),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            (FlutterFlowTheme.of(context)
                                    .toString()
                                    .contains('Dark'))
                                ? 'lib/assets/images/logo_black_text_no_bg.png'
                                : 'lib/assets/images/logo_to_white.png',
                            width: 300,
                            height: 200,
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: texMatriculaController,
                              obscureText: false,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Matrícula ou SIAPE',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 16,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyLargeFamily),
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).info,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                prefixIcon: Icon(
                                  Icons.location_history_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                                suffixIcon: texMatriculaController
                                        .text.isNotEmpty
                                    ? InkWell(
                                        onTap: () async {
                                          texMatriculaController.clear();
                                          setState(() {});
                                        },
                                        child: Icon(
                                          Icons.clear,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleLargeFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 16,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .titleLargeFamily),
                                  ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório';
                                } else if (value.length < 6) {
                                  return 'Matrícula inválida';
                                }
                                return null; // Retorna nulo se a validação passar
                              },
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: texSenhaController,
                              obscureText: !passwordVisibility,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Senha',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 16,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily),
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0x00000000),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).info,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                prefixIcon: Icon(
                                  Icons.vpn_key,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 20,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                    () => passwordVisibility =
                                        !passwordVisibility,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 18,
                                  ),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyLargeFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .bodyLargeFamily),
                                  ),
                              cursorColor: const Color(0xFF311A0B),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Senha vazia!';
                                } else if (value.length < 6) {
                                  return 'Tamanho mímino de 6 dígitos';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              60, 0, 60, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                                child: Checkbox(
                                  value: checkboxValue,
                                  onChanged: (newValue) async {
                                    setState(() =>
                                        checkboxValue = newValue ?? false);
                                  },
                                  activeColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  checkColor:
                                      FlutterFlowTheme.of(context).onBackground,
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-1, 0),
                                child: Text(
                                  'Lembrar senha',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyLarge
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyLargeFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        useGoogleFonts: GoogleFonts.asMap()
                                            .containsKey(
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                        child: Consumer<ConnectivityService>(
                          builder: (context, connectivity, _) {
                            return TextButton(
                              onPressed: connectivity.isOffline
                                  ? () {
                                      showOfflineDialog(context);
                                    }
                                  : () async {
                                      if (_formKey.currentState != null &&
                                          _formKey.currentState!.validate()) {
                                        Fluttertoast.showToast(
                                            msg: 'Entrando...');
                                        await context
                                            .read<AuthService>()
                                            .signInWithRegistration(
                                              context,
                                              texMatriculaController.text,
                                              texSenhaController.text,
                                              checkboxValue,
                                            );
                                      }
                                    },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fixedSize: Size(
                                    MediaQuery.of(context).size.width * 0.7,
                                    40),
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                backgroundColor: connectivity.isOffline
                                    ? FlutterFlowTheme.of(context)
                                        .primary
                                        .withValues(alpha: 0.5)
                                    : FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      fontSize: 16,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .bodyLargeFamily),
                                    ),
                                elevation: 5,
                              ),
                              child: Text(
                                'Entrar',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimaryContainer,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .titleMediumFamily),
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 16, 0, 32),
                          child: TextButton(
                            child: Text(
                              "Esqueci minha senha",
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyLargeFamily,
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    decoration: TextDecoration.underline,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey(
                                            FlutterFlowTheme.of(context)
                                                .bodyLargeFamily),
                                  ),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ResetPasswordPage()),
                            ),
                          )),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Não possui cadastro ?',
                                style: FlutterFlowTheme.of(context).bodyLarge),
                            const SizedBox(width: 8),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CadastroPage()));
                              },
                              child: Text(
                                'Cadastre-se',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      decoration: TextDecoration.underline,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey(
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
