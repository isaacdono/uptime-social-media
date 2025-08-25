import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'post_model.dart';

class PostService {
  static Future<List<Post>> loadPostsFromAssets() async {
    try {
      // Carrega a lista de arquivos no diretório de posts
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filtra apenas os arquivos .md na pasta posts
      final postFiles = manifestMap.keys
          .where((String key) => key.contains('posts/') && key.endsWith('.md'))
          .toList();

      List<Post> posts = [];

      for (String assetPath in postFiles) {
        try {
          // Carrega o conteúdo do arquivo
          String fileContent = await rootBundle.loadString(assetPath);

          // Parse do conteúdo (formato específico com múltiplos posts)
          final postsFromFile = _parseMultiPostContent(fileContent, assetPath);
          posts.addAll(postsFromFile);
        } catch (e) {
          print('Erro ao carregar o post $assetPath: $e');
        }
      }

      // Ordena por timestamp (mais recente primeiro)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return posts;
    } catch (e) {
      print('Erro ao carregar posts: $e');
      return [];
    }
  }

  static List<Post> _parseMultiPostContent(String content, String assetPath) {
    List<Post> posts = [];

    // Divide o conteúdo em seções de post separadas por '---'
    final postSections = content.split('---');

    // Ignora o cabeçalho inicial e processa cada seção de post
    for (int i = 1; i < postSections.length; i++) {
      final section = postSections[i].trim();
      if (section.isEmpty) continue;

      try {
        final post = _parsePostSection(section, assetPath, i);
        if (post != null) {
          posts.add(post);
        }
      } catch (e) {
        print('Erro ao parsear a seção $i do arquivo $assetPath: $e');
      }
    }

    return posts;
  }

  static Post? _parsePostSection(String section, String assetPath, int index) {
    final lines = section.split('\n');
    final Map<String, dynamic> postData = {};
    String description = '';
    bool inDescription = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Verifica se é um campo do post
      if (line.startsWith('- **') && line.contains(':**')) {
        inDescription = false;
        final colonIndex = line.indexOf(':**');
        final key = line.substring(3, colonIndex).trim();
        String value = line.substring(colonIndex + 3).trim();

        // Remove aspas se presentes
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }

        postData[key] = value;
      }
      // Verifica se é o início da descrição
      else if (line.startsWith('**Descricao:**')) {
        inDescription = true;
      }
      // Coleta as linhas da descrição
      else if (inDescription) {
        // Remove o marcador "> " se presente
        if (line.startsWith('> ')) {
          description += line.substring(2) + '\n';
        } else {
          description += line + '\n';
        }
      }
    }

    // Adiciona a descrição ao postData
    postData['descricao'] = description.trim();

    // Gera um ID único se não existir
    if (!postData.containsKey('Id Post') || postData['Id Post'].isEmpty) {
      postData['Id Post'] = '${assetPath.split('/').last}-$index';
    }

    // Converte as chaves para o formato esperado pelo modelo
    final Map<String, dynamic> formattedData = {
      'idPost': postData['Id Post'] ?? '',
      'idPersona': postData['Id Persona'] ?? '',
      'categoria': postData['Categoria'] ?? '',
      'tipoMedia': postData['Tipo Media'] ?? '',
      'urlMedia': postData['Url Media'] ?? '',
      'descricao': postData['descricao'] ?? '',
      'timestamp': postData['Timestamp'] ?? DateTime.now().toIso8601String(),
    };

    return Post.fromMap(formattedData);
  }

  // Método para carregar posts de um diretório local
  static Future<List<Post>> loadPostsFromDirectory() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String postsPath = '${appDocDir.path}/posts';
      final Directory postsDir = Directory(postsPath);

      if (!await postsDir.exists()) {
        return [];
      }

      List<Post> posts = [];
      final List<FileSystemEntity> files = postsDir.listSync();

      for (FileSystemEntity file in files) {
        if (file is File && file.path.endsWith('.md')) {
          try {
            String content = await file.readAsString();
            final postsFromFile = _parseMultiPostContent(content, file.path);
            posts.addAll(postsFromFile);
          } catch (e) {
            print('Erro ao ler arquivo ${file.path}: $e');
          }
        }
      }

      // Ordena por timestamp (mais recente primeiro)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return posts;
    } catch (e) {
      print('Erro ao carregar posts do diretório: $e');
      return [];
    }
  }
}