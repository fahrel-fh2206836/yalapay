import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/styling/background.dart';
import 'package:yalapay/widget/delete_record_confirmation.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_container.dart';
import 'package:yalapay/widget/icon_yalapay.dart';
import 'package:yalapay/widget/search_bar.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BackgroundGradient(
        colors: const [
          darkSecondary,
          darkPrimary,
        ],
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Text(
                  'Customers',
                  style: getTextStyle('xlargeBold', color: Colors.white),
                ),
              ],
            ),
            actions: const [
              YalapayIcon(),
              SizedBox(
                width: 16,
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SharedSearchBar(
                    hintText: "Search Customer",
                    onChanged: (value) {
                      final customerNotifier =
                          ref.read(customerNotifierProvider.notifier);
                      if (value.isEmpty) {
                        customerNotifier.showAll();
                      } else {
                        customerNotifier.filterByName(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                const Expanded(child: CustomerList()),
                const SizedBox(height: 10),
              ],
            ),
          ),
          floatingActionButton: const AddCustomerButton(),
        ),
      ),
    );
  }
}

class CustomerList extends ConsumerWidget {
  const CustomerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerNotifierProvider);

    return customers.isEmpty
        ? const EmptyScreen()
        : ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Customer ID: ${customer.id}",
                              style: getTextStyle("smallBold",
                                  color: lightSecondary),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 70,
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: lightSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_2_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      customer.companyName,
                                      style: getTextStyle('mediumBold',
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Contact: ${customer.contactDetails.firstName} ${customer.contactDetails.lastName}',
                              style: getTextStyle("smallLight",
                                  color: Colors.grey),
                            ),
                            Text(
                              'Address: ${customer.address.city}, ${customer.address.country}',
                              style: getTextStyle("smallLight",
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          context.pushNamed(AppRouter.customerDetails.name,
                              pathParameters: {'customerId': customer.id});
                        },
                        icon: iconContainer(Icons.remove_red_eye),
                      ),
                      IconButton(
                        onPressed: () {
                          showDeleteDialog(context, ref, customer);
                        },
                        icon: iconContainer(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class AddCustomerButton extends StatelessWidget {
  const AddCustomerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.pushNamed(AppRouter.addCustomer.name);
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        "Add Customer",
        style: getTextStyle('small', color: Colors.white),
      ),
      backgroundColor: lightPrimary,
    );
  }
}

void showDeleteDialog(BuildContext context, WidgetRef ref, Customer customer) {
  showDialog(
    context: context,
    builder: (context) {
      return ConfirmDeleteDialog(
        title: 'Customer',
        message: 'Are you sure you want to delete this customer?',
        itemToDelete: customer,
        deleteFunction: (customer) => ref
            .read(customerNotifierProvider.notifier)
            .removeCustomer(customer.id),
      );
    },
  );
}
