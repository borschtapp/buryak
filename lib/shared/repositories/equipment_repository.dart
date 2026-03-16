import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/equipment.dart';
import '../models/paginated_list.dart';

part 'equipment_repository.g.dart';

@Riverpod(keepAlive: true)
EquipmentRepository equipmentRepository(Ref ref) => EquipmentRepository(ref: ref);

class EquipmentRepository extends Repository {
  const EquipmentRepository({required super.ref}) : super(module: '/api/v1/equipment');

  Future<PaginatedList<Equipment>> search({
    String? q,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'q': ?q,
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