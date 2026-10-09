import '../pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuLateral extends StatelessWidget {
  final bool temaEscuro;
  final Function(bool) onTemaAlterado;

  const MenuLateral({
    super.key,
    required this.temaEscuro,
    required this.onTemaAlterado,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),

              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.white,
                    size: 55,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Caminhadas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.home,
              ),

              title: const Text(
                'Caminhadas',
              ),

              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.animation,
              ),

              title: const Text(
                'Splash',
              ),

              onTap: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => Splash(
                      onFinalizado: () => navigator.pop(),
                    ),
                  ),
                );
              },
            ),

            SwitchListTile(
              secondary: Icon(
                temaEscuro
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),

              title: const Text(
                'Tema escuro',
              ),

              value: temaEscuro,

              onChanged: (valor) {
                onTemaAlterado(valor);

                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),

              title: const Text(
                'Sair',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),

              onTap: () {
                SystemNavigator.pop();
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}