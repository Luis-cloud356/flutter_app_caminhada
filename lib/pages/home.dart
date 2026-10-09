import 'package:flutter/material.dart';

import '../models/caminhada.dart';
import '../services/storage_service.dart';
import '../widgets/card_caminhada.dart';
import '../widgets/menu_lateral.dart';
import 'detalhes.dart';
import 'nova_caminhada.dart';

class Home extends StatefulWidget {
  final bool temaEscuro;
  final Function(bool) onTemaAlterado;

  const Home({
    super.key,
    required this.temaEscuro,
    required this.onTemaAlterado,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Caminhada> caminhadas = [];

  bool carregando = true;

  @override
  void initState() {
    super.initState();

    carregarCaminhadas();
  }

  Future<void> carregarCaminhadas() async {
    final lista =
        await StorageService.listarCaminhadas();

    if (!mounted) return;

    setState(() {
      caminhadas = lista;
      carregando = false;
    });
  }

  Future<void> abrirNovaCaminhada() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NovaCaminhada(),
      ),
    );

    carregarCaminhadas();
  }

  Future<void> abrirDetalhes(
    Caminhada caminhada,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Detalhes(
          caminhada: caminhada,
        ),
      ),
    );

    carregarCaminhadas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuLateral(
        temaEscuro: widget.temaEscuro,
        onTemaAlterado: widget.onTemaAlterado,
      ),

      appBar: AppBar(
        title: const Text(
          'Caminhadas',
        ),

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
              ),

              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : caminhadas.isEmpty
              ? _telaVazia()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 90,
                  ),

                  itemCount: caminhadas.length,

                  itemBuilder: (context, index) {
                    final caminhada =
                        caminhadas[index];

                    return InkWell(
                      onTap: () {
                        abrirDetalhes(caminhada);
                      },

                      child: CardCaminhada(
                        caminhada: caminhada,
                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirNovaCaminhada,

        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  Widget _telaVazia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.directions_walk,
              size: 100,
              color: Colors.green.shade300,
            ),

            const SizedBox(height: 20),

            const Text(
              'Nenhuma caminhada cadastrada',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Clique no botão + para registrar sua primeira caminhada.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}