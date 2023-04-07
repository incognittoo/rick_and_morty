import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rick_and_morty_lite/data/models/character.dart';
import 'package:rick_and_morty_lite/data/repositories/character_repo.dart';

part 'character_bloc.freezed.dart';
part 'character_bloc.g.dart'; // импортируем при использование кэширования
part 'character_event.dart';
part 'character_state.dart';

// HydratedMixin - мы подключаем тогда, когда нам нужно создать кэширование в приложение
class CharacterBloc extends Bloc<CharacterEvent, CharacterState>
    with HydratedMixin {
  final CharacterRepo characterRepo;
  CharacterBloc({required this.characterRepo})
      : super(const CharacterState.loading()) {
    on<CharacterEventFetch>((event, emit) async {
      emit(const CharacterState.loading());
      try {
        Character _characterLoaded = await characterRepo
            .getCharacter(event.page, event.name)
            .timeout(const Duration(seconds: 5));
        emit(CharacterState.loaded(characterLoaded: _characterLoaded));
      } catch (_) {
        emit(const CharacterState.error());
        rethrow;
      }
    });
  }

  @override
  CharacterState? fromJson(Map<String, dynamic> json) =>
      CharacterState.fromJson(json);
  // TODO: Отвечает за восстановление состоянии

  @override
  Map<String, dynamic>? toJson(CharacterState state) => state.toJson();
  // TODO: Отвечает за сохранение состоянии
}
