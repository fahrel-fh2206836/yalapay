import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/widget/delete_record_confirmation.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_container.dart';
import 'package:yalapay/widget/special_text.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

class ChequeDepositsScreen extends ConsumerStatefulWidget {
  const ChequeDepositsScreen({super.key});

  @override
  ConsumerState<ChequeDepositsScreen> createState() =>
      ChequeDepositsScreenState();
}

class ChequeDepositsScreenState extends ConsumerState<ChequeDepositsScreen> {
  String statusDropdownValue = "Cashed";
  ChequeDeposit? selectedDeposit;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
      ref.read(chequeNotifierProvider.notifier).showAll();
    });

    Future.microtask(() {
      ref.read(depositStatusProvider);
      ref.read(returnReasonProvider);
      ref.read(chequeDepositNotifierProvider);
      ref.read(chequeNotifierProvider);
      ref.read(paymentNotifierProvider);
      ref.read(invoiceNotifierProvider);
    });
  }

  bool isFilled() {
    return selectedDeposit != null;
  }

  Future<void> updateInvoiceBalance({required int chequeNo}) async {
    ref.watch(chequeNotifierProvider);
    Cheque? cheque =
        await ref.read(chequeNotifierProvider.notifier).getCheque(chequeNo);
    Payment? payment = await ref
        .read(paymentNotifierProvider.notifier)
        .getPaymentWithChequeNo(chequeNo);
    Invoice? invoice = await ref
        .read(invoiceNotifierProvider.notifier)
        .getInvoice(payment!.invoiceNo);
    ref.watch(paymentNotifierProvider).when(
          data: (paymentsList) {
            List<Payment> invoicePayments = paymentsList
                .where((payment) => payment.invoiceNo == invoice!.id)
                .toList();
            invoice!.payments = invoicePayments;
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        );
    ref.watch(chequeNotifierProvider).when(
          data: (cheques) {
            invoice!.updateInvoiceBalance(cheques);
            invoice.updateStatus();
            ref
                .read(invoiceNotifierProvider.notifier)
                .removeInvoice(invoice.id);
            ref.read(invoiceNotifierProvider.notifier).addInvoice(invoice);
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        );
  }

  void handleStatusUpdate() async {
    ref
        .read(chequeDepositNotifierProvider.notifier)
        .updateStatus(selectedDeposit!.id, statusDropdownValue);

    await ref.read(chequeNotifierProvider.notifier).updateChequeListStatus(
        chequeNoList: selectedDeposit!.chequeNos, status: statusDropdownValue);

    await ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
        chequeNoList: selectedDeposit!.chequeNos,
        date: DateTime.now().toString().substring(0, 10),
        type: DateType.cashedDate);
    setState(() {
      selectedDeposit = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Cheque deposit status is set to $statusDropdownValue"),
        duration: const Duration(seconds: 2),
        backgroundColor: lightSecondary,
        elevation: 5,
      ),
    );
    Navigator.of(context).pop(); //Hide the modal sheet
  }

  void handleContinue() {
    setState(() {
      Navigator.of(context).pop();
      context.pushNamed(AppRouter.chequeDepositUpdate.name,
          pathParameters: {'chequeDepositId': selectedDeposit!.id}).then((_) {
        setState(() {
          ref.watch(chequeDepositNotifierProvider);
          selectedDeposit = null;
          statusDropdownValue = "Cashed";
        });
      });
    });
  }

  void handleIncompleteFields() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Incomplete Fields"),
          content: const Text("A deposit must be selected."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showStatusUpdateBottomSheet(
      BuildContext context,
      AsyncValue<List<String>> depositStatusList,
      AsyncValue<List<String>> returnReasonList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: screenHeight(context) * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.update, color: Colors.white),
                        const SizedBox(width: 10),
                        Text("Update Deposit Status",
                            style: getTextStyle('mediumBold',
                                color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Deposit Status",
                            style: getTextStyle('medium', color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    depositStatusList.when(
                      data: (statusList) {
                        statusList.remove("Deposited");
                        return SizedBox(
                          width: double.infinity,
                          child: FilterDropdown(
                            selectedFilter: statusDropdownValue,
                            options: statusList,
                            onSelected: (newValue) {
                              setState(() {
                                statusDropdownValue = newValue!;
                              });
                              setModalState(() {
                                statusDropdownValue = newValue!;
                              });
                            },
                          ),
                        );
                      },
                      error: (err, stack) => Text('Error: $err'),
                      loading: () => const CircularProgressIndicator(),
                    ),
                    const Spacer(),
                    buildButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            "Deposits",
            style: getTextStyle('xlargeBold', color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(true);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget buildChequeDepositList(List<ChequeDeposit> chequeDeposits) {
    return chequeDeposits.isEmpty
        ? const EmptyScreen()
        : ListView.builder(
            itemCount: chequeDeposits.length,
            itemBuilder: (context, index) {
              return buildChequeDepositItem(chequeDeposits[index]);
            },
          );
  }

  Widget buildChequeDepositItem(ChequeDeposit deposit) {
    final isSelected = selectedDeposit == deposit;

    return GestureDetector(
      onTap: () {
        if (deposit.status == 'Deposited') {
          setState(() {
            if (isSelected) {
              selectedDeposit = null;
            } else {
              selectedDeposit = deposit;
            }
          });
        }
      },
      child: Card(
        color:
            isSelected ? lightSecondary.withOpacity(0.4) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${deposit.id}',
                      style: getTextStyle('smallBold', color: lightSecondary),
                    ),
                    const SizedBox(height: 4),
                    buildSubtitle(deposit),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: buildTrailingIcons(deposit, isSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildSubtitle(ChequeDeposit deposit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          deposit.bankAccountNo,
          style: getTextStyle('xlargeBold', color: Colors.white),
        ),
        const SizedBox(height: 10),
        specialText(deposit.status),
        const SizedBox(height: 10),
        Text(
          'No. of Cheques: ${deposit.chequeNos.length}',
          style: getTextStyle('small', color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text('Date of Deposit: ${deposit.depositDate}',
            style: getTextStyle('small', color: Colors.grey)),
        if (ref
                    .read(chequeDepositNotifierProvider.notifier)
                    .getStatus(deposit.id) ==
                "Cashed" ||
            ref
                    .read(chequeDepositNotifierProvider.notifier)
                    .getStatus(deposit.id) ==
                "Cashed with Returns")
          Text(
            'Cashed Date: ${deposit.cashedDate}',
            style: getTextStyle('small', color: Colors.grey),
          ),
      ],
    );
  }

  Row buildTrailingIcons(ChequeDeposit deposit, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            context.pushNamed(AppRouter.chequeDepositDetails.name,
                pathParameters: {'chequeDepositId': deposit.id});
          },
          icon: iconContainer(Icons.remove_red_eye,
              backgroundColor: isSelected ? Colors.grey[700] : lightPrimary),
        ),
        IconButton(
          onPressed: () {
            showDeleteDialog(context, ref, deposit);
          },
          icon: iconContainer(Icons.delete,
              backgroundColor: isSelected ? Colors.grey[700] : lightPrimary),
        ),
      ],
    );
  }

  SizedBox buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFilled() && statusDropdownValue == "Cashed"
            ? handleStatusUpdate
            : isFilled() && statusDropdownValue == "Cashed with Returns"
                ? handleContinue
                : handleIncompleteFields,
        style: isFilled() ? purpleButtonStyle : greyButtonStyle,
        child: statusDropdownValue == "Cashed"
            ? Text("Update", style: getTextStyle('small', color: Colors.white))
            : Text("Continue",
                style: getTextStyle('small', color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chequeDeposits = ref.watch(chequeDepositNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(true);
          Navigator.of(context).pop(result);
        }
        return;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(),
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  chequeDeposits.when(
                    data: (depositsList) {
                      return Expanded(
                          child: buildChequeDepositList(depositsList));
                    },
                    error: (err, stack) => Text('Error: $err'),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: isFilled()
              ? () {
                  showStatusUpdateBottomSheet(
                      context,
                      ref.watch(depositStatusProvider),
                      ref.watch(returnReasonProvider));
                }
              : null,
          icon: const Icon(Icons.update, color: Colors.white),
          label: Text(
            "Update Deposit Status",
            style: getTextStyle('small', color: Colors.white),
          ),
          backgroundColor: isFilled() ? lightPrimary : Colors.grey[600],
        ),
      ),
    );
  }

  void showDeleteDialog(
      BuildContext context, WidgetRef ref, ChequeDeposit deposit) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmDeleteDialog<ChequeDeposit>(
          title: 'Cheque Deposit',
          message: 'Are you sure you want to delete this deposit?',
          itemToDelete: deposit,
          deleteFunction: (deposit) async {
            //Update Individual Cheque Status to Awaiting.
            await ref
                .read(chequeNotifierProvider.notifier)
                .updateChequeListStatus(
                    chequeNoList: deposit.chequeNos, status: 'Awaiting');

            //Set Deposit Date to Empty ''.
            await ref
                .read(chequeNotifierProvider.notifier)
                .updateChequeListDate(
                    chequeNoList: deposit.chequeNos,
                    date: '',
                    type: DateType.depositDate);

            if (deposit.status == "Cashed" ||
                deposit.status == "Cashed with Returns") {
              //Set Cashed Date to Empty ''.
              await ref
                  .read(chequeNotifierProvider.notifier)
                  .updateChequeListDate(
                      chequeNoList: deposit.chequeNos,
                      date: '',
                      type: DateType.cashedDate);
            }
            if (deposit.status == "Cashed with Returns") {
              //Set Returned Date to Empty ''.
              await ref
                  .read(chequeNotifierProvider.notifier)
                  .updateChequeListDate(
                      chequeNoList: deposit.chequeNos,
                      date: '',
                      type: DateType.returnedDate);

              //Set Return reason to Empty ''.
              ref
                  .read(chequeNotifierProvider.notifier)
                  .setReturnInfo(chequeNoList: deposit.chequeNos, reason: '');
              for (var chequeNo in deposit.chequeNos) {
                await updateInvoiceBalance(chequeNo: chequeNo);
              }
            }
            //Delete Cheque Deposit
            await ref
                .read(chequeDepositNotifierProvider.notifier)
                .removeChequeDeposit(deposit.id);
          },
        );
      },
    );
  }
}
