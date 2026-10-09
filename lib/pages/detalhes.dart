import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/caminhada.dart';
import '../services/storage_service.dart';

class Detalhes extends StatefulWidget {
  final Caminhada caminhada;

  const Detalhes({
    super.key,
    required this.caminhada,
  });

  @override
  State<Detalhes> createState() =>
      _DetalhesState();
}

class _DetalhesState
    extends State<Detalhes> {
  late Caminhada caminhada;

  @override
  void initState() {
    super.initState();

    caminhada = widget.caminhada;
  }

  Future<void> tirarFoto() async {
    final ImagePicker picker =
        ImagePicker();

    final XFile? imagem =
        await picker.pickImage(
      source: ImageSource.camera,

      imageQuality: 80,
    );

    if (imagem == null) {
      return;
    }

    caminhada.foto = imagem.path;

    await StorageService.atualizarCaminhada(
      caminhada,
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> excluir() async {
    final confirmar =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir caminhada',
          ),

          content: const Text(
            'Tem certeza que deseja excluir esta caminhada?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Excluir',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await StorageService.excluirCaminhada(
      caminhada.id,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pontos = caminhada.trajeto
        .map(
          (ponto) => LatLng(
            ponto['latitude']!,
            ponto['longitude']!,
          ),
        )
        .toList();

    final inicio = LatLng(
      caminhada.latitudeInicio,
      caminhada.longitudeInicio,
    );

    final destino = LatLng(
      caminhada.latitudeDestino,
      caminhada.longitudeDestino,
    );

    final todosPontos = [
      inicio,
      destino,
      ...pontos,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          caminhada.titulo,
        ),

        actions: [
          IconButton(
            onPressed: excluir,

            icon: const Icon(
              Icons.delete,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 350,

              child: FlutterMap(
                options: MapOptions(
                  initialCenter: inicio,

                  initialZoom: 15,

                  onMapReady: () {
                    if (todosPontos.length > 1) {
                      // O mapa será ajustado pelo botão abaixo
                    }
                  },
                ),

                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName:
                        'com.example.caminhadas',
                  ),

                  if (pontos.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: pontos,

                          strokeWidth: 5,

                          color: Colors.blue,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: inicio,

                        width: 50,
                        height: 50,

                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 35,
                        ),
                      ),

                      Marker(
                        point: destino,

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

            _dados(),

            _foto(),
          ],
        ),
      ),
    );
  }

  Widget _dados() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            caminhada.titulo,

            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _linhaInformacao(
            Icons.route,
            'Distância',
            '${caminhada.distancia.toStringAsFixed(2)} km',
          ),

          _linhaInformacao(
            Icons.local_fire_department,
            'Gasto calórico',
            '${caminhada.calorias.toStringAsFixed(0)} kcal',
          ),

          _linhaInformacao(
            Icons.timer,
            'Tempo de caminhada',
            '${caminhada.tempoMinutos} minutos',
          ),
        ],
      ),
    );
  }

  Widget _linhaInformacao(
    IconData icone,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 15,
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icone,
              color: Colors.green,
            ),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                titulo,

                style: const TextStyle(
                  fontSize: 13,
                ),
              ),

              Text(
                valor,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _foto() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        30,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Foto da caminhada',

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          if (caminhada.foto == null)
            GestureDetector(
              onTap: tirarFoto,

              child: Container(
                width: double.infinity,
                height: 220,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(15),

                  color: Colors.grey.shade200,
                ),

                child: const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Tirar foto',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(15),

                  child: Image.file(
                    File(caminhada.foto!),

                    width: double.infinity,
                    height: 300,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton.icon(
                    onPressed: tirarFoto,

                    icon: const Icon(
                      Icons.camera_alt,
                    ),

                    label: const Text(
                      'Tirar outra foto',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}