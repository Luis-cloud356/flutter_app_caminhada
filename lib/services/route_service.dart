import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static Future<List<LatLng>> calcularRota(
    LatLng inicio,
    LatLng destino,
  ) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/'
        '${inicio.longitude},${inicio.latitude};'
        '${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson',
      );

      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        return [inicio, destino];
      }

      final dados = jsonDecode(resposta.body);

      final coordenadas =
          dados['routes'][0]['geometry']['coordinates'];

      return coordenadas.map<LatLng>((coordenada) {
        return LatLng(
          coordenada[1].toDouble(),
          coordenada[0].toDouble(),
        );
      }).toList();
    } catch (e) {
      return [inicio, destino];
    }
  }

  static double calcularDistancia(
    List<LatLng> pontos,
  ) {
    if (pontos.length < 2) {
      return 0;
    }

    const distancia = Distance();

    double total = 0;

    for (int i = 0; i < pontos.length - 1; i++) {
      total += distancia(
        pontos[i],
        pontos[i + 1],
      );
    }

    return total / 1000;
  }

  static int calcularTempo(double distanciaKm) {
    // velocidade média de 5 km/h
    const velocidadeMedia = 5.0;

    final horas = distanciaKm / velocidadeMedia;

    return (horas * 60).round();
  }

  static double calcularCalorias(double distanciaKm) {
    // Estimativa considerando uma pessoa de 70 kg.
    // Aproximadamente 50 kcal por km.
    return distanciaKm * 50;
  }
}