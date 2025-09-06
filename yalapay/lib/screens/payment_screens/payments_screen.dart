import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/deleted_cheques_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/styling/frosted_glass.dart';
import 'package:yalapay/widget/delete_record_confirmation.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_container.dart';
import 'package:yalapay/screens/payment_screens/payment_filter.dart';
import 'package:yalapay/widget/special_text.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool isFilterEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentNotifierProvider.notifier).showAllPayments();
    });

    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  void toggleFilterVisibility() {
    setState(() {
      isFilterEnabled = !isFilterEnabled;
      if (!isFilterEnabled) {
        ref.watch(selectedInvoiceNotifierProvider).when(
              data: (invoice) {
                ref
                    .read(paymentNotifierProvider.notifier)
                    .getPaymentsByInvoiceId(invoice.id);
              },
              error: (err, stack) => Text('Error: $err'),
              loading: () => const CircularProgressIndicator(),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(selectedInvoiceNotifierProvider);

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
                .showBottomNavBar(false);
            Navigator.of(context).pop(result);
          }
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Payments',
                  style: getTextStyle('xlargeBold', color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                    isFilterEnabled ? Icons.filter_alt_off : Icons.filter_alt),
                onPressed: toggleFilterVisibility,
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [darkSecondary, darkPrimary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SafeArea(
                  child: invoice.when(
                    data: (selectedInvoice) {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          FrostedGlassBox(
                            boxWidth: double.infinity,
                            boxChild: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child:
                                      InvoiceDetails(invoice: selectedInvoice),
                                ),
                                if (isFilterEnabled)
                                  FilterSection(invoiceId: selectedInvoice.id),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: PaymentList(
                              invoice: selectedInvoice,
                              isFilterEnabled: isFilterEnabled,
                            ),
                          ),
                        ],
                      );
                    },
                    error: (err, stack) => Text('Error: $err'),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceDetails extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetails({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              specialText(invoice.status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Invoice ID ${invoice.id}',
                style: getTextStyle('small', color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                invoice.customerName,
                style: getTextStyle('largeBold', color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentList extends ConsumerWidget {
  final Invoice invoice;
  final bool isFilterEnabled;

  const PaymentList(
      {super.key, required this.invoice, required this.isFilterEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCheques = ref.watch(chequeNotifierProvider);
    final allPayments = ref.watch(paymentNotifierProvider);
    return allPayments.when(
        data: (payments) {
          if (!isFilterEnabled) {
            ref
                .read(paymentNotifierProvider.notifier)
                .getPaymentsByInvoiceId(invoice.id);
          }
          return payments.isEmpty
              ? const Center(child: SingleChildScrollView(child: EmptyScreen()))
              : allCheques.when(
                  data: (chequesList) {
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return PaymentCard(
                            payment: payment, cheques: chequesList);
                      },
                    );
                  },
                  error: (err, stack) => Text('Error: $err'),
                  loading: () => const CircularProgressIndicator());
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }
}

class PaymentCard extends ConsumerWidget {
  final dynamic payment;
  final List<Cheque> cheques;

  const PaymentCard({super.key, required this.payment, required this.cheques});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: getPaymentModeColor(payment.paymentMode),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Payment ID: ${payment.id}',
                    style: getTextStyle('smallBold', color: lightSecondary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'QR ${payment.amount.toStringAsFixed(2)}',
                    style: getTextStyle('largeBold', color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Mode: ${payment.paymentMode}',
                    style: getTextStyle('small', color: Colors.white),
                  ),
                  Text(
                    'Payment Date: ${payment.paymentDate}',
                    style: getTextStyle('smallLight', color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                context.pushNamed(AppRouter.chequeDetails.name,
                    pathParameters: {'paymentId': payment.id});
              },
              icon: iconContainer(Icons.remove_red_eye_rounded),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmDeleteDialog(
                    title: 'Payment',
                    message: 'Are you sure you want to delete this payment?',
                    itemToDelete: payment.id,
                    deleteFunction: (id) {
                      final selectedinvoice =
                          ref.watch(selectedInvoiceNotifierProvider);
                      selectedinvoice.when(
                        data: (invoice) {
                          ref
                              .read(paymentNotifierProvider.notifier)
                              .removePayment(id);

                          if (payment.chequeNo != -1) {
                            ref
                                .read(chequeNotifierProvider.notifier)
                                .removeCheque(payment.chequeNo);

                            List<int> chequeNoList = [];
                            chequeNoList.add(payment.chequeNo);
                            ref
                                .read(deletedChequesNotfierProvider.notifier)
                                .addRecentlyDeletedCheques((chequeNoList));
                          }

                          ref.watch(chequeNotifierProvider).when(
                                data: (cheques) {
                                  invoice.payments.remove(invoice.payments
                                      .where((payment) => payment.id == id)
                                      .first);
                                  invoice.updateInvoiceBalance(cheques);
                                  invoice.updateStatus();
                                },
                                error: (err, stack) => Text('Error: $err'),
                                loading: () =>
                                    const CircularProgressIndicator(),
                              );

                          ref
                              .read(invoiceNotifierProvider.notifier)
                              .removeInvoice(invoice.id);
                          ref
                              .read(invoiceNotifierProvider.notifier)
                              .addInvoice(invoice);
                        },
                        error: (err, stack) => Text('Error: $err'),
                        loading: () => const CircularProgressIndicator(),
                      );
                    },
                  ),
                );
              },
              icon: iconContainer(Icons.delete_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
