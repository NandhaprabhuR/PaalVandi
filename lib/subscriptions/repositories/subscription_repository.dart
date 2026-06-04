import '../models/subscription_delivery_model.dart';
import '../models/subscription_billing_model.dart';
import '../models/delivery_ledger_entry.dart';
import '../../core/constants/mock_data.dart';

/// Abstract subscription repository — swap for Supabase later.
abstract class SubscriptionRepository {
  Future<List<SubscriptionDeliveryModel>> fetchTodaySubscriptions();
  Future<SubscriptionDeliveryModel> markDelivered(String id);
  Future<SubscriptionDeliveryModel> skipDeliveryWithReason(String id, String reason);
  Future<SubscriptionDeliveryModel> collectBottles(String id, int bottleCount);
  Future<SubscriptionBillingModel> fetchBillingProfile(String subscriptionId);
  Future<List<DeliveryLedgerEntry>> fetchLedger(String subscriptionId);
  Future<void> logLedgerStatus(String subscriptionId, String status, {double quantityMorning = 0.0, double quantityEvening = 0.0});
}

class MockSubscriptionRepository implements SubscriptionRepository {
  final List<SubscriptionDeliveryModel> _subs =
      List.from(MockData.subscriptionDeliveries);

  final List<SubscriptionBillingModel> _billingProfiles =
      List.from(MockData.subscriptionBillingProfiles);

  final List<DeliveryLedgerEntry> _ledger =
      MockData.deliveryLedger; // Use references to keep database state shared

  @override
  Future<List<SubscriptionDeliveryModel>> fetchTodaySubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_subs);
  }

  String _getCurrentTimeString() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $amPm';
  }

  @override
  Future<SubscriptionDeliveryModel> markDelivered(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(
        isDelivered: true, 
        isSkipped: false,
        deliveryTime: _getCurrentTimeString(),
      );

      // Write to ledger
      final billing = await fetchBillingProfile(id);
      await logLedgerStatus(
        id, 
        'Delivered',
        quantityMorning: billing.morningQty,
        quantityEvening: billing.eveningQty,
      );

      return _subs[index];
    }
    throw Exception('Subscription not found: $id');
  }

  @override
  Future<SubscriptionDeliveryModel> skipDeliveryWithReason(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(
        isSkipped: true, 
        isDelivered: false, 
        skipReason: reason,
        deliveryTime: _getCurrentTimeString(),
      );

      // Write to ledger
      final billing = await fetchBillingProfile(id);
      String ledgerStatus = 'Customer Skip';
      if (reason.contains('Company') || reason.contains('Failed')) {
        ledgerStatus = 'Company Skip';
      }
      await logLedgerStatus(
        id, 
        ledgerStatus,
        quantityMorning: billing.morningQty,
        quantityEvening: billing.eveningQty,
      );

      return _subs[index];
    }
    throw Exception('Subscription not found: $id');
  }

  @override
  Future<SubscriptionDeliveryModel> collectBottles(String id, int bottleCount) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(bottlesCollected: bottleCount);
      return _subs[index];
    }
    throw Exception('Subscription not found: $id');
  }

  @override
  Future<SubscriptionBillingModel> fetchBillingProfile(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _billingProfiles.indexWhere((p) => p.id == subscriptionId);
    if (index != -1) {
      return _billingProfiles[index];
    }
    // Default fallback
    return SubscriptionBillingModel(
      id: subscriptionId,
      customerName: 'Unknown Customer',
      phone: '9876500000',
      subscriptionType: 'Family',
      ratePerLiter: 60.0,
      morningQty: 1.0,
    );
  }

  @override
  Future<List<DeliveryLedgerEntry>> fetchLedger(String subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _ledger.where((entry) => entry.subscriptionId == subscriptionId).toList();
  }

  @override
  Future<void> logLedgerStatus(
    String subscriptionId, 
    String status, {
    double quantityMorning = 0.0, 
    double quantityEvening = 0.0,
  }) async {
    // Current date is June 3, 2026 based on mock system timestamp
    final today = DateTime(2026, 6, 3);
    
    // Check if entry exists for today
    final index = _ledger.indexWhere((entry) => 
        entry.subscriptionId == subscriptionId &&
        entry.date.year == today.year &&
        entry.date.month == today.month &&
        entry.date.day == today.day);

    if (index != -1) {
      // Update existing entry
      _ledger[index] = _ledger[index].copyWith(
        status: status,
        quantityMorning: quantityMorning,
        quantityEvening: quantityEvening,
      );
    } else {
      // Create new ledger entry
      final profile = await fetchBillingProfile(subscriptionId);
      _ledger.add(DeliveryLedgerEntry(
        id: 'LED-${_ledger.length + 1}',
        subscriptionId: subscriptionId,
        date: today,
        status: status,
        quantityMorning: quantityMorning,
        quantityEvening: quantityEvening,
        ratePerLiter: profile.ratePerLiter,
      ));
    }
  }
}
