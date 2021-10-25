import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:msk_utils/models/item_select.dart';
import 'package:select_any/src/models/models.dart';
import 'package:select_any/src/modules/select_any_expanded/select_any_expanded_controller.dart';

// ignore: must_be_immutable
class SelectAnyExpandedPage extends StatefulWidget {
  final SelectModel _selectModel;
  final ObservableList<ItemSelectExpanded> itens;
  Map data;

  SelectAnyExpandedPage(this._selectModel, this.itens, {this.data});

  @override
  _SelectAnyExpandedPageState createState() {
    return _SelectAnyExpandedPageState(_selectModel.title, itens);
  }
}

class _SelectAnyExpandedPageState extends State<SelectAnyExpandedPage> {
  SelectAnyExpandedController controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;

  // indica se está sendo usada a fonte alternativa ou nao
  bool fonteAlternativa = false;
  BuildContext buildContext;

  _SelectAnyExpandedPageState(
      String title, ObservableList<ItemSelectExpanded> itens) {
    controller = SelectAnyExpandedController(title, itens);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //widget._selectModel.fonteDados.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Observer(builder: (_) => controller.appBarTitle),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _getFloatingActionButtons(),
        ),
      ),
      body: Builder(builder: (buildContext) {
        this.buildContext = buildContext;
        return _getBody();
      }),
    );
  }

  /// Retorna o conteúdo principal da tela
  Widget _getBody() {
    if (controller.listaExibida.isEmpty == true)
      return Center(child: new Text('Nenhum registro encontrado'));
    else
      return RefreshIndicator(
        onRefresh: () async {},
        key: _refreshIndicatorKey,
        child: new ListView.builder(
            itemCount: controller.listaExibida.length,
            itemBuilder: (context, index) {
              return Observer(
                  builder: (_) => _getItemList(controller.listaExibida[index]));
            }),
      );
  }

  Widget _getItemList(ItemSelectExpanded itemSelect) {
    return Card(
      child: InkWell(
        onTap: () {
          if (itemSelect.items?.isNotEmpty != true) {
            _tratarOnTap(itemSelect);
          } else {
            itemSelect.isExpanded = !itemSelect.isExpanded;
          }
        },
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _getTexts(itemSelect.strings, itemSelect.object),
                    )),
                    if (itemSelect.items?.isNotEmpty == true)
                      IconButton(
                          splashRadius: 24,
                          icon: Icon(Icons.expand_more),
                          onPressed: () {
                            itemSelect.isExpanded = !itemSelect.isExpanded;
                          })
                  ],
                ),
                Observer(builder: (_) {
                  if (itemSelect.isExpanded) {
                    return Column(
                        children: itemSelect.items
                            .map((element) => _getItemList(element))
                            .toList());
                  } else {
                    return SizedBox();
                  }
                })
              ],
            )),
      ),
    );
  }

  Widget _getLinha(MapEntry item, Map map) {
    Line linha = widget._selectModel.lines
        .firstWhere((linha) => linha.key == item.key, orElse: () => null);
    if (linha == null) {
      return null;
    }
    dynamic valor = (item.value == null || item.value.toString().isEmpty)
        ? (linha.defaultValue != null ? linha.defaultValue(map) : '')
        : item.value;
    if (linha.formatData != null) {
      valor = linha.formatData.formatData(ObjFormatData(data: valor, map: map));
    }
    if (linha != null &&
        (linha.enclosure != null || linha.customLine != null)) {
      if (linha.customLine != null) {
        return linha.customLine(CustomLineData(data: map));
      }
      return Text(linha.enclosure.replaceAll('???', valor),
          style: linha.textStyle(ObjFormatData(data: valor, map: map)));
    } else {
      return Text(valor?.toString(),
          style: linha.textStyle(ObjFormatData(data: valor, map: map)));
    }
  }

  List<Widget> _getTexts(Map<String, dynamic> map, Map object) {
    List<Widget> widgets = [];
    for (var item in map.entries) {
      Widget widget = _getLinha(item, object);
      if (widget != null) {
        widgets.add(widget);
      }
    }
    return widgets;
  }

  void _onAction(ItemSelect itemSelect, ActionSelect acao) async {
    if (acao.function != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }
      acao.function(DataFunction(data: itemSelect, context: context));
    }
    if (acao.functionUpd != null) {
      if (acao.closePage) {
        Navigator.pop(context);
      }

      var res = await acao
          .functionUpd(DataFunction(data: itemSelect, context: context));
      if (res == true) {
        loaded = false;
      }
    } else if (acao.route != null || acao.page != null) {
      Map<String, dynamic> dados = Map();
      if (acao.keys?.entries != null) {
        for (MapEntry dado in acao.keys.entries) {
          if (itemSelect != null &&
              (itemSelect.object as Map).containsKey(dado.key)) {
            dados.addAll({dado.value: itemSelect.object[dado.key]});
          } else if (widget.data.containsKey(dado.key)) {
            dados.addAll({dado.value: widget.data[dado.key]});
          }
        }
      }

      RouteSettings settings = (itemSelect != null || dados.isNotEmpty)
          ? RouteSettings(arguments: {
              'cod_obj': itemSelect?.id,
              'obj': itemSelect?.object,
              'data': dados,
            })
          : RouteSettings();

      var res = await Navigator.of(context).push(acao.route != null
          ? acao.route
          : new MaterialPageRoute(
              builder: (_) => acao.page(), settings: settings));
      if (acao.closePage) {
        if (res != null) {
          if (res is Map &&
              res['dados'] != null &&
              res['dados'] is Map &&
              res['dados'].isNotEmpty) {
            Navigator.pop(context, res['dados']);
          }
          if (res is Map &&
              res['data'] != null &&
              res['data'] is Map &&
              res['data'].isNotEmpty) {
            Navigator.pop(context, res['data']);
          } else {
            Navigator.pop(context, res);
          }
        }
      }
    }
  }

  List<Widget> _getFloatingActionButtons() {
    List<Widget> widgets = [];
    // if (!(widget._selectModel.filtros?.isEmpty ?? true)) {
    //   widgets.add(FloatingActionButton(
    //       heroTag: widgets.length,
    //       onPressed: () async {
    //         Map<String, List<String>> s = await Navigator.of(context).push(
    //             new MaterialPageRoute(
    //                 builder: (BuildContext context) =>
    //                     new FiltroPage(widget._selectModel.filtros)));
    //         if (widget.data == null) {
    //           widget.data = Map();
    //         }
    //         widget.data['filtros'] = s;
    //       },
    //       mini: (!(widget._selectModel.acoes?.isEmpty ?? true)),
    //       child: Icon(Icons.filter_list)));
    // }
    if (!(widget._selectModel.buttons?.isEmpty ?? true)) {
      for (ActionSelect acao in widget._selectModel.buttons) {
        widgets.add(FloatingActionButton(
          heroTag: widgets.length,
          mini: widgets.isNotEmpty,
          tooltip: acao.description,
          onPressed: () {
            _onAction(null, acao);
          },
          child: acao.icon ?? Icon(Icons.add),
        ));
      }
    }
    widgets = widgets.reversed.toList();
    return widgets;
  }

  void _exibirListaAcoes(ItemSelect itemSelect) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: widget._selectModel.actions
                  .map((acao) => new ListTile(
                      title: new Text(acao.description),
                      onTap: () {
                        Navigator.pop(context);
                        _onAction(itemSelect, acao);
                      }))
                  .toList(),
            ),
          );
        });
  }

  void _tratarOnTap(ItemSelect itemSelect) {
    if (widget._selectModel.typeSelect == TypeSelect.ACTION &&
        widget._selectModel.actions != null) {
      if (widget._selectModel.actions.length > 1) {
        _exibirListaAcoes(itemSelect);
      } else if (widget._selectModel.actions.isNotEmpty) {
        ActionSelect acao = widget._selectModel.actions?.first;
        if (acao != null) {
          _onAction(itemSelect, acao);
        }
      }
    } else if (widget._selectModel.typeSelect == TypeSelect.SIMPLE) {
      Navigator.pop(context, itemSelect.object);
    } else if (widget._selectModel.typeSelect == TypeSelect.MULTIPLE) {
      itemSelect.isSelected = !itemSelect.isSelected;
    }
  }
}
