import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> obterLocalizacao() async {
    bool servicoAtivo =
        await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception(
        'Ative o GPS do dispositivo.',
      );
    }

    LocationPermission permissao =
        await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao =
          await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception(
        'Permissão de localização negada.',
      );
    }

    if (permissao ==
        LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização bloqueada nas configurações.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}