/// Modelo para provedor de streaming
class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final int displayPriority;

  WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    required this.displayPriority,
  });

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: json['provider_id'] ?? 0,
      providerName: json['provider_name'] ?? '',
      logoPath: json['logo_path'],
      displayPriority: json['display_priority'] ?? 999,
    );
  }

  /// URL do logo do provedor
  String get logoUrl {
    if (logoPath == null || logoPath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w92$logoPath';
  }
}

/// Resultado dos provedores de streaming para um filme
class WatchProviders {
  final List<WatchProvider> flatrate; // Streaming (Netflix, Prime, etc)
  final List<WatchProvider> rent; // Alugar
  final List<WatchProvider> buy; // Comprar
  final String? link; // Link para JustWatch

  WatchProviders({
    required this.flatrate,
    required this.rent,
    required this.buy,
    this.link,
  });

  factory WatchProviders.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WatchProviders(flatrate: [], rent: [], buy: []);
    }

    return WatchProviders(
      flatrate:
          (json['flatrate'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p))
              .toList() ??
          [],
      rent:
          (json['rent'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p))
              .toList() ??
          [],
      buy:
          (json['buy'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p))
              .toList() ??
          [],
      link: json['link'],
    );
  }

  /// Retorna true se houver algum provedor disponível
  bool get hasAnyProvider =>
      flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;

  /// Retorna todos os provedores de streaming (flatrate)
  List<WatchProvider> get streamingProviders => flatrate;
}
