import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/screens/common_screens/report_screen.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

//If number of cheques in this deposit is 1 it has only the option to return and not cashed.
class ChequeDepositUpdateScreen extends ConsumerStatefulWidget {
  final String chequeDepositId;
  const ChequeDepositUpdateScreen({super.key, required this.chequeDepositId});

  @override
  ConsumerState<ChequeDepositUpdateScreen> createState() =>
      _ChequeDepositUpdateScreenState();
}

class _ChequeDepositUpdateScreenState
    extends ConsumerState<ChequeDepositUpdateScreen> {
  List<Map<String, dynamic>> dropDownMenuStates = [];

  @override
  void initState() {
    super.initState();
    List<int> chequesNoList;
    ref
        .read(chequeDepositNotifierProvider.notifier)
        .getChequesNoList(widget.chequeDepositId)
        .then((chequesNo) {
      chequesNoList = chequesNo;
      initializeDropDownMenuState(chequesNoList.length);
    });
  }

  void initializeDropDownMenuState(int length) {
    for (int i = 0; i < length; i++) {
      Map<String, dynamic> dropDownMenuState = {
        "Status": "Returned",
        "Reason": "No funds/insufficient funds",
        "ReturnDate": DateTime.now(),
      };
      dropDownMenuStates.add(dropDownMenuState);
    }
  }

  void handleStatusUpdate(List<Cheque> chequeList) async {
    ref
        .read(chequeDepositNotifierProvider.notifier)
        .updateStatus(widget.chequeDepositId, "Cashed with Returns");

    int index = 0;
    for (var cheque in chequeList) {
      if (dropDownMenuStates[index]['Status'] == "Cashed") {
        cheque.status = "Cashed";
        cheque.cashedDate = DateTime.now().toString().substring(0, 10);
        ref.read(chequeNotifierProvider.notifier).updateCheque(cheque);
      } else {
        cheque.status = "Returned";
        cheque.returnedDate = DateTime.now().toString().substring(0, 10);
        cheque.returnReason = dropDownMenuStates[index]['Reason'];
        ref.read(chequeNotifierProvider.notifier).updateCheque(cheque);
        await updateInvoiceBalance(chequeNo: cheque.chequeNo);
      }
      index++;
    }
    context.pop();
  }

  Future<void> updateInvoiceBalance({required int chequeNo}) async {
    ref.watch(chequeNotifierProvider);
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
    ref.read(chequeNotifierProvider).when(
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ref
            .read(chequeDepositNotifierProvider.notifier)
            .getChequesNoList(widget.chequeDepositId),
        builder: (context, snapshot1) {
          if (snapshot1.data == null) {
            return const CircularProgressIndicator();
          }
          return FutureBuilder(
              future: ref
                  .read(chequeNotifierProvider.notifier)
                  .getChequesByNo(snapshot1.data!),
              builder: (context, snapshot2) {
                if (snapshot2.data == null) {
                  return const CircularProgressIndicator();
                }
                return PopScope(
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
                    extendBodyBehindAppBar: true,
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
                      title: Row(
                        children: [
                          Text("Update Deposit",
                              style: getTextStyle('largeBold',
                                  color: Colors.white)),
                        ],
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          ref
                              .read(showNavBarNotifierProvider.notifier)
                              .showBottomNavBar(false);
                          Navigator.of(context).pop();
                        },
                      ),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: ListView.builder(
                            itemCount: snapshot2.data!.length,
                            itemBuilder: (context, index) {
                              return buildChequeCard(
                                  snapshot2.data![index], index);
                            },
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: FloatingActionButton.extended(
                        onPressed: () {
                          handleStatusUpdate(snapshot2.data!);
                        },
                        icon: const Icon(Icons.update, color: Colors.white),
                        label: Text(
                          "Update Cheques Status",
                          style: getTextStyle('small', color: Colors.white),
                        ),
                        backgroundColor: lightPrimary),
                  ),
                );
              });
        });
  }

  Widget buildChequeCard(Cheque cheque, int index) {
    return Card(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InstaImageViewer(
                  child: Image.asset(
                      'assets/images/cheques/${cheque.chequeImageUri}'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Cheque No: ${cheque.chequeNo} - QR ${cheque.amount.toStringAsFixed(2)}',
                      style: getTextStyle('smallBold', color: lightSecondary)),
                  const SizedBox(height: 5),
                  Text(cheque.drawer,
                      style: getTextStyle('smallBold', color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(cheque.bankName,
                      style: getTextStyle('smallBold', color: Colors.white)),
                  const SizedBox(height: 5),
                  updateDropDowns(
                    context,
                    ref.watch(chequeStatusProvider),
                    ref.watch(returnReasonProvider),
                    index,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget updateDropDowns(
    BuildContext context,
    AsyncValue<List<String>> chequeStatusList,
    AsyncValue<List<String>> returnReasonList,
    int index,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text("Cheque Status",
                style: getTextStyle('small', color: Colors.white)),
          ],
        ),
        const SizedBox(height: 5),
        chequeStatusList.when(
          data: (statusList) {
            if (!statusList.contains("Cashed")) {
              statusList.add("Cashed");
            }
            statusList.remove("Deposited");
            statusList.remove("Awaiting");
            if (dropDownMenuStates.length == 1) {
              statusList.remove("Cashed");
            }
            return SizedBox(
              height: 30,
              width: double.infinity,
              child: FilterDropdown(
                selectedFilter: dropDownMenuStates[index]["Status"],
                options: statusList,
                onSelected: (newValue) {
                  setState(() {
                    dropDownMenuStates[index]["Status"] = newValue!;
                  });
                },
              ),
            );
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        ),
        if (dropDownMenuStates[index]["Status"] == "Returned")
          Column(
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  Text("Return Reason",
                      style: getTextStyle('small', color: Colors.white)),
                ],
              ),
              const SizedBox(height: 5),
              returnReasonList.when(
                data: (reasonList) => SizedBox(
                  height: 30,
                  child: FilterDropdown(
                    selectedFilter: dropDownMenuStates[index]["Reason"],
                    options: reasonList,
                    onSelected: (newValue) {
                      setState(() {
                        dropDownMenuStates[index]["Reason"] = newValue!;
                      });
                    },
                  ),
                ),
                error: (err, stack) => Text('Error: $err'),
                loading: () => const CircularProgressIndicator(),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text("Return Date",
                      style: getTextStyle('small', color: Colors.white)),
                ],
              ),
              const SizedBox(height: 5),
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
                        dropDownMenuStates[index]["ReturnDate"] = value;
                      });
                    }
                  });
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: DateField(
                    color: darkTertiary,
                    label:
                        '${dropDownMenuStates[index]["ReturnDate"].year}-${dropDownMenuStates[index]["ReturnDate"].month}-${dropDownMenuStates[index]["ReturnDate"].day}',
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 5),
      ],
    );
  }
}
