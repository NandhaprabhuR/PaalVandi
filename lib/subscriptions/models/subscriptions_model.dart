import 'package:equatable/equatable.dart';

class SubscriptionsModel extends Equatable {
  final bool isLoading;
  final List<String> activePlans;

  const SubscriptionsModel({
    this.isLoading = false,
    this.activePlans = const [],
  });

  SubscriptionsModel copyWith({
    bool? isLoading,
    List<String>? activePlans,
  }) {
    return SubscriptionsModel(
      isLoading: isLoading ?? this.isLoading,
      activePlans: activePlans ?? this.activePlans,
    );
  }

  @override
  List<Object> get props => [isLoading, activePlans];
}
