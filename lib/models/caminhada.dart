class Caminhada {
  int id;
  String titulo;

  double distancia;
  double calorias;
  int tempoMinutos;

  double latitudeInicio;
  double longitudeInicio;

  double latitudeDestino;
  double longitudeDestino;

  List<Map<String, double>> trajeto;

  String? foto;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.distancia,
    required this.calorias,
    required this.tempoMinutos,
    required this.latitudeInicio,
    required this.longitudeInicio,
    required this.latitudeDestino,
    required this.longitudeDestino,
    required this.trajeto,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'distancia': distancia,
      'calorias': calorias,
      'tempoMinutos': tempoMinutos,
      'latitudeInicio': latitudeInicio,
      'longitudeInicio': longitudeInicio,
      'latitudeDestino': latitudeDestino,
      'longitudeDestino': longitudeDestino,
      'trajeto': trajeto,
      'foto': foto,
    };
  }

  factory Caminhada.fromJson(Map<String, dynamic> json) {
    return Caminhada(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      distancia: (json['distancia'] ?? 0).toDouble(),
      calorias: (json['calorias'] ?? 0).toDouble(),
      tempoMinutos: json['tempoMinutos'] ?? 0,
      latitudeInicio: (json['latitudeInicio'] ?? 0).toDouble(),
      longitudeInicio: (json['longitudeInicio'] ?? 0).toDouble(),
      latitudeDestino: (json['latitudeDestino'] ?? 0).toDouble(),
      longitudeDestino: (json['longitudeDestino'] ?? 0).toDouble(),

      trajeto: (json['trajeto'] as List? ?? [])
          .map<Map<String, double>>(
            (ponto) => <String, double>{
              'latitude': ((ponto['latitude'] ?? 0) as num).toDouble(),
              'longitude': ((ponto['longitude'] ?? 0) as num).toDouble(),
            },
          )
          .toList(),

      foto: json['foto'],
    );
  }
}