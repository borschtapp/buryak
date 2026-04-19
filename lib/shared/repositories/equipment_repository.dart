import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/equipment.dart';
import '../models/paginated_list.dart';
import 'repository.dart';

part 'equipment_repository.g.dart';

// ignore: constant_identifier_names
enum EquipmentPreload { total_recipes }

@Riverpod(keepAlive: true)
EquipmentRepository equipmentRepository(Ref ref) => EquipmentRepository(ref: ref, client: ref.watch(httpClientProvider));

class EquipmentRepository extends Repository {
  const EquipmentRepository({required super.ref, super.client}) : super(module: '/api/v1/equipment');

  Future<PaginatedList<Equipment>> findAll({
    List<EquipmentPreload>? preload,
    String? scope,
    String? q,
    String? sort,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'preload': preload?.map((e) => e.name).join(','),
        'scope': ?scope,
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Equipment>.fromJson(
      ensureMap(response),
      (json) => Equipment.fromJson(ensureMap(json)),
    );
  }
}
