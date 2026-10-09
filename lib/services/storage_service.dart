import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/caminhada.dart';

class StorageService {
  static const String chave = 'caminhadas';

  static Future<List<Caminhada>> listarCaminhadas() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List lista = jsonDecode(dados);

    return lista
        .map(
          (item) => Caminhada.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<void> salvarCaminhada(Caminhada caminhada) async {
    final prefs = await SharedPreferences.getInstance();

    final caminhadas = await listarCaminhadas();

    caminhadas.add(caminhada);

    final dados = jsonEncode(
      caminhadas.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(chave, dados);
  }

  static Future<void> atualizarCaminhada(
    Caminhada caminhada,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final caminhadas = await listarCaminhadas();

    final index = caminhadas.indexWhere(
      (item) => item.id == caminhada.id,
    );

    if (index != -1) {
      caminhadas[index] = caminhada;
    }

    final dados = jsonEncode(
      caminhadas.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(chave, dados);
  }

  static Future<void> excluirCaminhada(int id) async {
    final prefs = await SharedPreferences.getInstance();

    final caminhadas = await listarCaminhadas();

    caminhadas.removeWhere(
      (item) => item.id == id,
    );

    final dados = jsonEncode(
      caminhadas.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(chave, dados);
  }
}