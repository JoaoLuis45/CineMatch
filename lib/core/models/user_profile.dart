/// Modelo de dados do perfil do usuário
class UserProfile {
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? favoriteGenre;

  UserProfile({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.birthDate,
    this.favoriteGenre,
  });

  /// Cria uma cópia do perfil com novos valores
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? birthDate,
    String? favoriteGenre,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
    );
  }

  /// Formato da data de nascimento
  String get formattedBirthDate {
    if (birthDate == null) return 'Não informado';
    return '${birthDate!.day.toString().padLeft(2, '0')}/${birthDate!.month.toString().padLeft(2, '0')}/${birthDate!.year}';
  }

  /// Idade calculada
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Converte para JSON (para salvar localmente)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'favoriteGenre': favoriteGenre,
    };
  }

  /// Cria a partir de JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      displayName: json['displayName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      favoriteGenre: json['favoriteGenre'],
    );
  }
}
