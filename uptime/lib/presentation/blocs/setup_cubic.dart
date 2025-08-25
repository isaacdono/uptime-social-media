// presentation/blocs/setup_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/topic.dart';

// Trocamos 'part' por 'import'
import 'setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  SetupCubit() : super(const SetupState());

  Future<void> loadTopics() async {
    emit(state.copyWith(status: Status.loading));

    await Future.delayed(const Duration(seconds: 1));

    try {
      final mockTopics = [
        const Topic(id: '1', name: 'Memes', imageUrl: 'https://i.imgflip.com/1bij.jpg'),
        const Topic(id: '2', name: 'Dancinhas', imageUrl: 'https://img.odcdn.com.br/wp-content/uploads/2022/09/tiktok-assistir-video.jpg'),
        const Topic(id: '3', name: 'Notícias', imageUrl: 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
        const Topic(id: '4', name: 'Vídeos', imageUrl: 'https://images.pexels.com/photos/3227986/pexels-photo-3227986.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
        const Topic(id: '5', name: 'Dicas', imageUrl: 'https://images.unsplash.com/photo-1553095066-5014bc7b7f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1171&q=80'),
        const Topic(id: '6', name: 'Ciência', imageUrl: 'https://plus.unsplash.com/premium_photo-1677567996070-68fa4181775a?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YmlibGlvdGVjYXxlbnwwfHwwfHx8MA%3D%3D'),
      ];

      emit(state.copyWith(status: Status.success, topics: mockTopics));
    } catch (e) {
      emit(state.copyWith(status: Status.error));
    }
  }

  void toggleTopicSelection(String topicId) {
    final currentSelection = Set<String>.from(state.selectedTopicIds);
    if (currentSelection.contains(topicId)) {
      currentSelection.remove(topicId);
    } else {
      currentSelection.add(topicId);
    }
    emit(state.copyWith(selectedTopicIds: currentSelection));
  }

  void changeTimer(double newValue) {
    emit(state.copyWith(timerValue: newValue));
  }
}