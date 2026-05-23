import 'package:equatable/equatable.dart';

class CustomersHomeModel extends Equatable {
  final List<String> availableProducts;
  final bool isLoading;

  const CustomersHomeModel({
    this.availableProducts = const [],
    this.isLoading = false,
  });

  CustomersHomeModel copyWith({
    List<String>? availableProducts,
    bool? isLoading,
  }) {
    return CustomersHomeModel(
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [availableProducts, isLoading];
}
