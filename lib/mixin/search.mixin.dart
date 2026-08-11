import 'dart:async';

import 'package:fitnc_user/domain/abstract.domain.dart';
import 'package:fitnc_user/service/util.service.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

///
/// Classe utilitaire pour rechercher dans une liste.
///
/// La mixin s'applique sur un ChangeNotifier pour pouvoir libérer ses propres
/// ressources dans dispose() : sans ça, chaque écran de recherche laissait
/// derrière lui un BehaviorSubject ouvert et un listener actif.
///
mixin SearchMixin<T extends InterfaceDomainSearchable> on ChangeNotifier {
  final BehaviorSubject<List<T>> streamList = BehaviorSubject<List<T>>();
  final List<T> _listComplete = <T>[];
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  StreamSubscription<List<T>>? _sourceSubscription;
  bool _searchInitialized = false;

  void clearSearch() {
    searchQuery.value = '';
  }

  void search(String query) {
    searchQuery.value = query;
  }

  ///
  /// À appeler depuis le constructeur du notifier, jamais depuis un build().
  /// L'appel est idempotent par sécurité : rebrancher les listeners à chaque
  /// rebuild faisait se ré-exécuter la recherche en cascade.
  ///
  void initSearchList({
    Stream<List<T>> Function()? getStreamList,
    Future<List<T>> Function()? getFutureList,
    List<T> Function()? getLocalList,
  }) {
    assert(getStreamList != null || getFutureList != null || getLocalList != null, 'initSearchList called without any parameter. Please provide at least one of these method : getStreamList, getFutureList, getLocalList.');

    if (_searchInitialized) {
      return;
    }
    _searchInitialized = true;

    _fetchList(getStreamList, getFutureList, getLocalList);
    searchQuery.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    UtilService.search(searchQuery.value, _listComplete, streamList);
  }

  void _fetchList(
    Stream<List<T>> Function()? getStreamList,
    Future<List<T>> Function()? getFutureList,
    List<T> Function()? getLocalList,
  ) {
    if (getLocalList != null) {
      _initialization(getLocalList());
      return;
    }

    if (getFutureList != null) {
      getFutureList().then((List<T> listValues) => _initialization(listValues));
      return;
    }

    if (getStreamList != null) {
      _sourceSubscription = getStreamList()
          .listen((List<T> listValues) => _initialization(listValues));
      return;
    }
  }

  void _initialization(List<T> event) {
    if (streamList.isClosed) {
      return;
    }
    _listComplete.clear();
    _listComplete.addAll(event);
    streamList.sink.add(_listComplete);
    UtilService.search(searchQuery.value, _listComplete, streamList);
  }

  @override
  void dispose() {
    _sourceSubscription?.cancel();
    searchQuery.removeListener(_onQueryChanged);
    searchQuery.dispose();
    streamList.close();
    super.dispose();
  }
}
