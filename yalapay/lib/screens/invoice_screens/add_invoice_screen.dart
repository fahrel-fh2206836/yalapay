import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/customer.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/providers/customer_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/widget/add_screen_text_field.dart';
import 'package:yalapay/widget/section_title_with_icon.dart';

class AddInvoiceScreen extends ConsumerStatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  ConsumerState<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends ConsumerState<AddInvoiceScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController custIdController = TextEditingController();
  DateTime? selectedDueDate;
  String? companyText;
  List<Customer> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });

    final customers = ref.read(customerNotifierProvider);
    customers.when(
        data: (customersList) => filteredCustomers = List.from(customersList),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'));
  }

  @override
  void dispose() {
    amountController.dispose();
    custIdController.dispose();
    super.dispose();
  }

  void clearAll() {
    amountController.clear();
    custIdController.clear();
    companyText = null;
    setState(() {
      selectedDueDate = null;
      ref.watch(customerNotifierProvider).when(
            data: (customersList) => filteredCustomers = customersList,
            error: (err, stack) => Text('Error: $err'),
            loading: () => const CircularProgressIndicator(),
          );
    });
  }

  bool isAllFilled() =>
      amountController.text.isNotEmpty && selectedDueDate != null;

  void filterCustomers(String query) {
    final customers = ref.watch(customerNotifierProvider);
    customers.when(
      data: (customersList) {
        setState(() {
          if (query.isEmpty) {
            filteredCustomers = List.from(customersList);
          } else {
            filteredCustomers = customersList
                .where((customer) => customer.companyName
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList();
          }
        });
      },
      error: (err, stack) => Text('Error: $err'),
      loading: () => const CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            ref
                .read(showNavBarNotifierProvider.notifier)
                .showBottomNavBar(true);
            Navigator.of(context).pop(result);
          }
          return;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            title: Text(
              "Add Invoice",
              style: getTextStyle('largeBold', color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              buildBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    buildAmountAndDueDateSection(context),
                    const SizedBox(height: 30),
                    buildCustomerSelectionSection(context),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg4.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget buildCustomerSelectionSection(BuildContext context) {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.business,
        title: "Select Customer",
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              AddScreensTextField(
                label: "Search Company Name",
                controller: custIdController,
                activeBorderColor: lightSecondary,
                onChanged: (value) {
                  filterCustomers(value);
                },
                suffixIcon: custIdController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          custIdController.clear();
                          filterCustomers('');
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              if (filteredCustomers.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        title: Text(
                          customer.companyName,
                          style: getTextStyle("small", color: Colors.white),
                        ),
                        trailing: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: lightSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.person_2_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                custIdController.text = customer.companyName;
                                companyText = customer.companyName;
                              });
                              filterCustomers(customer.companyName);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAmountAndDueDateSection(BuildContext context) {
    return StyledContainer(
      child: Column(
        children: [
          SectionTitleWithIcon(
            icon: Icons.attach_money,
            title: "Invoice Details",
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: AddScreensTextField(
                        controller: amountController,
                        label: "Amount",
                        type: TextInputType.number,
                        activeBorderColor: lightSecondary,
                        suffixIcon: amountController.text.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.done, color: Colors.white),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDueDate = pickedDate;
                            });
                          }
                        },
                        style: purpleButtonStyle,
                        child: Text(
                          selectedDueDate != null
                              ? selectedDueDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first
                              : "Select Due Date",
                          style: getTextStyle('small', color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: BottomAppBar(
          color: Colors.black.withOpacity(0.4),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => handleAddInvoice(context),
                    style: purpleButtonStyle,
                    child: Text(
                      "Add Invoice",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: clearAll,
                    style: purpleButtonStyle,
                    child: Text(
                      "Clear All",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleAddInvoice(BuildContext context) {
    if (!isAllFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required.')));
      return;
    }

    final invoices = ref.watch(invoiceNotifierProvider);
    invoices.when(
      data: (invoices) {
        final invoice = Invoice(
          id: '-1',
          customerId: custIdController.text,
          customerName: companyText ?? '',
          amount: double.parse(amountController.text),
          invoiceDate: DateTime.now().toString().substring(0, 10),
          dueDate: selectedDueDate!.toIso8601String().split('T').first,
        );
        ref.read(invoiceNotifierProvider.notifier).addInvoice(invoice);
      },
      error: (err, stack) => Text('Error: $err'),
      loading: () => const CircularProgressIndicator(),
    );
    clearAll();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Invoice Added.')));
  }
}

class StyledContainer extends StatelessWidget {
  final Widget child;

  const StyledContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkPrimary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
