import '../models/bottle_collection_model.dart';
import '../../core/constants/mock_data.dart';

/// Abstract bottle collection repository — swap for Supabase later.
abstract class BottleRepository {
  Future<List<BottleCollectionModel>> fetchPendingCollections();
  Future<BottleCollectionModel> markCollected(String id);
}

class MockBottleRepository implements BottleRepository {
  final List<BottleCollectionModel> _collections =
      List.from(MockData.bottleCollections);

  @override
  Future<List<BottleCollectionModel>> fetchPendingCollections() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_collections);
  }

  @override
  Future<BottleCollectionModel> markCollected(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _collections.indexWhere((b) => b.id == id);
    if (index != -1) {
      _collections[index] = _collections[index].copyWith(
        isCollected: true,
        collectionDate: DateTime.now(),
      );
      return _collections[index];
    }
    throw Exception('Bottle collection not found: $id');
  }
}
