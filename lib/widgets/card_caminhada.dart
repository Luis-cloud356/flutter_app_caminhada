import 'dart:io';

import 'package:flutter/material.dart';

import '../models/caminhada.dart';

class CardCaminhada extends StatelessWidget {
  final Caminhada caminhada;

  const CardCaminhada({
    super.key,
    required this.caminhada,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade100,
              ),

              child: caminhada.foto != null &&
                      caminhada.foto!.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),

                      child: Image.file(
                        File(caminhada.foto!),
                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.directions_walk,
                            size: 40,
                            color: Colors.green,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.directions_walk,
                      size: 40,
                      color: Colors.green,
                    ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    caminhada.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${caminhada.distancia.toStringAsFixed(2)} km',
                  ),

                  Text(
                    '${caminhada.tempoMinutos} minutos',
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}