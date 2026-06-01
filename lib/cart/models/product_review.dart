class ProductReview {
  final String userName;
  final String userEmoji;
  final int rating;
  final String comment;
  final DateTime date;
  final String productName;

  const ProductReview({
    required this.userName,
    required this.userEmoji,
    required this.rating,
    required this.comment,
    required this.date,
    this.productName = 'Fresh Cow Milk',
  });
}
