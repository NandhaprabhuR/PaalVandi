import 'dart:math';

class AppIdGenerator {
  static String generate5CharId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(5, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
