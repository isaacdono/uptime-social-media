// Em presentation/screens/initial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/setup_cubic.dart';
import '../blocs/setup_state.dart';
import '../widgets/category_card.dart';
import 'feed_screen.dart';
import '../../data/models/post_model.dart';
// Importe seus widgets e o cubit/state aqui

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // É uma boa prática prover o Cubit na árvore de widgets
    return BlocProvider(
      create: (context) => SetupCubit()..loadTopics(), // Inicia o carregamento
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.person_outline),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<SetupCubit, SetupState>(
          builder: (context, state) {
            // Se estiver carregando, mostra um loader
            if (state.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Se carregar com sucesso, mostra o conteúdo
            if (state.status == Status.success) {
              return _buildSuccessBody(context, state);
            }

            // Se der erro, mostra uma mensagem
            // (Adicionar lógica de erro)
            return const Center(child: Text('Erro ao carregar os tópicos.'));
          },
        ),
      ),
    );
  }

  Widget _buildSuccessBody(BuildContext context, SetupState state) {
    final cubit = context.read<SetupCubit>(); // Acesso ao cubit para ações

    return Padding(
      // Aumentamos o padding lateral e adicionamos um vertical
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Aumentando o tamanho da fonte e ajustando o estilo
          ShaderMask(
            // Esta função cria o gradiente
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFBBFF28), Color(0xFF00A862), Color(0xFF005299)], // <-- Suas cores
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            // O widget Text que será "pintado"
            child: const Text(
              'Olá, Carlo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                // A cor aqui é importante para o ShaderMask funcionar, mas não será visível.
                // Use Colors.white ou qualquer cor sólida.
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Do que você está\n a fim hoje?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Spacer(flex: 1),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 24,
              childAspectRatio: 0.8,
            ),
            itemCount: state.topics.length,
            itemBuilder: (context, index) {
              final topic = state.topics[index];
              return CategoryCard(
                topic: topic,
                isSelected: state.selectedTopicIds.contains(topic.id),
                onTap: () => cubit.toggleTopicSelection(topic.id),
              );
            },
          ),
          const Spacer(flex: 2),
          const SizedBox(height: 20),
          Center(
            child: Text.rich(
              TextSpan(
                // Estilo padrão para o texto
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  const TextSpan(text: 'por '),
                  TextSpan(
                    text: '${state.timerValue.toInt()}',
                    // Estilo APENAS para o número
                    style: const TextStyle(
                      color: Color.fromARGB(255, 59, 214, 72),
                      fontSize: 24,
                    ), // <-- MUDE A COR AQUI
                  ),
                  const TextSpan(text: ' min'),
                ],
              ),
            ),
          ),
          Slider(
            value: state.timerValue,
            min: 5,
            max: 45,
            divisions: 8,
            label: '${state.timerValue.toInt()}',
            onChanged: (value) => cubit.changeTimer(value),
            // Customizando as cores
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          // Para criar um botão com gradiente
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
              colors: [Color(0xFFBBFF28), Color(0xFF00A862), Color(0xFF005299)], // <-- Suas cores
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedScreen(),
                            ),
                          );
                        },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Pronto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
