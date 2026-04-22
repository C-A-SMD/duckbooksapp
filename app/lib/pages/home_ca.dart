import 'package:app/pages/loan_page.dart';
import 'package:app/pages/reservations_page.dart';
import 'package:flutter/material.dart';
import '/assets/theme/flutter_flow_theme.dart';
import 'consult_colletion_page.dart';
import 'home_page_ca.dart';

class HomeCa extends StatefulWidget {
  const HomeCa({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeCaState createState() => _HomeCaState();
}

class _HomeCaState extends State<HomeCa> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  void setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: setPaginaAtual,
        children: const [
          HomePageCa(),
          ConsultPage(),
          LoanPage(),
          ReservationsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        onTap: (page) => setState(
          () {
            pc.jumpToPage(page);
            // pc.animateToPage(
            //   page,
            //   duration: const Duration(milliseconds: 50),
            //   curve: Curves.ease,
            // );
          },
        ),
        backgroundColor: FlutterFlowTheme.of(context).primaryContainer,
        selectedItemColor: FlutterFlowTheme.of(context).onPrimaryContainer,
        unselectedItemColor: FlutterFlowTheme.of(context).inactiveBottomBar,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              size: 22.0,
            ),
            activeIcon: Icon(
              Icons.home_rounded,
              size: 26.0,
            ),
            label: 'Home',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 20.0,
            ),
            activeIcon: Icon(
              Icons.saved_search,
              size: 30.0,
            ),
            label: 'Consulta',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.auto_stories_outlined,
              size: 22.0,
            ),
            activeIcon: Icon(
              Icons.auto_stories_rounded,
              size: 26.0,
            ),
            label: 'Empréstimos',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmarks_outlined,
              size: 22.0,
            ),
            activeIcon: Icon(
              Icons.bookmarks_rounded,
              size: 26.0,
            ),
            label: 'Reservas',
            tooltip: '',
          ),
        ],
      ),
    );
  }
}
