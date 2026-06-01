import 'package:url_launcher/url_launcher.dart';
import '../models/payment_model.dart';

class UpiPaymentService {
  static const String _merchantVpa = 'paalvandi@upi';
  static const String _merchantName = 'PaalVandi';

  static String upiUriForApp(UpiAppOption app, int amountRupees) {
    final amount = amountRupees.toStringAsFixed(2);
    final base =
        'upi://pay?pa=$_merchantVpa&pn=${Uri.encodeComponent(_merchantName)}&am=$amount&cu=INR&tn=${Uri.encodeComponent('PaalVandi Order')}';
    return switch (app) {
      UpiAppOption.gpay => '$base&app=gpay',
      UpiAppOption.phonepe => '$base&app=phonepe',
      UpiAppOption.paytm => '$base&app=paytm',
      UpiAppOption.bhim => base,
    };
  }

  static Future<bool> launchUpiPayment({
    required UpiAppOption app,
    required int amountRupees,
  }) async {
    try {
      final uri = Uri.parse(upiUriForApp(app, amountRupees));
      final bool canLaunchApp = await canLaunchUrl(uri);
      if (canLaunchApp) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Graceful fallback for simulator/emulator environments
    }

    try {
      final generic = Uri.parse(
        'upi://pay?pa=$_merchantVpa&pn=${Uri.encodeComponent(_merchantName)}&am=${amountRupees.toStringAsFixed(2)}&cu=INR',
      );
      final bool canLaunchGeneric = await canLaunchUrl(generic);
      if (canLaunchGeneric) {
        return await launchUrl(generic, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Graceful fallback for simulator/emulator environments
    }

    return false;
  }
}
