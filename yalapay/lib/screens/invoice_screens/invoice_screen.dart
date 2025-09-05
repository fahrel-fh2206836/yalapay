import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/deleted_cheques_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/styling/background.dart';
import 'package:yalapay/widget/delete_record_confirmation.dart';
import 'package:yalapay/widget/icon_yalapay.dart';
import 'package:yalapay/widget/invoice_list.dart';
import 'package:yalapay/widget/search_bar.dart';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceNotifierProvider);

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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Text(
                  'Invoices',
                  style: getTextStyle('xlargeBold', color: Colors.white),
                ),
              ],
            ),
            actions: const [
              YalapayIcon(),
              SizedBox(width: 16),
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
                    hintText: "Search ID or Customer",
                    onChanged: (value) {
                      final invoiceNotifier =
                          ref.read(invoiceNotifierProvider.notifier);
                      if (value.isEmpty) {
                        invoiceNotifier.showAll();
                      } else {
                        invoiceNotifier.filterByIdName(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: InvoiceList(
                    invoices: invoices,
                    onDelete: (invoice) =>
                        showDeleteDialog(context, ref, invoice),
                    onView: (invoice) {
                      ref
                          .read(selectedInvoiceNotifierProvider.notifier)
                          .setInvoice(invoice);
                      context.pushNamed(AppRouter.invoiceDetails.name);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          floatingActionButton: const AddInvoiceButton(),
        ),
      ),
    );
  }
}

class AddInvoiceButton extends StatelessWidget {
  const AddInvoiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.pushNamed(AppRouter.addInvoice.name);
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        "Add Invoice",
        style: getTextStyle('small', color: Colors.white),
      ),
      backgroundColor: lightPrimary,
    );
  }
}

void showDeleteDialog(BuildContext context, WidgetRef ref, Invoice invoice) {
  showDialog(
    context: context,
    builder: (context) {
      ref.watch(chequeNotifierProvider);
      return ConfirmDeleteDialog(
          title: 'Invoice',
          message: 'Are you sure you want to delete the selected invoice?',
          itemToDelete: invoice,
          deleteFunction: (invoice) {
            ref
                .read(invoiceNotifierProvider.notifier)
                .removeInvoice(invoice.id);
            //Removes cheques associated with the invoice in the cheque provider state.
            final invoiceCheques = invoice.payments
                .where((payment) => payment.chequeNo != 1)
                .map((payment) => payment.chequeNo)
                .toList();
            for (var chequeNo in invoiceCheques) {
              ref.read(chequeNotifierProvider.notifier).removeCheque(chequeNo);
            }

            //To update deposit cheque provider later.
            ref
                .read(deletedChequesNotfierProvider.notifier)
                .addRecentlyDeletedCheques(invoiceCheques);

            //Removes payments associated with the invoice from the payment provider state
            for (var payment in invoice.payments) {
              ref
                  .read(paymentNotifierProvider.notifier)
                  .removePayment(payment.id);
            }
          });
    },
  );
}
