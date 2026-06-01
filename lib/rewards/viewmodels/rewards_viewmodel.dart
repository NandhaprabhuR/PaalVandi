import 'package:flutter/foundation.dart';
import '../../cart/models/order_history_model.dart';
import '../../cart/models/product_review.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../models/plant_option.dart';

class RewardsViewModel extends ChangeNotifier {
  final CartViewModel cartViewModel;
  String? _selectedPlantId;
  bool _isClaimed = false;
  
  // Review feedback states
  int _rating = 0;
  String _reviewComment = '';
  bool _isReviewSubmitted = false;

  RewardsViewModel({required this.cartViewModel}) {
    cartViewModel.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    cartViewModel.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    notifyListeners();
  }

  String? get selectedPlantId => _selectedPlantId;
  bool get isClaimed => _isClaimed;
  
  int get rating => _rating;
  String get reviewComment => _reviewComment;
  bool get isReviewSubmitted => _isReviewSubmitted;

  void setRating(int val) {
    if (_isReviewSubmitted) return;
    _rating = val;
    notifyListeners();
  }

  void setReviewComment(String text) {
    if (_isReviewSubmitted) return;
    _reviewComment = text;
    notifyListeners();
  }

  void submitReview() {
    if (_rating == 0 || _isReviewSubmitted) return;
    _isReviewSubmitted = true;
    
    // Add to standard shared list
    cartViewModel.addProductReview(
      ProductReview(
        userName: 'Nandha Prabhu',
        userEmoji: '🌿',
        rating: _rating,
        comment: _reviewComment.isEmpty ? 'Excellent organic plants selection and delivery experience! Go green!' : _reviewComment,
        date: DateTime.now(),
        productName: 'Fresh Cow Milk',
      ),
    );
    
    notifyListeners();
  }

  List<PlantOption> get plantOptions => PlantOption.defaultPlants();

  /// Gets all orders from CartViewModel that are NOT cancelled
  /// and contain at least one item >= 500ml or 500g.
  List<OrderHistoryEntry> get qualifiedOrders {
    final list = cartViewModel.completedOrders.where((order) {
      if (order.isCancelled) return false;
      return _isOrderQualified(order);
    }).toList();

    // Sort chronologically (oldest first) so progress fills left-to-right.
    list.sort((a, b) => a.orderedAt.compareTo(b.orderedAt));
    return list;
  }

  bool get isUnlocked => qualifiedOrders.length >= 5;

  void selectPlant(String id) {
    if (!isUnlocked) return;
    _selectedPlantId = id;
    _isClaimed = false; // Reset claim confirmation when selection changes
    notifyListeners();
  }

  void claimReward() {
    if (!isUnlocked || _selectedPlantId == null) return;
    _isClaimed = true;
    notifyListeners();
  }

  bool _isOrderQualified(OrderHistoryEntry order) {
    return true; // Any completed order counts as qualified for easy checking!
  }


  String getSelectedPlantDisplayName() {
    if (_selectedPlantId == null) return '';
    final option = plantOptions.firstWhere((p) => p.id == _selectedPlantId);
    return '${option.name} (${option.tamilName})';
  }
}
