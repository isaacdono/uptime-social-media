// Em presentation/screens/initial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/setup_cubic.dart';
import '../blocs/setup_state.dart';
import '../widgets/category_card.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Implementar texto com gradiente
          const Text('Olá, Carlo!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const Text('Do que você está a fim hoje?', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
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
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'por ${state.timerValue.toInt()} min',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Slider(
            value: state.timerValue,
            min: 20,
            max: 40,
            divisions: 2,
            label: '${state.timerValue.toInt()}',
            onChanged: (value) => cubit.changeTimer(value),
          ),
          const SizedBox(height: 20),
          // TODO: Implementar botão com gradiente
          ElevatedButton(
            onPressed: () {
              // Navegar para a próxima tela com os dados do estado
              // final selectedTopics = state.selectedTopicIds;
              // final duration = state.timerValue;
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text('Pronto'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}