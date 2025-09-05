import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/widget/details_row.dart';
import 'package:yalapay/widget/special_text.dart';

class ChequeDepositDetailsScreen extends ConsumerStatefulWidget {
  final String chequeDepositId;
  const ChequeDepositDetailsScreen({super.key, required this.chequeDepositId});

  @override
  ConsumerState<ChequeDepositDetailsScreen> createState() =>
      ChequeDepositDetailsScreenState();
}

class ChequeDepositDetailsScreenState
    extends ConsumerState<ChequeDepositDetailsScreen> {
  bool showInfo = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  void toggleInfoVisibility() {
    setState(() {
      showInfo = !showInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chequesNoList = ref
        .read(chequeDepositNotifierProvider.notifier)
        .getChequesList(widget.chequeDepositId);
    final chequesList =
        ref.read(chequeNotifierProvider.notifier).getChequesByNo(chequesNoList);
    final totalAmount = chequesList
        .map((c) => c.amount)
        .reduce((value, element) => value + element);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
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
              Text("Deposit Details",
                  style: getTextStyle('largeBold', color: Colors.white)),
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
          actions: [
            IconButton(
              icon: Icon(showInfo ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleInfoVisibility,
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
            Padding(
              padding: showInfo
                  ? const EdgeInsets.fromLTRB(8, 205, 8, 0)
                  : const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ListView.builder(
                itemCount: chequesList.length,
                itemBuilder: (context, index) {
                  return buildChequeCard(chequesList[index]);
                },
              ),
            ),
            if (showInfo)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: buildTotalInfo(totalAmount, chequesList.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildChequeCard(dynamic cheque) {
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
                  Text('Cheque No: ${cheque.chequeNo}',
                      style: getTextStyle('smallBold', color: lightSecondary)),
                  const SizedBox(height: 5),
                  Text('QR ${cheque.amount.toStringAsFixed(2)}',
                      style: getTextStyle('largeBold', color: Colors.white)),
                  const SizedBox(height: 10),
                  specialText("${cheque.status}"),
                  const SizedBox(height: 10),
                  Text('${cheque.drawer}',
                      style: getTextStyle('smallBold', color: Colors.white)),
                  Text('${cheque.bankName}',
                      style: getTextStyle('small', color: Colors.white)),
                  const SizedBox(height: 5),
                  Text('Receive Date: ${cheque.receivedDate}',
                      style: getTextStyle('small', color: Colors.grey)),
                  Text('Due Date: ${cheque.dueDate}',
                      style: getTextStyle('smallLight', color: Colors.grey)),
                  cheque.status == "Cashed"
                      ? Text('Cashed Date: ${cheque.cashedDate}',
                          style: getTextStyle('smallLight', color: Colors.grey))
                      : Container(),
                  cheque.status == "Cashed with Returns"
                      ? Column(
                          children: [
                            Text('Returned Date: ${cheque.returnedDate}',
                                style: getTextStyle('smallLight',
                                    color: Colors.grey)),
                            Text('Return Reason: ${cheque.returnReason}',
                                style: getTextStyle('smallLight',
                                    color: Colors.grey)),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTotalInfo(double totalAmount, int chequeCount) {
    return Card(
      color: darkTertiary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.assessment_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Cheque Details Report Summary",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            DetailsRow(
              label: "Total Amount:",
              value: "QR $totalAmount",
              special: true,
            ),
            DetailsRow(
              label: "Number of Cheques:",
              value: "$chequeCount ${chequeCount > 1 ? 'cheques' : 'cheque'}",
              special: true,
              divider: false,
            ),
          ],
        ),
      ),
    );
  }
}
