import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:select_any/select_any.dart';

/// Cobre a distinção entre [SelectAnyController.dispose] (reset completo,
/// usado quando o controller foi criado pela própria página — descartável)
/// e [SelectAnyController.disposeApenasTimers] (usado quando o controller
/// foi passado por quem criou a página, ex: mantido vivo num controller de
/// tela pai e reaproveitado entre navegações).
///
/// Antes desta correção, `SelectAnyPage.dispose()` sempre chamava o reset
/// completo, mesmo para controllers externos — isso fazia `loaded` voltar
/// pra `false` e o cache do data source ser limpo toda vez que o usuário
/// saía da tela, forçando uma consulta nova completa à API na próxima
/// abertura da mesma lista, mesmo segundos depois.
void main() {
  group('SelectAnyController.disposeApenasTimers (controller externo)', () {
    test('preserva loaded e a lista carregada', () {
      final controller = SelectAnyController();
      controller.loaded = true;
      controller.list = ObservableList.of([ItemSelectTable(position: 1)]);

      controller.disposeApenasTimers();

      expect(controller.loaded, isTrue);
      expect(controller.list, hasLength(1));
    });

    test('preserva o data source já carregado (não zera o cache em memória)',
        () {
      final controller = SelectAnyController();
      final dataSource = _FakeDataSource();
      controller.actualDataSource = dataSource;
      dataSource.listAll = [
        {'id': 1}
      ];

      controller.disposeApenasTimers();

      expect(controller.actualDataSource, same(dataSource));
      expect(dataSource.listAll, isNotNull);
    });
  });

  group('SelectAnyController.dispose (controller próprio da página)', () {
    test('zera loaded e limpa a lista carregada', () {
      final controller = SelectAnyController();
      controller.loaded = true;
      controller.list = ObservableList.of([ItemSelectTable(position: 1)]);

      controller.dispose();

      expect(controller.loaded, isFalse);
      expect(controller.list, isEmpty);
    });
  });
}

class _FakeDataSource extends DataSourceAny {
  @override
  Future<List<Map<String, dynamic>>?> fetchData(
    int? limit,
    int offset,
    SelectModel? selectModel, {
    Map? data,
  }) async {
    return [];
  }
}
