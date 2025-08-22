// presentation/widgets/category_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/topic.dart';

class CategoryCard extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.greenAccent, width: 3)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                topic.imageUrl,
                fit: BoxFit.cover,
                // Simple loading and error widgets for network images
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
              // Gradient overlay for better text visibility
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white, // Branco com um pouco de transparência
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    topic.name,
                    style: const TextStyle(
                      color: Colors.black87, // Cor do texto dentro do bloquinho
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(blurRadius: 0.5, color: Colors.grey),
                      ], // Opcional: pequena sombra
                    ),
                    textAlign: TextAlign
                        .center, // Opcional: centralizar o texto dentro do bloquinho
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
