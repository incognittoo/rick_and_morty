part of 'character_bloc.dart';

@freezed
class CharacterState with _$CharacterState {
  const factory CharacterState.loading() = CharacterStateLoading;
  const factory CharacterState.loaded({required Character characterLoaded}) =
      CharacterStateLoaded;
  const factory CharacterState.error() = CharacterStateError;

  // этот фабричный конструктор использоваться только при кэширование приложении
  factory CharacterState.fromJson(Map<String, dynamic> json) =>
      _$CharacterStateFromJson(json);
}
