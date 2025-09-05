import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/styling/frosted_glass.dart';
import 'package:yalapay/widget/details_row.dart';
import 'package:yalapay/widget/filter_dropdown.dart';
import 'package:yalapay/widget/update_record_confirmation.dart';
import '../../widget/section_title_with_icon.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  final String paymentId;
  const PaymentDetailsScreen({super.key, required this.paymentId});

  @override
  ConsumerState<PaymentDetailsScreen> createState() =>
      _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  bool isEditing = false;
  String? dueDate;
  String? selectedImageUri;
  Cheque? cheque;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });
  }

  // Will do for cheque status's cashed and cashed with returns on phase 2 since
  //cheque-deposit.json only has depositDate for now.
  void setDatesForCheque(Cheque cheque) {
    var chequeDeposits = ref.read(chequeDepositNotifierProvider);

    for (var deposit in chequeDeposits) {
      if (deposit.chequeNos.contains(cheque.chequeNo)) {
        cheque.depositDate = deposit.depositDate;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(selectedInvoiceNotifierProvider);
    var payments = invoice.payments;
    Payment payment = payments.firstWhere((p) => p.id == widget.paymentId);

    if (payment.paymentMode == 'Cheque') {
      var chequeList = ref.read(chequeNotifierProvider);
      cheque = chequeList.firstWhere((c) => c.chequeNo == payment.chequeNo);
      if (cheque?.status == "Deposited" && cheque?.depositDate == '') {
        setDatesForCheque(cheque!);
      }
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

    void updateCheque() {
      if (dueDate != null && dueDate != cheque!.dueDate) {
        ref
            .read(chequeNotifierProvider.notifier)
            .updateChequeDue(cheque!.chequeNo, dueDate!);
      }
      if (selectedImageUri != null &&
          selectedImageUri != cheque!.chequeImageUri) {
        ref
            .read(chequeNotifierProvider.notifier)
            .updateChequeImage(cheque!.chequeNo, selectedImageUri!);
      }
      setState(() {
        isEditing = false;
      });
    }

    void showUpdateConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            type: "Cheque",
            title: "Confirm Update",
            content: "Are you sure you want to update the cheque details?",
            onConfirm: updateCheque,
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                  "Editing Payment",
                  style: getTextStyle('largeBold', color: Colors.white),
                )
              : Text(
                  "Payment Details",
                  style: getTextStyle('largeBold', color: Colors.white),
                ),
          centerTitle: true,
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
            if (payment.paymentMode == 'Cheque')
              IconButton(
                icon: Icon(isEditing ? Icons.done : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                    dueDate = cheque?.dueDate;
                    selectedImageUri = cheque?.chequeImageUri;
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
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: getInvoiceStatusColor(payment.paymentMode),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          "Payment ID: ${widget.paymentId}",
                          style:
                              getTextStyle('xlargeBold', color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FrostedGlassBox(
                        boxWidth: double.infinity,
                        boxChild: PaymentDetailsSection(payment: payment),
                      ),
                    ),
                    if (payment.paymentMode == 'Cheque') ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FrostedGlassBox(
                          boxWidth: double.infinity,
                          boxChild: ChequeDetailsSection(
                            cheque: cheque!,
                            isEditing: isEditing,
                            dueDate: dueDate,
                            selectDate: selectDate,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FrostedGlassBox(
                          boxWidth: double.infinity,
                          boxChild: ChequeImageSection(
                            cheque: cheque!,
                            isEditing: isEditing,
                            selectedImageUri:
                                selectedImageUri ?? cheque!.chequeImageUri,
                            onImageSelected: (newImageUri) {
                              setState(() {
                                selectedImageUri = newImageUri;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: isEditing
            ? ClipRRect(
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
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          showUpdateConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Update",
                          style: getTextStyle('small', color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class ChequeImageSection extends StatelessWidget {
  final Cheque cheque;
  final bool isEditing;
  final String selectedImageUri;
  final Function(String) onImageSelected;

  const ChequeImageSection({
    super.key,
    required this.cheque,
    required this.isEditing,
    required this.selectedImageUri,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = imageList.map((image) => image['value'] as String).toList();
    String selectedFilter =
        options.contains(selectedImageUri) ? selectedImageUri : options.first;

    return DetailsSection(
      title: "Cheque Image",
      icon: Icons.image,
      children: [
        const SizedBox(height: 10),
        if (isEditing)
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: FilterDropdown(
                    selectedFilter: selectedFilter,
                    options: options,
                    onSelected: (String? newImage) {
                      if (newImage != null) {
                        onImageSelected(newImage);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        SizedBox(
          height: 150,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InstaImageViewer(
              disposeLevel: DisposeLevel.low,
              child: Image.asset(
                'assets/images/cheques/$selectedFilter',
                // fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class PaymentDetailsSection extends StatelessWidget {
  final Payment payment;

  const PaymentDetailsSection({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      title: "Payment Details",
      icon: Icons.payment,
      children: [
        DetailsRow(
          label: "Amount",
          value: 'QR ${payment.amount.toString()}',
          special: true,
        ),
        DetailsRow(label: "Payment Date", value: payment.paymentDate),
        DetailsRow(
          label: "Payment Mode",
          value: payment.paymentMode,
          divider: false,
        ),
      ],
    );
  }
}

class ChequeDetailsSection extends StatelessWidget {
  final Cheque cheque;
  final bool isEditing;
  final String? dueDate;
  final Function(BuildContext) selectDate;

  const ChequeDetailsSection({
    super.key,
    required this.cheque,
    required this.isEditing,
    required this.dueDate,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    return DetailsSection(
      title: "Cheque Details",
      icon: Icons.description,
      children: [
        DetailsRow(label: "Cheque No", value: cheque.chequeNo.toString()),
        DetailsRow(label: "Drawer", value: cheque.drawer),
        DetailsRow(label: "Drawer Bank", value: cheque.bankName),
        DetailsRow(label: "Status", value: cheque.status, special: true),
        isEditing
            ? GestureDetector(
                onTap: () => selectDate(context),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: borderColor, width: 1)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("Due Date",
                              style: getTextStyle('smallBold',
                                  color: Colors.white)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: lightSecondary, width: 2.0),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              dueDate ?? cheque.dueDate,
                              style: getTextStyle('small', color: Colors.white),
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
            : DetailsRow(label: "Due Date", value: cheque.dueDate),
        DetailsRow(label: "Receive Date", value: cheque.receivedDate),
        if (cheque.depositDate.isNotEmpty)
          DetailsRow(label: "Deposit Date", value: cheque.depositDate),
        if (cheque.cashedDate.isNotEmpty)
          DetailsRow(label: "Cashed Date", value: cheque.cashedDate),
        if (cheque.status == "Returned") ...[
          DetailsRow(label: "Returned Date", value: cheque.returnedDate),
          DetailsRow(
            label: "Return Reason",
            value: cheque.returnReason,
            divider: false,
          ),
        ]
      ],
    );
  }
}

class DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const DetailsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SectionTitleWithIcon(
        icon: icon,
        title: title,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
