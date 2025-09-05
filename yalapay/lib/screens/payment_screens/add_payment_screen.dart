import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/payment.dart';
import 'package:yalapay/providers/banks_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/payment_mode_provider.dart';
import 'package:yalapay/providers/payment_provider.dart';
import 'package:yalapay/providers/selected_invoice_provider.dart';
import 'package:yalapay/providers/show_nav_bar_provider.dart';
import 'package:yalapay/widget/add_screen_text_field.dart';
import 'package:yalapay/widget/filter_dropdown.dart';
import 'package:yalapay/widget/section_title_with_icon.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  ConsumerState<AddPaymentScreen> createState() => AddPaymentScreenState();
}

class AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final amountController = TextEditingController();
  final modeController = TextEditingController(text: 'Bank transfer');
  final chequeNoController = TextEditingController();
  final drawerController = TextEditingController();
  final drawerBankController = TextEditingController();

  bool optionSelected = true;
  bool isChequeMode = false;
  DateTime? selectedDueDate;
  String selectedImage = 'cheque1.jpg';

  final existingChequeSnackBar = const SnackBar(
    backgroundColor: lightSecondary,
    content: Text(
      'This cheque number is already in the database, please write a unique cheque number.',
    ),
  );

  final paymentSuccessfulSnackBar = const SnackBar(
    content: Text(
      'Payment Added',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(showNavBarNotifierProvider.notifier).showBottomNavBar(false);
    });

    ref.read(chequeNotifierProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final paymentModes = ref.watch(paymentModeProvider);
    final banks = ref.watch(bankProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),
            title: Text(
              "Add Payment",
              style: getTextStyle('largeBold', color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              buildBackground(),
              SafeArea(
                child: paymentModes.when(
                  data: (list) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Column(
                      children: [
                        buildPaymentDetailsSection(list),
                        const SizedBox(height: 30),
                        if (isChequeMode) buildChequeDetailsSection(banks),
                      ],
                    ),
                  ),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
      child: Container(color: Colors.black.withOpacity(0.3)),
    );
  }

  Widget buildPaymentDetailsSection(List<String> paymentModes) {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.payment,
        title: "Payment Details",
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Payment Mode",
                                style: getTextStyle('smallBold',
                                    color: Colors.white)),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: FilterDropdown(
                                  selectedFilter:
                                      paymentModes.contains(modeController.text)
                                          ? modeController.text
                                          : (paymentModes.isNotEmpty
                                              ? paymentModes.first
                                              : 'Bank transfer'),
                                  options: paymentModes,
                                  onSelected: (value) {
                                    setState(() {
                                      isChequeMode = value == "Cheque";
                                      modeController.text =
                                          value ?? 'Bank transfer';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
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
                              icon: const Icon(Icons.done, color: Colors.white),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(DateTime.now().toString().substring(0, 10),
                          style: getTextStyle('small', color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChequeDetailsSection(AsyncValue<List<String>> banks) {
    return StyledContainer(
      child: SectionTitleWithIcon(
        icon: Icons.description,
        title: "Cheque Details",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            AddScreensTextField(
                controller: chequeNoController,
                label: 'Cheque No.',
                type: TextInputType.number,
                activeBorderColor: lightSecondary),
            const SizedBox(height: 20),
            AddScreensTextField(
                controller: drawerController,
                label: 'Drawer',
                activeBorderColor: lightSecondary),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: banks.when(
                data: (list) => FilterDropdown(
                  selectedFilter: drawerBankController.text.isNotEmpty &&
                          list.contains(drawerBankController.text)
                      ? drawerBankController.text
                      : 'Select a drawer bank',
                  options: ['Select a drawer bank', ...list],
                  onSelected: (value) =>
                      setState(() => drawerBankController.text = value!),
                ),
                error: (err, stack) => Text("Error: $err"),
                loading: () => const CircularProgressIndicator(),
              ),
            ),
            const SizedBox(height: 20),
            buildChequeImageDropdown(),
            const SizedBox(height: 20),
            buildDueDateButton(),
          ],
        ),
      ),
    );
  }

  Widget buildChequeImageDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Cheque Image', style: getTextStyle('small', color: Colors.white)),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            dropdownColor: darkTertiary,
            menuMaxHeight: 200,
            value: selectedImage.isNotEmpty &&
                    imageList.any((item) => item['value'] == selectedImage)
                ? selectedImage
                : imageList.isNotEmpty
                    ? imageList.first['value']
                    : null,
            items: imageList.map((item) {
              return DropdownMenuItem(
                value: item['value'],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Image.asset(item['image'], height: 100),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedImage = newValue as String;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildDueDateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Due Date", style: getTextStyle('small', color: Colors.white)),
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null)
                setState(() => selectedDueDate = pickedDate);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lightPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              selectedDueDate?.toIso8601String().split('T').first ??
                  "Select Due Date",
              style: getTextStyle('small', color: Colors.white),
            ),
          ),
        ),
      ],
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
                    onPressed: () => handleAddPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Add Payment",
                        style: getTextStyle('small', color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: clearAllFields,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Clear All",
                        style: getTextStyle('small', color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleAddPayment(BuildContext context) {
    if (!isAllFieldsFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    final invoice = ref.read(selectedInvoiceNotifierProvider);
    final amount = double.parse(amountController.text);
    final dateNow = DateTime.now().toString().substring(0, 10);
    final payments = ref.read(paymentNotifierProvider);

    String newPaymentId = (int.parse(payments.last.id) + 1).toString();
    Payment newPayment = Payment(
      id: newPaymentId,
      invoiceNo: invoice.id,
      amount: amount,
      paymentDate: dateNow,
      paymentMode: modeController.text,
    );

    if (isChequeMode) {
      int newChequeNo = int.parse(chequeNoController.text);
      bool isDuplicate = ref
          .read(chequeNotifierProvider.notifier)
          .checkIdDuplicate(newChequeNo);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(existingChequeSnackBar);
        return;
      }
      newPayment.chequeNo = newChequeNo;
      Cheque newCheque = Cheque(
        chequeNo: newChequeNo,
        amount: amount,
        drawer: drawerController.text,
        bankName: drawerBankController.text,
        status: 'Awaiting',
        receivedDate: dateNow,
        dueDate: selectedDueDate.toString().substring(0, 10),
        chequeImageUri: selectedImage,
      );
      ref.read(chequeNotifierProvider.notifier).addCheque(newCheque);
    }

    ref.read(paymentNotifierProvider.notifier).addPayment(newPayment, false);
    ref
        .read(selectedInvoiceNotifierProvider.notifier)
        .addNewPayment(newPayment, ref.read(chequeNotifierProvider));
    ref.read(invoiceNotifierProvider.notifier)
      ..removeInvoice(invoice.id)
      ..addInvoice(invoice);

    clearAllFields();
    ScaffoldMessenger.of(context).showSnackBar(paymentSuccessfulSnackBar);
  }

  bool isAllFieldsFilled() {
    bool isFilled =
        amountController.text.isNotEmpty && modeController.text.isNotEmpty;

    if (isChequeMode) {
      isFilled &= chequeNoController.text.isNotEmpty &&
          drawerController.text.isNotEmpty &&
          drawerBankController.text.isNotEmpty &&
          selectedDueDate != null;
    }

    return isFilled;
  }

  void clearAllFields() {
    amountController.clear();
    chequeNoController.clear();
    drawerController.clear();
    drawerBankController.clear();
    selectedDueDate = null;
    selectedImage = 'cheque1.jpg';
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
