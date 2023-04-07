import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rick_and_morty_lite/bloc/character_bloc.dart';
import 'package:rick_and_morty_lite/data/models/character.dart';
import 'package:rick_and_morty_lite/ui/widgets/custom_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Character _currentCharacter;
  List<Results> _currentResult = [];
  int _currentPage = 1;
  String _currentSearchStr = '';

  final RefreshController _refreshController = RefreshController();
  bool _isPagination = false;

  Timer? searchDebounce;

  @override
  void initState() {
    if (HydratedBloc.storage.toString().isEmpty) {
      if (_currentResult.isEmpty) {
        context
            .read<CharacterBloc>()
            .add(const CharacterEvent.fetch(name: '', page: 1));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(86, 86, 86, 0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintText: 'Search name',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            onChanged: (value) {
              _currentPage =
                  1; // когда мы начинаем поиск, мы начинаем с первой страницы
              _currentResult = []; // мы очищаем перед каждым поиском

// передаем то, что пользователь ввел в поиск.
              _currentSearchStr = value;

// при вводе текста в поиск у нас выполнялся таймеры, далее searchDebounce отменяем таймеры
              searchDebounce?.cancel();

// добавляем таймер, чтобы у нас выполнялся запрос после того как пользователь ввел имя искомого персонажа полностью. (ОПТИМИЗАЦИЯ ПОИСКА)
              searchDebounce = Timer(const Duration(milliseconds: 800), () {
                context.read<CharacterBloc>().add(
                      CharacterEvent.fetch(
                        name: value,
                        page: _currentPage,
                      ),
                    );
              });
            },
          ),
        ),
        Expanded(
          child: state.when(
            loading: () {
              if (!_isPagination) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('Loading...'),
                    ],
                  ),
                );
              } else {
                return _customListView(_currentResult);
              }
            },
            loaded: (characterLoaded) {
              _currentCharacter = characterLoaded;

              if (_isPagination) {
                _currentResult.addAll(_currentCharacter.results);
                _refreshController.loadComplete();
                _isPagination = false;
              } else {
                _currentResult = List.of(_currentCharacter.results);
              }
              return _currentResult.isNotEmpty
                  ? _customListView(_currentResult)
                  : const SizedBox();
            },
            error: () => const Text('Nothing found...'),
          ),
        )
      ],
    );
  }

  Widget _customListView(List<Results> currentResults) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      enablePullDown: false,
      onLoading: () {
        _isPagination = true;
        _currentPage++;
        if (_currentPage <= _currentCharacter.info.pages) {
          context.read<CharacterBloc>().add(CharacterEvent.fetch(
              name: _currentSearchStr, page: _currentPage));
        } else {
          _refreshController.loadNoData();
        }
      },
      child: ListView.separated(
        itemBuilder: ((context, index) {
          final result = currentResults[index];
          return Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 3, bottom: 3),
              child: CustomListTile(result: result));
        }),
        separatorBuilder: (_, index) => const SizedBox(
          height: 5,
        ),
        shrinkWrap: true,
        itemCount: currentResults.length,
      ),
    );
  }
}
