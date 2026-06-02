import '../../cart/models/product_review.dart';
import '../../home/models/home_catalog_data.dart';

abstract class CatalogRepository {
  Future<List<HomeProductSectionData>> getProductSections();
  Future<List<ProductReview>> getProductReviews(String productName);
  Future<void> addProductReview(ProductReview review);
}

class MockCatalogRepository implements CatalogRepository {
  final List<ProductReview> _reviews = [];

  @override
  Future<List<HomeProductSectionData>> getProductSections() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return HomeCatalogData.productSections;
  }

  @override
  Future<List<ProductReview>> getProductReviews(String productName) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _reviews.where((r) => r.productName == productName).toList();
  }

  @override
  Future<void> addProductReview(ProductReview review) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _reviews.insert(0, review);
  }
}
