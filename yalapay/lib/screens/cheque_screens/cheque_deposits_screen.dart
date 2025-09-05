import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/deposit_status_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/return_reason_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/screens/common_screens/report_screen.dart';
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
  String returnDropdownValue = "No funds/insufficient funds";
  DateTime dateTime = DateTime.now();
  List<ChequeDeposit> selectedDeposits = [];

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
    return selectedDeposits.isNotEmpty;
  }

  void updateInvoiceBalance({required int chequeNo}) {
    ref.watch(paymentNotifierProvider);
    ref.watch(invoiceNotifierProvider);
    final cheques = ref.watch(chequeNotifierProvider);
    try {
      Payment payment = ref
          .read(paymentNotifierProvider.notifier)
          .getPaymentWithChequeNo(chequeNo);
      Invoice invoice = ref
          .read(invoiceNotifierProvider.notifier)
          .getInvoice(payment.invoiceNo);
      invoice.updateInvoiceBalance(cheques);
      invoice.updateStatus();
    } catch (e) {
      print(e);
    }
  }

  void showDatePickerDialog() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101))
        .then((value) {
      setState(() {
        if (value != null) {
          dateTime = value;
        }
      });
    });
  }

  void handleStatusUpdate() {
    setState(() {
      for (var deposit in selectedDeposits) {
        ref
            .read(chequeDepositNotifierProvider.notifier)
            .updateStatus(deposit.id, statusDropdownValue);

        if (statusDropdownValue == "Cashed") {
          ref.read(chequeNotifierProvider.notifier).updateChequeListStatus(
              chequeNoList: deposit.chequeNos, status: statusDropdownValue);
        }

        if (statusDropdownValue == "Cashed" ||
            statusDropdownValue == "Cashed with Returns") {
          ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
              chequeNoList: deposit.chequeNos,
              date: DateTime.now().toString().substring(0, 10),
              type: DateType.cashedDate);
        }

        if (statusDropdownValue == "Cashed with Returns") {
          ref.read(chequeNotifierProvider.notifier).updateChequeListStatus(
              chequeNoList: deposit.chequeNos, status: "Returned");
          ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
              chequeNoList: deposit.chequeNos,
              date: dateTime.toString().substring(0, 10),
              type: DateType.returnedDate);
          ref.read(chequeNotifierProvider.notifier).setReturnInfo(
              chequeNoList: deposit.chequeNos, reason: returnDropdownValue);
          for (var chequeNo in deposit.chequeNos) {
            updateInvoiceBalance(chequeNo: chequeNo);
          }
        }
      }
      selectedDeposits = [];
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
              height: screenHeight(context) * 0.6,
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
                    if (statusDropdownValue == "Cashed with Returns")
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text("Return Reason",
                                  style: getTextStyle('medium',
                                      color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          returnReasonList.when(
                            data: (reasonList) => FilterDropdown(
                              selectedFilter: returnDropdownValue,
                              options: reasonList,
                              onSelected: (newValue) {
                                setState(() {
                                  returnDropdownValue = newValue!;
                                });
                                setModalState(() {
                                  returnDropdownValue = newValue!;
                                });
                              },
                            ),
                            error: (err, stack) => Text('Error: $err'),
                            loading: () => const CircularProgressIndicator(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text("Return Date",
                                  style: getTextStyle('medium',
                                      color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    dateTime = value;
                                  });
                                  setModalState(() {
                                    dateTime = value;
                                  });
                                }
                              });
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: DateField(
                                label:
                                    '${dateTime.year}-${dateTime.month}-${dateTime.day}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    buildUpdateButton(),
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
          ref.read(chequeNotifierProvider.notifier).setByStatus('Awaiting');
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
    final isSelected = selectedDeposits.contains(deposit);

    return GestureDetector(
      onTap: () {
        if (deposit.status == 'Deposited') {
          setState(() {
            if (isSelected) {
              selectedDeposits.remove(deposit);
            } else {
              selectedDeposits.add(deposit);
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
                      'Deposit ID: ${deposit.id}',
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

  Widget buildReturnReasonSection(
      AsyncValue<List<String>> returnReasonList, StateSetter setModalState) {
    return returnReasonList.when(
      data: (reasonList) => FilterDropdown(
        selectedFilter: returnDropdownValue,
        options: reasonList,
        onSelected: (newValue) {
          setModalState(() {
            returnDropdownValue = newValue!;
          });
        },
      ),
      error: (err, stack) => Text('Error: $err'),
      loading: () => const CircularProgressIndicator(),
    );
  }

  SizedBox buildReturnDateField(StateSetter setModalState) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          ).then((value) {
            if (value != null) {
              setModalState(() {
                dateTime = value;
              });
            }
          });
        },
        child: SizedBox(
          width: double.infinity,
          child: DateField(
            label: '${dateTime.year}-${dateTime.month}-${dateTime.day}',
          ),
        ),
      ),
    );
  }

  SizedBox buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFilled() ? handleStatusUpdate : handleIncompleteFields,
        style: isFilled() ? purpleButtonStyle : greyButtonStyle,
        child:
            Text("Update", style: getTextStyle('small', color: Colors.white)),
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
          ref.read(chequeNotifierProvider.notifier).setByStatus('Awaiting');
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
                  Expanded(child: buildChequeDepositList(chequeDeposits)),
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
            setState(() {
              //Update Individual Cheque Status to Awaiting.
              ref.read(chequeNotifierProvider.notifier).updateChequeListStatus(
                  chequeNoList: deposit.chequeNos, status: 'Awaiting');

              //Set Deposit Date to Empty ''.
              ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
                  chequeNoList: deposit.chequeNos,
                  date: '',
                  type: DateType.depositDate);

              if (deposit.status == "Cashed" ||
                  deposit.status == "Cashed with Returns") {
                //Set Cashed Date to Empty ''.
                ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
                    chequeNoList: deposit.chequeNos,
                    date: '',
                    type: DateType.cashedDate);
              }
              if (deposit.status == "Cashed with Returns") {
                //Set Returned Date to Empty ''.
                ref.read(chequeNotifierProvider.notifier).updateChequeListDate(
                    chequeNoList: deposit.chequeNos,
                    date: '',
                    type: DateType.returnedDate);

                //Set Return reason to Empty ''.
                ref
                    .read(chequeNotifierProvider.notifier)
                    .setReturnInfo(chequeNoList: deposit.chequeNos, reason: '');

                //Update Invoice Balance.
                for (var chequeNo in deposit.chequeNos) {
                  updateInvoiceBalance(chequeNo: chequeNo);
                }
              }
              //Delete Cheque Deposit
              ref
                  .read(chequeDepositNotifierProvider.notifier)
                  .removeChequeDeposit(deposit.id);
            });
          },
        );
      },
    );
  }
}
