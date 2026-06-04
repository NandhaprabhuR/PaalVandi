import '../models/subscription_billing_model.dart';
import '../models/delivery_ledger_entry.dart';

class BillingStatement {
  final String id;
  final String subscriptionType;
  final String customerName;
  final String phone;
  final int month;
  final int year;
  final double ratePerLiter;
  final int calendarDays;
  final int deliveredDays;
  final int vacationDays;
  final int pausedDays;
  final int skippedDays;
  final int failedDeliveries;
  final double deliveredQuantity;
  final double morningQuantity;
  final double eveningQuantity;
  final double monthlyBill;
  final double advancePaid;
  final double remainingBalance;
  final String paymentStatus;
  final List<DeliveryLedgerEntry> monthEntries;

  const BillingStatement({
    required this.id,
    required this.subscriptionType,
    required this.customerName,
    required this.phone,
    required this.month,
    required this.year,
    required this.ratePerLiter,
    required this.calendarDays,
    required this.deliveredDays,
    required this.vacationDays,
    required this.pausedDays,
    required this.skippedDays,
    required this.failedDeliveries,
    required this.deliveredQuantity,
    required this.morningQuantity,
    required this.eveningQuantity,
    required this.monthlyBill,
    required this.advancePaid,
    required this.remainingBalance,
    required this.paymentStatus,
    required this.monthEntries,
  });

  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'Unknown';
  }
}

class SubscriptionBillingEngine {
  /// Calculates the billing statement for a given subscription and a list of ledger entries.
  static BillingStatement calculateStatement(
    SubscriptionBillingModel sub,
    List<DeliveryLedgerEntry> ledger,
    int month,
    int year,
  ) {
    // 1. Get exact calendar days for the given month/year
    final lastDayDateTime = DateTime(year, month + 1, 0);
    final calendarDays = lastDayDateTime.day;

    int deliveredDays = 0;
    int vacationDays = 0;
    int pausedDays = 0;
    int skippedDays = 0;
    int failedDeliveries = 0;

    double deliveredQuantity = 0.0;
    double morningQuantity = 0.0;
    double eveningQuantity = 0.0;

    // Filter ledger entries for the target month and year
    final monthEntries = ledger.where((entry) {
      return entry.date.month == month && entry.date.year == year;
    }).toList();

    // Map entries by day for fast lookup
    final Map<int, DeliveryLedgerEntry> dayToEntry = {
      for (var entry in monthEntries) entry.date.day: entry
    };

    // Smart or regular event pricing calculation
    if (sub.subscriptionType == 'Event') {
      // Event subscriptions are one-time orders
      // Aggregate any event quantity in the month ledger or default to daily quantity
      double eventQty = 0.0;
      for (final entry in monthEntries) {
        if (entry.status == 'Delivered') {
          eventQty += entry.totalQuantity;
        }
      }
      // If no entries found in ledger, check if any event default exists
      if (eventQty == 0 && monthEntries.isNotEmpty) {
        // Fallback or count
      }
      
      final totalBill = eventQty * sub.ratePerLiter;
      final remainingBalance = totalBill - sub.advancePaid;
      
      String payStatus = 'Unpaid';
      if (remainingBalance <= 0) {
        payStatus = 'Paid';
      } else if (remainingBalance < totalBill) {
        payStatus = 'Partial';
      }

      return BillingStatement(
        id: sub.id,
        subscriptionType: sub.subscriptionType,
        customerName: sub.customerName,
        phone: sub.phone,
        month: month,
        year: year,
        ratePerLiter: sub.ratePerLiter,
        calendarDays: calendarDays,
        deliveredDays: monthEntries.where((e) => e.status == 'Delivered').length,
        vacationDays: monthEntries.where((e) => e.status == 'Vacation').length,
        pausedDays: monthEntries.where((e) => e.status == 'Paused').length,
        skippedDays: monthEntries.where((e) => e.status.contains('Skip')).length,
        failedDeliveries: monthEntries.where((e) => e.status == 'Failed Delivery').length,
        deliveredQuantity: eventQty,
        morningQuantity: 0.0,
        eveningQuantity: 0.0,
        monthlyBill: totalBill,
        advancePaid: sub.advancePaid,
        remainingBalance: remainingBalance,
        paymentStatus: payStatus,
        monthEntries: monthEntries,
      );
    }

    // Process every calendar day of the month
    for (int day = 1; day <= calendarDays; day++) {
      final date = DateTime(year, month, day);
      final entry = dayToEntry[day];

      if (entry != null) {
        switch (entry.status) {
          case 'Delivered':
            deliveredDays++;
            
            double mQty = entry.quantityMorning;
            double eQty = entry.quantityEvening;

            // If Smart Subscription, assign daily quantity based on weekday logic
            if (sub.subscriptionType == 'Smart' && sub.weekdayQuantities != null) {
              final weekday = date.weekday; // 1 = Monday, 7 = Sunday
              final smartQty = sub.weekdayQuantities![weekday] ?? 0.0;
              // Distribute smart quantity: if only morning is selected or both
              mQty = smartQty; // Simplification for display
              eQty = 0.0;
            }

            deliveredQuantity += (mQty + eQty);
            morningQuantity += mQty;
            eveningQuantity += eQty;
            break;
          case 'Vacation':
            vacationDays++;
            break;
          case 'Paused':
            pausedDays++;
            break;
          case 'Customer Skip':
          case 'Company Skip':
            skippedDays++;
            break;
          case 'Failed Delivery':
            failedDeliveries++;
            break;
          default:
            // Pending / Not Processed
            break;
        }
      }
    }

    final monthlyBill = deliveredQuantity * sub.ratePerLiter;
    final remainingBalance = monthlyBill - sub.advancePaid;
    
    String paymentStatus = 'Unpaid';
    if (remainingBalance <= 0) {
      paymentStatus = 'Paid';
    } else if (remainingBalance < monthlyBill) {
      paymentStatus = 'Partial';
    }

    return BillingStatement(
      id: sub.id,
      subscriptionType: sub.subscriptionType,
      customerName: sub.customerName,
      phone: sub.phone,
      month: month,
      year: year,
      ratePerLiter: sub.ratePerLiter,
      calendarDays: calendarDays,
      deliveredDays: deliveredDays,
      vacationDays: vacationDays,
      pausedDays: pausedDays,
      skippedDays: skippedDays,
      failedDeliveries: failedDeliveries,
      deliveredQuantity: deliveredQuantity,
      morningQuantity: morningQuantity,
      eveningQuantity: eveningQuantity,
      monthlyBill: monthlyBill,
      advancePaid: sub.advancePaid,
      remainingBalance: remainingBalance,
      paymentStatus: paymentStatus,
      monthEntries: monthEntries,
    );
  }

