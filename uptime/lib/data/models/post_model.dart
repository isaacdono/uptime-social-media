class Post {
  final String idPost;
  final String idPersona;
  final String categoria;
  final String tipoMedia;
  final String urlMedia;
  final String descricao;
  final DateTime timestamp;

  Post({
    required this.idPost,
    required this.idPersona,
    required this.categoria,
    required this.tipoMedia,
    required this.urlMedia,
    required this.descricao,
    required this.timestamp,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      idPost: map['idPost'] ?? '',
      idPersona: map['idPersona'] ?? '',
      categoria: map['categoria'] ?? '',
      tipoMedia: map['tipoMedia'] ?? '',
      urlMedia: map['urlMedia'] ?? '',
      descricao: map['descricao'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPost': idPost,
      'idPersona': idPersona,
      'categoria': categoria,
      'tipoMedia': tipoMedia,
      'urlMedia': urlMedia,
      'descricao': descricao,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}