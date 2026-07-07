import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:msk_utils/msk_utils.dart';
import 'package:select_any/select_any.dart';

class InsertIntent extends Intent {
  const InsertIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class DoneIntent extends Intent {
  const DoneIntent();
}

// ignore: must_be_immutable
class SelectAnyPage extends StatefulWidget {
  final SelectModel? _selectModel;
  Map? data;
  SelectAnyController? controller;
  late bool _showBackButton;

  SelectAnyPage(
    this._selectModel, {
    this.data,
    this.controller,
    bool? showBackButton,
  }) {
    if (controller == null) {
      controller = SelectAnyController();
    }
    controller!.typeDiplay = UtilsPlatform.isMobile ? 1 : 2;
    controller!.confirmToLoadData = _selectModel!.confirmToLoadData;
    controller!.init(_selectModel!.title, _selectModel!, data);
    _showBackButton = showBackButton ?? !UtilsPlatform.isAndroid;
  }

  @override
  _SelectAnyPageState createState() {
    return _SelectAnyPageState();
  }
}

class _SelectAnyPageState extends State<SelectAnyPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  // indica se está sendo usada a fonte alternativa ou nao
  bool fonteAlternativa = false;
  BuildContext? buildContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller!.dispose();

    /// Caso a pesquisa esteja ativa, desativa ela
    if (widget.controller!.searchIcon.icon == Icons.close) {
      _searchPressed();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller!.dynamicScreen) {
      if (MediaQuery.of(context).size.width > 800) {
        if (widget.controller!.typeDiplay != 2) {
          widget.controller!.typeDiplay = 2;
          _searchPressed();
        }
      } else {
        if (widget.controller!.typeDiplay != 1) {
          widget.controller!.clearFilters(callDataSource: false);
          widget.controller!.typeDiplay = 1;
          if (!(widget.controller!.actualDataSource?.supportPaginate ??
                  false) &&
              widget.controller!.loaded) {
            /// Caso a fonte nao suporte paginação, recarrega os dados
            /// Pois os dados carregados na tabela não são completos
            widget.controller!.setCorretDataSource(offset: -1);
          }
        }
      }
    }
    if (!widget.controller!.confirmToLoadData) {
      carregarDados();
    }
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
              const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.insert): const InsertIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
              const ExportIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              const DoneIntent()
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                  onInvoke: (DismissIntent intent) {
                Navigator.pop(context);
                return;
              }),
              InsertIntent:
                  CallbackAction<InsertIntent>(onInvoke: (InsertIntent intent) {
                if (widget._selectModel!.buttons
                        ?.where((element) => element is ActionSelect)
                        .isNotEmpty ==
                    true) {
                  UtilsWidget.onAction(
                      context,
                      null,
                      null,
                      widget._selectModel!.buttons!
                              .firstWhere((element) => element is ActionSelect)
                          as ActionSelect,
                      widget.data,
                      widget.controller!.reloadData,
                      widget.controller!.actualDataSource);
                }
                return;
              }),
              SearchIntent:
                  CallbackAction<SearchIntent>(onInvoke: (SearchIntent intent) {
                if (widget.controller!.typeDiplay == 1) {
                  _searchPressed();
                }
                widget.controller!.focusNodeSearch.requestFocus();

                return;
              }),
              ExportIntent:
                  CallbackAction<ExportIntent>(onInvoke: (ExportIntent intent) {
                if (widget.controller!.actualDataSource?.allowExport == true) {
                  widget.controller!.export(context);
                }
                return;
              }),
              DoneIntent:
                  CallbackAction<DoneIntent>(onInvoke: (DoneIntent intent) {
                onDone();
                return;
              })
            },
            child: Focus(
                autofocus: true,
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: widget
                        .controller!.selectModel!.theme.appBarBackgroundColor,
                    centerTitle:
                        widget.controller!.selectModel!.theme.centerTitle,
                    title: Observer(
                        builder: (_) => widget.controller!.appBarTitle!),
                    actions: [
                      Observer(builder: (_) {
                        if (widget.controller!.typeDiplay == 1) {
                          return Container(
                            padding: widget.controller!.selectModel!.theme
                                .paddingAppBarActions,
                            child: Row(children: [
                              IconButton(
                                  splashRadius: 24,
                                  onPressed: () {
                                    showDialogSorts(context);
                                  },
                                  icon: Icon(Icons.sort)),
                              if (_buildRefreshButton() != null)
                                _buildRefreshButton()!,
                              IconButton(
                                splashRadius: 24,
                                icon: widget.controller!.searchIcon,
                                onPressed: _searchPressed,
                              )
                            ]),
                          );
                        } else {
                          return Container(
                              padding: widget.controller!.selectModel!.theme
                                  .paddingAppBarActions,
                              child: Row(children: _buildIconButtons()));
                        }
                      })
                    ],
                    automaticallyImplyLeading: false,
                    leading: _getMenuButton(),
                  ),
                  bottomNavigationBar: widget._selectModel!.typeSelect ==
                              TypeSelect.MULTIPLE &&
                          widget._selectModel!.bottomActionForTypeSelectMULTIPLE
                      ? BottomNavigationBar(
                          selectedItemColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          onTap: (pos) {
                            onDone();
                          },
                          items: <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                                icon: SizedBox(), label: ''),
                            BottomNavigationBarItem(
                                icon: Icon(Icons.done), label: 'Concluído'),
                          ],
                        )
                      : null,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endDocked,
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      direction: Axis.horizontal,
                      runAlignment: WrapAlignment.end,
                      children: _getFloatingActionButtons(),
                    ),
                  ),
                  backgroundColor:
                      widget.controller!.selectModel!.theme.backgroundColor,
                  body: Builder(builder: (buildContext) {
                    this.buildContext = buildContext;
                    return _getBody();
                  }),
                ))));
  }

  void onDone() {
    Navigator.pop(context, widget.controller!.selectedList.toList());
  }

  List<Widget> _buildIconButtons() {
    List<Widget> buttons = [];
    if (widget.controller!.selectModel!.buttons != null) {
      for (ActionSelectBase action
          in widget.controller!.selectModel!.buttons!) {
        if ((action.buttonPosition ??
                    widget._selectModel!.theme.defaultButtonPosition)
                .call((widget.controller!.typeDiplay)) ==
            ButtonPosition.APPBAR) {
          buttons.add(action.build(ButtonPosition.APPBAR, () {
            UtilsWidget.onAction(
                context,
                null,
                null,
                action as ActionSelect,
                widget.controller!.data,
                widget.controller!.reloadData,
                widget.controller!.actualDataSource);
          }));
        }
      }
    }
    return buttons;
  }

  /// Retorna o conteúdo principal da tela
  Widget _getBody() {
    return Observer(builder: (_) {
      if (widget.controller!.typeDiplay == 2) {
        return TableDataWidget(widget._selectModel!,
            controller: widget.controller!, loadData: false);
      } else {
        if (!widget.controller!.confirmToLoadData == true) {
          return _getListBuilder();
        } else {
          return Center(
              child: TextButton.icon(
                  icon: Icon(Icons.sync),
                  label: Text('Carregar dados'),
                  onPressed: () {
                    /// Aqui é vantagem usar o setState, pois toda a tela precisa ser recarregada
                    setState(() {
                      widget.controller!.confirmToLoadData = false;
                      carregarDados();
                    });
                  }));
        }
      }
    });
  }

  Widget _buildListStatusBar() {
    return Observer(builder: (_) {
      final int shown = widget.controller!.showList.length;
      final int total = widget.controller!.total;
      final String countLabel = total > 0
          ? 'Exibindo $shown de $total registros'
          : 'Exibindo $shown registros';
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(countLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis),
            ),
            if (widget.controller!.isShowingCachedData)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('Dados offline',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.orange)),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _getListBuilder() {
    return Observer(builder: (_) {
      /// Só exibe o skeleton de tela cheia no primeiro carregamento (sem
      /// dados ainda em tela). Quando já existem itens carregados (refresh
      /// ou paginação via scroll), mantém a lista atual visível — evitando
      /// que a tela "pisque" e o scroll volte para o topo — e sinaliza o
      /// carregamento apenas com um spinner (ver rodapé da lista).
      if (widget.controller!.loading == true &&
          widget.controller!.list.isEmpty) {
        if (!widget.controller!.showLoadingSkeleton) {
          return const SizedBox();
        }
        return _buildListSkeleton();
      }
      if (widget.controller!.error != null) {
        if (widget._selectModel!.alternativeDataSource != null &&
            widget.controller!.actualDataSource !=
                widget._selectModel!.alternativeDataSource) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            //usa esse artefato para nao dar problema com o setstate
            widget.controller!.loaded = false;

            setState(() async {
              widget.controller!.actualDataSource =
                  widget._selectModel!.alternativeDataSource;
              widget.controller!.setDataSource(
                  offset: widget.controller!.typeDiplay == 1 ? -1 : 0);
              carregarDados();
            });
          });
          return new Center(child: new RefreshProgressIndicator());
        }
        return FailWidget(
          'Houve uma falha ao recuperar os dados',
          error: widget.controller!.error,
        );
      }
      //_gerarLista((snapshot.data as ResponseData).data);
      return Observer(builder: (_) {
        if (widget.controller!.showList.isEmpty == true)
          return Center(child: new Text('Nenhum registro encontrado'));
        else {
          return Column(
            children: [
              if (widget.controller!.actualDataSource!.supportPaginate)
                _buildListStatusBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    widget.controller!.reloadData();
                  },
                  key: _refreshIndicatorKey,
                  child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        /// não é necessário nenhuma ação caso não suporte paginação, pois os dados já estaram completos na tela
                        if (widget
                            .controller!.actualDataSource!.supportPaginate) {
                          /// Dispara a busca da próxima página um pouco antes do fim da lista
                          /// (aproximadamente duas telas de antecedência), para que o conteúdo
                          /// já esteja carregado quando o usuário chegar lá.
                          final double prefetchThreshold =
                              scrollInfo.metrics.viewportDimension * 2;
                          if (scrollInfo is ScrollEndNotification &&
                              scrollInfo.metrics.extentAfter <
                                  prefetchThreshold &&
                              !widget.controller!.loadingMore) {
                            if (widget.controller!.total == 0 ||
                                widget.controller!.page *
                                        widget.controller!.quantityItensPage <=
                                    widget.controller!.total) {
                              if (widget.controller!.searchText.isEmpty) {
                                widget.controller!.loadingMore = true;
                                widget.controller!.page++;
                                widget.controller!.setDataSource();
                              } else {
                                widget.controller!.loadingMore = true;
                                widget.controller!.page++;
                                widget.controller!.setDataSourceSearch();
                              }
                              debugPrint('Carregar mais dados');
                            } else {
                              widget.controller!.loadingMore = false;
                              debugPrint('Não carregar mais');
                              debugPrint(
                                  widget.controller!.list.length.toString());
                            }
                          }
                        }
                        return true;
                      },
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                            itemCount: widget.controller!.showList.length,
                            itemBuilder: (context, index) {
                              return Observer(
                                  builder: (_) => _getItemList(
                                      widget.controller!.showList[index],
                                      index));
                            }),
                      )),
                ),
              ),
              Observer(builder: (_) {
                /// Cobre tanto o "carregar mais" via scroll quanto um
                /// refresh em andamento com dados já em tela (nesse caso
                /// não há skeleton de tela cheia, ver `_getListBuilder`).
                if (widget.controller!.loadingMore ||
                    widget.controller!.loading) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                return SizedBox();
              }),
              if (widget._selectModel!.listBottomBuilder != null)
                widget._selectModel!.listBottomBuilder!(CustomBottomBuilderArgs(
                    context,
                    widget.controller!.actualFilters ??
                        widget.controller!.buildFilterExpression(),
                    widget.controller!.loaded,
                    widget.controller!.actualDataSource,
                    widget.controller!.list))
            ],
          );
        }
      });
    });
  }

  void _searchPressed() {
    if (widget.controller!.searchIcon.icon == Icons.search &&
        widget.controller!.typeDiplay == 1) {
      widget.controller!.searchIcon = Icon(Icons.close);
      widget.controller!.appBarTitle = Container(
        alignment: Alignment.topRight,
        constraints: BoxConstraints(maxWidth: 300),
        child: TextField(
          focusNode: widget.controller!.focusNodeSearch,
          controller: widget.controller!.filter,
          autofocus: true,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Pesquise...'),
          onChanged: (text) {
            widget.controller!.filterChanged();
          },
          onSubmitted:
              widget.controller!.selectModel!.dataSource.allowOnSubmittSearch
                  ? (_) {
                      widget.controller!.onSubmittedSearch();
                    }
                  : null,
        ),
      );
    } else {
      widget.controller!.searchIcon = new Icon(Icons.search);
      widget.controller!.appBarTitle = new Text(widget._selectModel!.title);
      if (widget.controller!.filter.text.isNotEmpty ||
          widget.controller!.searchText.isNotEmpty) {
        widget.controller!.searchText = '';
        widget.controller!.filter.clear();
        widget.controller!.filterChanged(reload: true);
      }
    }
  }

  Widget _buildListSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      separatorBuilder: (_, __) => widget._selectModel!.showInCards == true
          ? const SizedBox(height: 0)
          : const Divider(height: 1),
      itemBuilder: (_, __) => widget._selectModel!.showInCards == true
          ? _buildSkeletonCardItem()
          : _buildSkeletonListTileItem(),
    );
  }

  Widget _buildSkeletonCardItem() {
    final Color baseColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.18);
    final Color highlightColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.10);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSkeletonTextLines(
            lineCount: widget._selectModel!.lines.length.clamp(2, 5),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonListTileItem() {
    final Color baseColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.18);
    final Color highlightColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.10);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: ListTile(
        leading: widget._selectModel!.typeSelect == TypeSelect.MULTIPLE
            ? Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : null,
        title: _buildSkeletonLine(
          width: 160,
          color: baseColor,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSkeletonTextLines(
            lineCount: (widget._selectModel!.lines.length - 1).clamp(1, 3),
            baseColor: highlightColor,
            highlightColor: highlightColor,
            topSpacing: 10,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSkeletonTextLines({
    required int lineCount,
    required Color baseColor,
    required Color highlightColor,
    double topSpacing = 12,
  }) {
    final List<double> widths = <double>[160, double.infinity, 220, 180, 140];
    final List<Widget> widgets = <Widget>[];
    for (int index = 0; index < lineCount; index++) {
      if (index > 0) {
        widgets.add(SizedBox(height: index == 1 ? topSpacing : 8));
      }
      widgets.add(_buildSkeletonLine(
        width: widths[index.clamp(0, widths.length - 1)],
        color: index == 0 ? baseColor : highlightColor,
      ));
    }
    return widgets;
  }

  Widget _buildSkeletonLine({
    required double width,
    required Color color,
    double height = 14,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _getItemList(ItemSelect itemSelect, int index) {
    if (widget._selectModel!.showInCards != true) {
      return new Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: ListTile(
            leading: widget._selectModel!.typeSelect == TypeSelect.MULTIPLE
                ? Checkbox(
                    onChanged: (newValue) {
                      widget.controller!
                          .updateSelectItem(itemSelect, newValue ?? true);
                    },
                    value: itemSelect.isSelected)
                : null,
            title: _getLinha(
                    itemSelect.strings.entries.first, itemSelect.object) ??
                SizedBox(),
            subtitle: (itemSelect.strings.length > 1)
                ? _getLinha(
                    itemSelect.strings.entries.toList()[1], itemSelect.object)
                : null,
            onTap: () async {
              UtilsWidget.cbOnTap(
                  context, itemSelect, index, widget.controller!);
            },
            onLongPress: () {
              UtilsWidget.tratarOnLongPres(
                  context, itemSelect, index, widget.controller!);
            },
          ));
    } else {
      return Card(
        child: InkWell(
          onTap: () {
            UtilsWidget.cbOnTap(context, itemSelect, index, widget.controller!);
          },
          onLongPress: () {
            UtilsWidget.tratarOnLongPres(
                context, itemSelect, index, widget.controller!);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget._selectModel!.typeSelect == TypeSelect.MULTIPLE
                ? Row(
                    children: [
                      Checkbox(
                        onChanged: (newValue) {
                          widget.controller!
                              .updateSelectItem(itemSelect, newValue ?? true);
                        },
                        value: itemSelect.isSelected,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _getTexts(itemSelect.strings, itemSelect.object),
                      )),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getTexts(itemSelect.strings, itemSelect.object),
                  ),
          ),
        ),
      );
    }
  }

  Widget? _getLinha(MapEntry item, Map? map) {
    Line? linha = widget._selectModel!.lines
        .firstWhereOrNull((linha) => linha.key == item.key);
    if (linha == null) {
      return null;
    }
    dynamic valor = (item.value == null || item.value.toString().isEmpty)
        ? (linha.defaultValue != null ? linha.defaultValue!(map) : item.value)
        : item.value;
    ObjFormatData objFormatData = ObjFormatData(data: valor, map: map);

    if (linha.formatData != null) {
      valor = linha.formatData!.formatData(objFormatData);
    } else if (linha.typeData is TDDateTimestamp && linha.customLine == null) {
      try {
        valor = DateTime.fromMillisecondsSinceEpoch(int.tryParse(valor)!)
            .string((linha.typeData as TDDateTimestamp).outputFormat);
        if (linha.enclosure == null) {
          linha.enclosure = '${linha.name}: ???';
        }
      } catch (_) {}
    }

    if ((linha.enclosure != null || linha.customLine != null)) {
      if (linha.customLine != null) {
        return linha.customLine!(CustomLineData(
            data: map, typeScreen: widget.controller!.typeDiplay));
      }
      return Text(linha.enclosure!.replaceAll('???', valor?.toString() ?? ''),
          style: linha.textStyle?.call(objFormatData) ??
              widget.controller!.selectModel!.theme.defaultTextStyle);
    } else {
      if ((valor == null || valor.toString().isEmpty) &&
          linha.showSizedBoxWhenEmpty == true) {
        return SizedBox();
      }
      return Text(valor?.toString() ?? '',
          style: linha.textStyle?.call(objFormatData) ??
              widget.controller!.selectModel!.theme.defaultTextStyle);
    }
  }

  List<Widget> _getTexts(Map<String, dynamic> map, Map? object) {
    List<Widget> widgets = [];
    for (var item in map.entries) {
      Widget? widget = _getLinha(item, object);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }

  Widget? _getMenuButton() {
    if (widget._showBackButton) {
      return IconButton(
        icon: UtilsPlatform.isIOS || UtilsPlatform.isMacos
            ? Icon(Icons.arrow_back_ios)
            : Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    } else
      return null;
  }

  List<Widget> _getFloatingActionButtons() {
    List<Widget> widgets = [];
    if (!(widget._selectModel!.buttons?.isEmpty ?? true)) {
      for (ActionSelectBase action in widget._selectModel!.buttons!) {
        if ((action.buttonPosition ??
                    widget._selectModel!.theme.defaultButtonPosition)
                .call((widget.controller!.typeDiplay)) ==
            ButtonPosition.BOTTOM) {
          widgets.add(action.build(ButtonPosition.BOTTOM, () {
            UtilsWidget.onAction(
                context,
                null,
                null,
                action as ActionSelect,
                widget.controller!.data,
                widget.controller!.reloadData,
                widget.controller!.actualDataSource);
          }));
        }
      }
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  Widget? _buildRefreshButton() {
    if (widget._selectModel!.showRefreshButton != true) {
      return null;
    }
    return IconButton(
      splashRadius: 24,
      tooltip: 'Atualizar',
      icon: const Icon(Icons.refresh),
      onPressed: () {
        widget.controller!.reloadData();
      },
    );
  }

  void carregarDados() async {
    if (!widget.controller!.loaded) {
      final Map? args =
          ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>?;
      if (args?.containsKey('data') ?? false) {
        if (widget.data == null) {
          widget.data = Map();
        }
        widget.data!.addAll(args!['data']);
      }
      widget.controller!.data = widget.data;
      widget.controller!.actualDataSource = widget._selectModel!.dataSource;
      widget.controller!
          .setDataSource(offset: widget.controller!.typeDiplay == 1 ? -1 : 0);
      widget.controller!.loaded = true;
    }
    if (widget._selectModel!.openSearchAutomatically == true) {
      _searchPressed();
    }
  }

  void showDialogSorts(BuildContext context) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Ordenar por'),
              content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.controller!.selectModel!.lines
                        .where((element) => element.enableSorting)
                        .map((e) => ListTile(
                              onTap: () {
                                EnumTypeSort typeSort = EnumTypeSort.ASC;
                                if (widget.controller!.itemSort != null &&
                                    widget.controller!.itemSort!.line!.key ==
                                        e.key) {
                                  if (widget.controller!.itemSort!.typeSort ==
                                      EnumTypeSort.ASC) {
                                    typeSort = EnumTypeSort.DESC;
                                  }
                                }
                                widget.controller!.itemSort = ItemSort(
                                    indexLine: widget
                                        .controller!.selectModel!.lines
                                        .indexWhere(
                                            (element) => element.key == e.key),
                                    line: e,
                                    typeSort: typeSort);

                                widget.controller!.updateSortCollumn();
                                Navigator.pop(alertContext);
                              },
                              title: Text(e.name ?? e.key),
                              leading: widget.controller!.itemSort?.line?.key ==
                                      e.key
                                  ? (widget.controller!.itemSort!.typeSort ==
                                          EnumTypeSort.ASC
                                      ? Icon(Icons.arrow_upward)
                                      : Icon(Icons.arrow_downward))
                                  : null,
                            ))
                        .toList()),
              ),
            ));
  }
}
