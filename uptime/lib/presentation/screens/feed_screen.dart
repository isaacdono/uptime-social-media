import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/models/post_model.dart';
import '../../data/models/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Post>> _postsFuture;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  Future<List<Post>> _loadPosts() async {
    List<Post> posts = await PostService.loadPostsFromAssets();
    if (posts.isEmpty) {
      posts = await PostService.loadPostsFromDirectory();
    }
    return posts;
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Memes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshPosts,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Erro ao carregar posts'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              _posts = snapshot.data!;
              return Padding( // Adicionando Padding aqui
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return PostCard(post: post);
                  },
                ),
              );
            } else {
              return const Center(
                child: Text('Nenhum post encontrado.'),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Memes', isSelected: true),
            _buildNavItem(Icons.video_library, 'Vídeos'),
            _buildNavItem(Icons.music_note, 'Dancinhas'),
            _buildNavItem(Icons.more_horiz, 'Mais...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.green : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(
                post.idPersona.isNotEmpty ? post.idPersona[0] : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              post.idPersona,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(timeago.format(post.timestamp, locale: 'pt_br')),
            trailing: const Icon(Icons.more_vert),
          ),
          if (post.tipoMedia == 'imagem' && post.urlMedia.isNotEmpty)
            Image.network(
              post.urlMedia,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownBody(
              data: post.descricao,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16, height: 1.5),
                strong: const TextStyle(fontWeight: FontWeight.bold),
                blockquote: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                  backgroundColor: Colors.grey[100],
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('10k', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('15k', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.share, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('8k', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}