  static BillingSummaryReport calculateSummaryReport(
    List<BillingStatement> statements,
    int month,
    int year,
  ) {
    final totalCalendarDays = DateTime(year, month + 1, 0).day;
    int deliveredDays = 0;
    int vacationDays = 0;
    int pausedDays = 0;
    int skippedDays = 0;
    double deliveredQuantity = 0.0;
    double milkAmount = 0.0;
    double advancePaid = 0.0;
    double remainingBalance = 0.0;

    for (final stmt in statements) {
      deliveredDays += stmt.deliveredDays;
      vacationDays += stmt.vacationDays;
      pausedDays += stmt.pausedDays;
      skippedDays += stmt.skippedDays;
      deliveredQuantity += stmt.deliveredQuantity;
      milkAmount += stmt.monthlyBill;
      advancePaid += stmt.advancePaid;
      remainingBalance += stmt.remainingBalance;
    }

    // Structured delivery charge structure: e.g. ₹5 per delivery day
    final deliveryCharges = deliveredDays * 5.0;
    
    // Final payable amount formula: Milk Amount + Delivery Charges - Advance Paid
    final finalPayableAmount = milkAmount + deliveryCharges - advancePaid;

    return BillingSummaryReport(
      month: month,
      year: year,
      totalCalendarDays: totalCalendarDays,
      deliveredDays: deliveredDays,
      vacationDays: vacationDays,
      pausedDays: pausedDays,
      skippedDays: skippedDays,
      deliveredQuantity: deliveredQuantity,
      milkAmount: milkAmount,
      deliveryCharges: deliveryCharges,
      advancePaid: advancePaid,
      remainingBalance: remainingBalance,
      finalPayableAmount: finalPayableAmount,
    );
  }
}

class BillingSummaryReport {
  final int month;
  final int year;
  final int totalCalendarDays;
  final int deliveredDays;
  final int vacationDays;
  final int pausedDays;
  final int skippedDays;
  final double deliveredQuantity;
  final double milkAmount;
  final double deliveryCharges;
  final double advancePaid;
  final double remainingBalance;
  final double finalPayableAmount;

  const BillingSummaryReport({
    required this.month,
    required this.year,
    required this.totalCalendarDays,
    required this.deliveredDays,
    required this.vacationDays,
    required this.pausedDays,
    required this.skippedDays,
    required this.deliveredQuantity,
    required this.milkAmount,
    required this.deliveryCharges,
    required this.advancePaid,
    required this.remainingBalance,
    required this.finalPayableAmount,
  });

  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return 'Unknown';
  }
}
