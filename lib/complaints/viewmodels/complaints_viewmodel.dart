import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';

class ComplaintsViewModel extends ChangeNotifier {
  final List<Complaint> _complaints = [
    Complaint(
      id: 'CMP-2026-081',
      category: 'Wrong Quantity',
      description: 'Ordered 1L milk but received only 500ml bottle.',
      status: 'Resolved',
      date: DateTime.now().subtract(const Duration(days: 3)),
      reply: 'Extremely sorry for the mixup Nandha. We have refunded ₹50 to your wallet and updated our route sheet.',
    ),
    Complaint(
      id: 'CMP-2026-094',
      category: 'Late Delivery',
      description: 'Delivery happened at 8:15 AM today instead of the regular 6:30 AM schedule.',
      status: 'Pending',
      date: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  List<Complaint> get complaints => List.unmodifiable(_complaints);

  void raiseComplaint(String category, String description) {
    final newId = 'CMP-2026-${100 + _complaints.length}';
    final complaint = Complaint(
      id: newId,
      category: category,
      description: description,
      status: 'Pending',
      date: DateTime.now(),
    );
    _complaints.insert(0, complaint);
    notifyListeners();
  }
}
