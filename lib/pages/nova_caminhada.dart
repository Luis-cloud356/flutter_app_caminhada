import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/caminhada.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import '../services/storage_service.dart';

class NovaCaminhada extends StatefulWidget {
  const NovaCaminhada({super.key});

  @override
  State<NovaCaminhada> createState() => _NovaCaminhadaState();
}

class _NovaCaminhadaState extends State<NovaCaminhada> {
  final MapController mapController = MapController();

  LatLng? localAtual;
  LatLng? destino;

  List<LatLng> rota = [];

  double distancia = 0;
  double calorias = 0;

  int tempo = 0;

  bool carregandoLocalizacao = true;
  bool calculandoRota = false;

  @override
  void initState() {
    super.initState();

    obterLocalizacao();
  }

  Future<void> obterLocalizacao() async {
    try {
      final Position position = await LocationService.obterLocalizacao();

      final ponto = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        localAtual = ponto;
        carregandoLocalizacao = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregandoLocalizacao = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> selecionarDestino(LatLng ponto) async {
    if (localAtual == null) return;

    setState(() {
      destino = ponto;
      calculandoRota = true;
      rota = [];
    });

    final novaRota = await RouteService.calcularRota(localAtual!, ponto);

    final distanciaCalculada = RouteService.calcularDistancia(novaRota);

    final tempoCalculado = RouteService.calcularTempo(distanciaCalculada);

    final caloriasCalculadas = RouteService.calcularCalorias(
      distanciaCalculada,
    );

    if (!mounted) return;

    setState(() {
      rota = novaRota;
      distancia = distanciaCalculada;
      tempo = tempoCalculado;
      calorias = caloriasCalculadas;
      calculandoRota = false;
    });

    if (novaRota.isNotEmpty) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(novaRota),
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  Future<void> salvar() async {
    if (localAtual == null || destino == null || rota.isEmpty) {
      return;
    }

    final titulo = await mostrarModalTitulo();

    if (titulo == null || titulo.trim().isEmpty) {
      return;
    }

    final caminhada = Caminhada(
      id: DateTime.now().millisecondsSinceEpoch,

      titulo: titulo.trim(),

      distancia: distancia,

      calorias: calorias,

      tempoMinutos: tempo,

      latitudeInicio: localAtual!.latitude,

      longitudeInicio: localAtual!.longitude,

      latitudeDestino: destino!.latitude,

      longitudeDestino: destino!.longitude,

      trajeto: rota
          .map(
            (ponto) => {
              'latitude': ponto.latitude,
              'longitude': ponto.longitude,
            },
          )
          .toList(),
    );

    await StorageService.salvarCaminhada(caminhada);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caminhada salva com sucesso!')),
    );

    Navigator.pop(context);
  }

  Future<String?> mostrarModalTitulo() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Salvar caminhada'),

          content: TextField(
            controller: controller,

            autofocus: true,

            decoration: const InputDecoration(
              labelText: 'Título da caminhada',
              hintText: 'Ex: Caminhada no parque',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },

              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova caminhada')),

      body: carregandoLocalizacao
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,

                    options: MapOptions(
                      initialCenter:
                          localAtual ?? const LatLng(-23.5505, -46.6333),

                      initialZoom: 16,

                      onTap: (tapPosition, point) {
                        selecionarDestino(point);
                      },
                    ),

                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                        userAgentPackageName: 'com.example.caminhadas',
                      ),

                      if (rota.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: rota,

                              strokeWidth: 5,

                              color: Colors.blue,
                            ),
                          ],
                        ),

                      MarkerLayer(
                        markers: [
                          if (localAtual != null)
                            Marker(
                              point: localAtual!,

                              width: 50,
                              height: 50,

                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 35,
                              ),
                            ),

                          if (destino != null)
                            Marker(
                              point: destino!,

                              width: 50,
                              height: 50,

                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 45,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (calculandoRota) const LinearProgressIndicator(),

                _informacoes(),

                Padding(
                  padding: const EdgeInsets.all(15),

                  child: SizedBox(
                    width: double.infinity,

                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: destino != null && !calculandoRota
                          ? salvar
                          : null,

                      icon: const Icon(Icons.save),

                      label: const Text(
                        'Salvar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _informacoes() {
    if (destino == null) {
      return Container(
        padding: const EdgeInsets.all(15),

        child: const Text(
          'Toque no mapa para selecionar o destino da caminhada.',
          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 15),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          _informacao(
            Icons.route,
            '${distancia.toStringAsFixed(2)} km',
            'Distância',
          ),

          _informacao(
            Icons.local_fire_department,
            '${calorias.toStringAsFixed(0)} kcal',
            'Calorias',
          ),

          _informacao(Icons.timer, '$tempo min', 'Tempo'),
        ],
      ),
    );
  }

  Widget _informacao(IconData icone, String valor, String titulo) {
    return Column(
      children: [
        Icon(icone, color: Colors.green, size: 28),

        const SizedBox(height: 5),

        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),

        Text(titulo, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
