// presentation/blocs/setup_state.dart

// import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/topic.dart';

enum Status { initial, loading, success, error }

class SetupState {
  final Status status;
  final List<Topic> topics;
  final Set<String> selectedTopicIds;
  final double timerValue;

  const SetupState({
    this.status = Status.initial,
    this.topics = const [],
    this.selectedTopicIds = const {},
    this.timerValue = 30.0,
  });

  SetupState copyWith({
    Status? status,
    List<Topic>? topics,
    Set<String>? selectedTopicIds,
    double? timerValue,
  }) {
    return SetupState(
      status: status ?? this.status,
      topics: topics ?? this.topics,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      timerValue: timerValue ?? this.timerValue,
    );
  }
}