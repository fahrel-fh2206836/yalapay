import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/styling/frosted_glass.dart';
import 'package:yalapay/widget/details_row.dart';
import 'package:yalapay/widget/section_title_with_icon.dart';
import 'package:yalapay/widget/update_record_confirmation.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  const InvoiceDetailScreen({super.key});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool isEditing = false;
  String? dueDate;

  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dueDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void initializeControllers(invoice) {
    yearController.text = invoice.dueDate.substring(0, 4);
    monthController.text = invoice.dueDate.substring(5, 7);
    dayController.text = invoice.dueDate.substring(8, 10);
    dueDate = invoice.dueDate;
  }

  void showUpdateConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          type: "Invoice",
          title: "Confirm Update",
          content: "Are you sure you want to update the invoice details?",
          onConfirm: updateInvoice,
        );
      },
    );
  }

  void updateInvoice() {
    setState(() {
      final selectedInvoice = ref.read(selectedInvoiceNotifierProvider);
      selectedInvoice.when(
        data: (invoice) {
          if (dueDate != null && dueDate != invoice.dueDate) {
            ref
                .read(invoiceNotifierProvider.notifier)
                .updateInvoiceDue(dueDate!, invoice.id);
          }

          isEditing = false;
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedInvoice = ref.watch(selectedInvoiceNotifierProvider);
    ref.watch(paymentNotifierProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(true);
          Navigator.of(context).pop(result);
        }
        return;
      },
      child: selectedInvoice.when(
        data: (invoice) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
              title: isEditing
                  ? Text(
                      "Editing Invoice",
                      style: getTextStyle('largeBold', color: Colors.white),
                    )
                  : Text(
                      "Invoice Details",
                      style: getTextStyle('largeBold', color: Colors.white),
                    ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref
                      .read(showNavBarNotifierProvider.notifier)
                      .showBottomNavBar(true);
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(isEditing ? Icons.done : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                      if (isEditing) {
                        initializeControllers(invoice);
                      }
                    });
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/bg4.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: getInvoiceStatusColor(invoice.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "ID: ${invoice.id}",
                              style: getTextStyle('largeBold',
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FrostedGlassBox(
                        boxWidth: double.infinity,
                        isCurved: true,
                        boxChild: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomerSection(
                            isEditing: isEditing,
                            invoice: invoice,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FrostedGlassBox(
                        boxWidth: double.infinity,
                        isCurved: true,
                        boxChild: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DetailsSection(
                            isEditing: isEditing,
                            invoice: invoice,
                            selectDate: selectDate,
                            dueDate: dueDate,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ClipRRect(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: isEditing
                          ? ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                showUpdateConfirmationDialog();
                              },
                              style: purpleButtonStyle,
                              child: Text(
                                "Update",
                                style:
                                    getTextStyle('small', color: Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: invoice.invoiceBalance > 0
                                        ? () {
                                            context.pushNamed(
                                                AppRouter.addPayment.name);
                                          }
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Payment Complete"),
                                                  content: const Text(
                                                      "The payment for this invoice has already been completed."),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("OK"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                    style: invoice.invoiceBalance > 0
                                        ? purpleButtonStyle
                                        : greyButtonStyle,
                                    child: Text(
                                      'Add Payment',
                                      style: getTextStyle('small',
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .pushNamed(AppRouter.payments.name);
                                    },
                                    style: purpleButtonStyle,
                                    child: Text(
                                      'View Payment',
                                      style: getTextStyle('small',
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                ),
              ),
            ),
          );
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator(),
      ),
    );
  }
}

class CustomerSection extends StatelessWidget {
  final bool isEditing;
  final dynamic invoice;

  const CustomerSection({
    super.key,
    required this.isEditing,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTitleWithIcon(
      icon: Icons.person,
      title: "Customer",
      child: Column(
        children: [
          DetailsRow(label: "Customer ID", value: invoice.customerId),
          DetailsRow(
            label: "Customer",
            value: invoice.customerName,
            divider: false,
          ),
        ],
      ),
    );
  }
}

class DetailsSection extends StatelessWidget {
  final bool isEditing;
  final dynamic invoice;
  final Function(BuildContext) selectDate;
  final String? dueDate;

  const DetailsSection({
    super.key,
    required this.isEditing,
    required this.invoice,
    required this.selectDate,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return SectionTitleWithIcon(
      icon: Icons.description,
      title: "Details",
      child: Column(
        children: [
          DetailsRow(
              label: "Amount",
              value: "QR ${invoice.amount.toStringAsFixed(2)}",
              special: true),
          DetailsRow(label: "Invoice Issue date", value: invoice.invoiceDate),
          isEditing
              ? GestureDetector(
                  onTap: () => selectDate(context),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: borderColor, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Due Date",
                              style: getTextStyle('smallBold',
                                  color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: lightSecondary,
                                  width: 2.0,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                dueDate ?? invoice.dueDate,
                                style:
                                    getTextStyle('small', color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : DetailsRow(label: "Due Date", value: invoice.dueDate),
          DetailsRow(label: "Status", value: invoice.status, special: true),
          DetailsRow(
            label: "Balance Pending",
            value: "QR ${invoice.invoiceBalance.toStringAsFixed(2)}",
            divider: false,
          )
        ],
      ),
    );
  }
}
