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
    final uri = Uri.parse(upiUriForApp(app, amountRupees));
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    final generic = Uri.parse(
      'upi://pay?pa=$_merchantVpa&pn=${Uri.encodeComponent(_merchantName)}&am=${amountRupees.toStringAsFixed(2)}&cu=INR',
    );
    if (await canLaunchUrl(generic)) {
      return launchUrl(generic, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
