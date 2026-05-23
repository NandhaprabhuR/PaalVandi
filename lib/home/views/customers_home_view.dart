import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/customers_home_viewmodel.dart';
import '../../theme/customers_home_themeview.dart';

class CustomersHomeView extends StatelessWidget {
  const CustomersHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paalvandi Home',
          style: CustomersHomeThemeView.appBarTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<CustomersHomeViewModel>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<CustomersHomeViewModel, CustomersHomeState>(
        listener: (context, state) {
          if (state is HomeLoggedOut) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is HomeLoading || state.model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return ListView.builder(
            itemCount: state.model.availableProducts.length,
            itemBuilder: (context, index) {
              final product = state.model.availableProducts[index];
              return Card(
                color: CustomersHomeThemeView.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    product,
                    style: CustomersHomeThemeView.productTitleStyle,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
