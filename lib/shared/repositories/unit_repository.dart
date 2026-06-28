import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/paginated_list.dart';
import '../models/unit.dart';
import 'repository.dart';

part 'unit_repository.g.dart';

@Riverpod(keepAlive: true)
UnitRepository unitRepository(Ref ref) =>
    UnitRepository(ref: ref, client: ref.watch(httpClientProvider));

class UnitRepository extends Repository {
  const UnitRepository({required super.ref, super.client}) : super(module: '/api/v1/units');

  Future<PaginatedList<Unit>> findAll({String? q, int limit = 200, int offset = 0}) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {'q': ?q, 'limit': limit, 'offset': offset},
    );
    return PaginatedList<Unit>.fromJson(
      ensureMap(response),
      (json) => Unit.fromJson(ensureMap(json)),
    );
  }

  Future<Unit> update(String unitId, {required String name}) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$unitId',
      body: {'name': name},
    );
    return Unit.fromJson(ensureMap(response));
  }

  Future<void> merge(String unitId, String mergeIntoId) async {
    await sendRequest(
      method: .post,
      path: '/$unitId/merge',
      body: {'merge_into': mergeIntoId},
    );
  }
}
