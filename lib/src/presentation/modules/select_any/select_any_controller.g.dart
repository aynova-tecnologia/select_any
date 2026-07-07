// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_any_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SelectAnyController on _SelectAnyBase, Store {
  Computed<ObservableList<ItemSelectTable>>? _$showListComputed;

  @override
  ObservableList<ItemSelectTable> get showList => (_$showListComputed ??=
          Computed<ObservableList<ItemSelectTable>>(() => super.showList,
              name: '_SelectAnyBase.showList'))
      .value;

  late final _$typeDiplayAtom =
      Atom(name: '_SelectAnyBase.typeDiplay', context: context);

  @override
  int get typeDiplay {
    _$typeDiplayAtom.reportRead();
    return super.typeDiplay;
  }

  @override
  set typeDiplay(int value) {
    _$typeDiplayAtom.reportWrite(value, super.typeDiplay, () {
      super.typeDiplay = value;
    });
  }

  late final _$searchTextAtom =
      Atom(name: '_SelectAnyBase.searchText', context: context);

  @override
  String get searchText {
    _$searchTextAtom.reportRead();
    return super.searchText;
  }

  @override
  set searchText(String value) {
    _$searchTextAtom.reportWrite(value, super.searchText, () {
      super.searchText = value;
    });
  }

  late final _$searchIconAtom =
      Atom(name: '_SelectAnyBase.searchIcon', context: context);

  @override
  Icon get searchIcon {
    _$searchIconAtom.reportRead();
    return super.searchIcon;
  }

  @override
  set searchIcon(Icon value) {
    _$searchIconAtom.reportWrite(value, super.searchIcon, () {
      super.searchIcon = value;
    });
  }

  late final _$appBarTitleAtom =
      Atom(name: '_SelectAnyBase.appBarTitle', context: context);

  @override
  Widget? get appBarTitle {
    _$appBarTitleAtom.reportRead();
    return super.appBarTitle;
  }

  @override
  set appBarTitle(Widget? value) {
    _$appBarTitleAtom.reportWrite(value, super.appBarTitle, () {
      super.appBarTitle = value;
    });
  }

  late final _$confirmToLoadDataAtom =
      Atom(name: '_SelectAnyBase.confirmToLoadData', context: context);

  @override
  bool get confirmToLoadData {
    _$confirmToLoadDataAtom.reportRead();
    return super.confirmToLoadData;
  }

  @override
  set confirmToLoadData(bool value) {
    _$confirmToLoadDataAtom.reportWrite(value, super.confirmToLoadData, () {
      super.confirmToLoadData = value;
    });
  }

  late final _$pageAtom = Atom(name: '_SelectAnyBase.page', context: context);

  @override
  int get page {
    _$pageAtom.reportRead();
    return super.page;
  }

  @override
  set page(int value) {
    _$pageAtom.reportWrite(value, super.page, () {
      super.page = value;
    });
  }

  late final _$totalAtom = Atom(name: '_SelectAnyBase.total', context: context);

  @override
  int get total {
    _$totalAtom.reportRead();
    return super.total;
  }

  @override
  set total(int value) {
    _$totalAtom.reportWrite(value, super.total, () {
      super.total = value;
    });
  }

  late final _$listAtom = Atom(name: '_SelectAnyBase.list', context: context);

  @override
  ObservableList<ItemSelectTable> get list {
    _$listAtom.reportRead();
    return super.list;
  }

  @override
  set list(ObservableList<ItemSelectTable> value) {
    _$listAtom.reportWrite(value, super.list, () {
      super.list = value;
    });
  }

  late final _$loadingAtom =
      Atom(name: '_SelectAnyBase.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$loadedAtom =
      Atom(name: '_SelectAnyBase.loaded', context: context);

  @override
  bool get loaded {
    _$loadedAtom.reportRead();
    return super.loaded;
  }

  @override
  set loaded(bool value) {
    _$loadedAtom.reportWrite(value, super.loaded, () {
      super.loaded = value;
    });
  }

  late final _$quantityItensPageAtom =
      Atom(name: '_SelectAnyBase.quantityItensPage', context: context);

  @override
  int get quantityItensPage {
    _$quantityItensPageAtom.reportRead();
    return super.quantityItensPage;
  }

  @override
  set quantityItensPage(int value) {
    _$quantityItensPageAtom.reportWrite(value, super.quantityItensPage, () {
      super.quantityItensPage = value;
    });
  }

  late final _$loadingMoreAtom =
      Atom(name: '_SelectAnyBase.loadingMore', context: context);

  @override
  bool get loadingMore {
    _$loadingMoreAtom.reportRead();
    return super.loadingMore;
  }

  @override
  set loadingMore(bool value) {
    _$loadingMoreAtom.reportWrite(value, super.loadingMore, () {
      super.loadingMore = value;
    });
  }

  late final _$isShowingCachedDataAtom =
      Atom(name: '_SelectAnyBase.isShowingCachedData', context: context);

  @override
  bool get isShowingCachedData {
    _$isShowingCachedDataAtom.reportRead();
    return super.isShowingCachedData;
  }

  @override
  set isShowingCachedData(bool value) {
    _$isShowingCachedDataAtom.reportWrite(value, super.isShowingCachedData, () {
      super.isShowingCachedData = value;
    });
  }

  late final _$showSearchAtom =
      Atom(name: '_SelectAnyBase.showSearch', context: context);

  @override
  bool get showSearch {
    _$showSearchAtom.reportRead();
    return super.showSearch;
  }

  @override
  set showSearch(bool value) {
    _$showSearchAtom.reportWrite(value, super.showSearch, () {
      super.showSearch = value;
    });
  }

  late final _$actualFiltersAtom =
      Atom(name: '_SelectAnyBase.actualFilters', context: context);

  @override
  GroupFilterExp? get actualFilters {
    _$actualFiltersAtom.reportRead();
    return super.actualFilters;
  }

  @override
  set actualFilters(GroupFilterExp? value) {
    _$actualFiltersAtom.reportWrite(value, super.actualFilters, () {
      super.actualFilters = value;
    });
  }

  @override
  String toString() {
    return '''
typeDiplay: ${typeDiplay},
searchText: ${searchText},
searchIcon: ${searchIcon},
appBarTitle: ${appBarTitle},
confirmToLoadData: ${confirmToLoadData},
page: ${page},
total: ${total},
list: ${list},
loading: ${loading},
loaded: ${loaded},
quantityItensPage: ${quantityItensPage},
loadingMore: ${loadingMore},
isShowingCachedData: ${isShowingCachedData},
showSearch: ${showSearch},
actualFilters: ${actualFilters},
showList: ${showList}
    ''';
  }
}
