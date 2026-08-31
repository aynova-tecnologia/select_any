import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:select_any/select_any.dart';

void main() {
  List<Map<String, dynamic>> data = List.generate(
    45,
    (index) => {'key': 'key$index', 'id': index},
  );
  DataSource dataSource = FontDataAny((_) async => data);

  testWidgets('Test selectFK', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    expect(find.text('title'), findsOneWidget);
    expect(find.text('Toque para selecionar'), findsOneWidget);
  });
  // customTextTitle
  testWidgets('Test selectFK customTitle', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title', 'id', [Line('key')], ctlSelect, dataSource,
            customTitle: Text('My custom title')),
      ),
    ));
    expect(find.text('title'), findsNothing);
    expect(find.text('My custom title'), findsOneWidget);
  });

  testWidgets('Test customLabel', (tester) async {
    SelectFKController ctlSelect = SelectFKController();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title', 'id', [Line('key')], ctlSelect, dataSource,
            defaultLabel: 'My default label'),
      ),
    ));
    expect(find.text('My default label'), findsOneWidget);
  });

  testWidgets('Test selectFK selected obj', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    ctlSelect.obj = {'key': 'Test value 2'};
    await tester.pump();
    expect(find.text('Test value 2'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', customLine: (data) => Text('customValue'))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsNothing);
    expect(find.text('customValue'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', defaultValue: ((data) => 'My default value'))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': null};
    await tester.pump();
    expect(find.text('Test value'), findsNothing);
    expect(find.text('My default value'), findsOneWidget);

    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    expect(find.text('My default value'), findsNothing);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child:
            SelectFKWidget('title', 'id', [Line('key')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': null};
    await tester.pump();
    expect(find.text('Linha vazia'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget('title', 'id',
            [Line('key', enclosure: 'Value: ???')], ctlSelect, dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Value: Test value'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SelectFKWidget(
            'title',
            'id',
            [Line('key', textStyle: (p0) => TextStyle(color: Colors.red))],
            ctlSelect,
            dataSource),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    ctlSelect.inFocus = false;
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    expect((tester.widget(find.text('Test value')) as Text).style?.color?.value,
        Colors.red.value);
    ctlSelect.inFocus = true;
    await tester.pump();
    expect((tester.widget(find.text('Test value')) as Text).style?.color?.value,
        isNot(Colors.red.value));
  });

  /// RadioList
  testWidgets('Test selectFK radioList', (tester) async {
    SelectFKController ctlSelect = SelectFKController();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
              'title', 'id', [Line('key')], ctlSelect, dataSource,
              typeView: TypeView.radioList),
        ),
      ),
    ));
    expect(find.text('key1'), findsOneWidget);
    expect(find.byType(Radio), findsNWidgets(data.length));
  });

  testWidgets('Test selectFK empty List', (tester) async {
    SelectFKController ctlSelect = SelectFKController();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget('title', 'id', [Line('key')], ctlSelect,
              FontDataAny((_) async => []),
              typeView: TypeView.radioList),
        ),
      ),
    ));
    expect(find.text('Lista vazia'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
            'title',
            'id',
            [Line('key')],
            ctlSelect,
            FontDataAny((_) async => []),
            typeView: TypeView.radioList,
            customEmptyList: Text('List is Empty'),
          ),
        ),
      ),
    ));
    expect(find.text('List is Empty'), findsOneWidget);
  });

  testWidgets('Test selectFK clean obj', (tester) async {
    SelectFKController ctlSelect = SelectFKController();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
            'title',
            'id',
            [Line('key')],
            ctlSelect,
            FontDataAny((_) async => data),
          ),
        ),
      ),
    ));
    ctlSelect.obj = {'key': 'Test value'};
    await tester.pump();
    expect(find.text('Test value'), findsOneWidget);
    Widget widgetInkWell = tester.widget(find.byKey(Key('key_inkewell_title')));
    expect(widgetInkWell, isNotNull);
    expect(widgetInkWell.runtimeType, InkWell);
    (widgetInkWell as InkWell).onLongPress!();
    await tester.pump(); // schedule animation
    //expect(find.text('Campo limpo com sucesso'), findsOneWidget);
    expect(ctlSelect.obj, isNull);
  });

  testWidgets('Test selectFK select element list', (tester) async {
    SelectFKController ctlSelect = SelectFKController();
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
              'title', 'id', [Line('key')], ctlSelect, dataSource,
              typeView: TypeView.radioList),
        ),
      ),
    ));
    expect(find.text('Lista vazia'), findsNothing);

    expect(find.byKey(Key('radio_select_0')), findsOneWidget);
    Radio radio = tester.widget(find.byKey(Key('radio_select_0')));
    radio.onChanged!(true);
    await tester.pump();
    expect(ctlSelect.obj, data.first);

    ctlSelect.clear();

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
            'title',
            'id',
            [Line('key')],
            ctlSelect,
            dataSource,
            typeView: TypeView.radioList,
            allowEdit: () async => false,
          ),
        ),
      ),
    ));
    Radio radio2 = tester.widget(find.byKey(Key('radio_select_0')));
    radio2.onChanged!(true);
    await tester.pump();
    expect(ctlSelect.obj, isNull);

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: SingleChildScrollView(
          child: SelectFKWidget(
            'title',
            'id',
            [Line('key')],
            ctlSelect,
            dataSource,
            typeView: TypeView.radioList,
            selectedFK: (data, cb) async {
              return data!['id'] == 2;
            },
          ),
        ),
      ),
    ));
    Radio radio3 = tester.widget(find.byKey(Key('radio_select_0')));
    radio3.onChanged!(true);
    await tester.pump();
    expect(ctlSelect.obj, isNull);

    Radio radio4 = tester.widget(find.byKey(Key('radio_select_2')));
    radio4.onChanged!(true);
    await tester.pump();
    expect(ctlSelect.obj, data[2]);
  });

  /// O SelectModel vive no controller e sobrevive ao rebuild do widget. Quem
  /// consome ele e a tela de listagem: SelectAnyPage tira dai o titulo da
  /// AppBar (`init(_selectModel.title, ...)`) e as colunas exibidas.
  group('SelectModel acompanha o rebuild do widget', () {
    testWidgets('titulo novo chega ao SelectModel que a listagem consome',
        (tester) async {
      SelectFKController ctlSelect = SelectFKController();

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'Placa Julieta', 'id', [Line('key')], ctlSelect, dataSource),
        ),
      ));
      expect(ctlSelect.selectModel!.title, 'Placa Julieta');

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'Placa Bitrem', 'id', [Line('key')], ctlSelect, dataSource),
        ),
      ));

      expect(ctlSelect.selectModel!.title, 'Placa Bitrem');
      expect(find.text('Placa Bitrem'), findsOneWidget);
    });

    testWidgets('customListTitle continua tendo precedencia sobre o title',
        (tester) async {
      SelectFKController ctlSelect = SelectFKController();

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'title', 'id', [Line('key')], ctlSelect, dataSource,
              customListTitle: 'Titulo da listagem'),
        ),
      ));
      expect(ctlSelect.selectModel!.title, 'Titulo da listagem');

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'outro title', 'id', [Line('key')], ctlSelect, dataSource,
              customListTitle: 'Outro titulo da listagem'),
        ),
      ));

      expect(ctlSelect.selectModel!.title, 'Outro titulo da listagem');
    });

    testWidgets('colunas novas chegam ao SelectModel', (tester) async {
      SelectFKController ctlSelect = SelectFKController();

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'title', 'id', [Line('key')], ctlSelect, dataSource),
        ),
      ));
      expect(ctlSelect.selectModel!.lines.map((linha) => linha.key), ['key']);

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget('title', 'id', [Line('key'), Line('id')],
              ctlSelect, dataSource),
        ),
      ));

      expect(
          ctlSelect.selectModel!.lines.map((linha) => linha.key), ['key', 'id']);
    });

    testWidgets('o valor ja selecionado sobrevive ao rebuild', (tester) async {
      SelectFKController ctlSelect = SelectFKController();

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'Placa Julieta', 'id', [Line('key')], ctlSelect, dataSource),
        ),
      ));
      ctlSelect.obj = {'key': 'ABC1234', 'id': 1};
      await tester.pump();

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: SelectFKWidget(
              'Placa Bitrem', 'id', [Line('key')], ctlSelect, dataSource),
        ),
      ));

      expect(ctlSelect.obj, {'key': 'ABC1234', 'id': 1});
      expect(find.text('ABC1234'), findsOneWidget);
    });
  });
}
