import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/model/cheque_deposit.dart';
import 'package:yalapay/providers/banks_provider.dart';
import 'package:yalapay/providers/cheque_deposit_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/providers/deleted_cheques_provider.dart';
import 'package:yalapay/routes/app_router.dart';
import 'package:yalapay/styling/background.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_yalapay.dart';
import 'package:yalapay/widget/filter_dropdown.dart';

class ChequeScreen extends ConsumerStatefulWidget {
  const ChequeScreen({super.key});

  @override
  ConsumerState<ChequeScreen> createState() => _ChequeScreenState();
}

class _ChequeScreenState extends ConsumerState<ChequeScreen> {
  String? selectedAccount;
  List<Cheque> selectedCheques = [];
  var selectAll = false;

  bool isChequeInSelected(Cheque cheque) => selectedCheques.contains(cheque);

  bool isFilled() => selectedCheques.isNotEmpty && selectedAccount != null;

  SnackBar chequeDepositSuccess = const SnackBar(
    backgroundColor: lightSecondary,
    content: Text(
      'Cheques have been deposited.',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  List<int> getChequeNos() =>
      selectedCheques.map((cheque) => cheque.chequeNo).toList();

  void removeEmptyChequeDeposit(
      List<int> chequeNoList, List<ChequeDeposit> chequeDeposit) {
    List<ChequeDeposit> emptyDeposits = [];
    for (var deposit in chequeDeposit) {
      for (var chequeNo in chequeNoList) {
        if (deposit.chequeNos.contains(chequeNo)) {
          deposit.chequeNos.remove(chequeNo);
        }
      }
      if (deposit.chequeNos.isEmpty) {
        emptyDeposits.add(deposit);
      }
    }
    for (var emptyDeposit in emptyDeposits) {
      ref
          .read(chequeDepositNotifierProvider.notifier)
          .removeChequeDeposit(emptyDeposit.id);
    }
    ref
        .read(deletedChequesNotfierProvider.notifier)
        .removeRecentlyDeletedCheques();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(bankAccountMapProvider);
    final cheques = ref.watch(chequeNotifierProvider);
    var chequeDeposits = ref.watch(chequeDepositNotifierProvider);
    return cheques.when(
      data: (chequesList) {
        final chequesAwaiting =
            chequesList.where((cheque) => cheque.status == 'Awaiting').toList();
        return BackgroundGradient(
          colors: const [darkSecondary, darkPrimary],
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: buildHeader(),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: accounts.when(
                        data: (accountList) {
                          final accountListString = accountList
                              .map((account) =>
                                  "${account.accountNo} : ${account.bank}")
                              .toList();
                          final options = ["Accounts", ...accountListString];
                          return FilterDropdown(
                            selectedFilter: selectedAccount ?? options.first,
                            options: options,
                            onSelected: (value) {
                              setState(() {
                                selectedAccount =
                                    value != "Accounts" ? value : null;
                              });
                            },
                          );
                        },
                        error: (err, stack) => Text('Error: $err'),
                        loading: () => const CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectAllRow(
                      selectAll: selectAll,
                      toggleSelectAll: (value) => setState(() {
                        selectAll = value;
                        if (selectAll) {
                          selectedCheques = [...chequesAwaiting];
                        } else {
                          selectedCheques.clear();
                        }
                      }),
                    ),
                    Expanded(
                      child: chequesAwaiting.isEmpty
                          ? const EmptyScreen()
                          : AwaitingChequesList(
                              cheques: chequesAwaiting,
                              selectedCheques: selectedCheques,
                              onSelectCheque: (cheque) => setState(() {
                                if (isChequeInSelected(cheque)) {
                                  selectedCheques.remove(cheque);
                                } else {
                                  selectedCheques.add(cheque);
                                }
                                selectAll = selectedCheques.length ==
                                    chequesAwaiting.length;
                              }),
                            ),
                    ),
                    const SizedBox(height: 10),
                    chequeDeposits.when(
                      data: (depositsList) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: CreateDepositButton(
                                isFilled: isFilled(),
                                onPressed: () =>
                                    createChequeDeposit(context, depositsList),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: NavigationButton(
                                chequeDeposits: depositsList,
                                removeEmptyChequeDeposit:
                                    removeEmptyChequeDeposit,
                              ),
                            ),
                          ],
                        );
                      },
                      error: (err, stack) => Text('Error: $err'),
                      loading: () => const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (err, stack) => Text('Error: $err'),
      loading: () => const CircularProgressIndicator(),
    );
  }

  AppBar buildHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          Text(
            'Cheque Deposits',
            style: getTextStyle('xlargeBold', color: Colors.white),
          ),
        ],
      ),
      actions: const [YalapayIcon(), SizedBox(width: 16)],
    );
  }

  void createChequeDeposit(
      BuildContext context, List<ChequeDeposit> chequeDeposits) {
    setState(() {
      if (!isFilled()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please select an account and at least one cheque.')),
        );
        return;
      }
      var deletedCheques = ref.watch(deletedChequesNotfierProvider);
      removeEmptyChequeDeposit(deletedCheques, chequeDeposits);

      ChequeDeposit newChequeDeposit = ChequeDeposit(
        id: '-1',
        depositDate: DateTime.now().toString().substring(0, 10),
        bankAccountNo: selectedAccount!.substring(0, 11),
        status: 'Deposited',
        chequeNos: getChequeNos(),
      );

      ref
          .read(chequeDepositNotifierProvider.notifier)
          .addChequeDeposit(newChequeDeposit);

      for (var number in getChequeNos()) {
        ref.read(chequeNotifierProvider.notifier).updateNewlyDepositedCheques(
            chequeNo: number,
            status: 'Deposited',
            date: DateTime.now().toString().substring(0, 10));
      }
      selectAll = false;
      selectedCheques = [];
      selectedAccount = null;
      ScaffoldMessenger.of(context).showSnackBar(chequeDepositSuccess);
    });
  }
}

class NavigationButton extends ConsumerWidget {
  final Function(List<int>, List<ChequeDeposit>) removeEmptyChequeDeposit;
  final List<ChequeDeposit> chequeDeposits;
  const NavigationButton(
      {super.key,
      required this.removeEmptyChequeDeposit,
      required this.chequeDeposits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var deletedCheques = ref.watch(deletedChequesNotfierProvider);
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        style: purpleButtonStyle,
        onPressed: () {
          removeEmptyChequeDeposit(deletedCheques, chequeDeposits);
          context.pushNamed(AppRouter.chequeDeposits.name);
        },
        child: Text(
          'View Deposits',
          style: getTextStyle('small', color: Colors.white),
        ),
      ),
    );
  }
}

class SelectAllRow extends StatelessWidget {
  final bool selectAll;
  final ValueChanged<bool> toggleSelectAll;

  const SelectAllRow(
      {super.key, required this.selectAll, required this.toggleSelectAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('Awaiting Deposits',
            style: getTextStyle('mediumBold', color: Colors.white)),
        const SizedBox(width: 40),
        Text('Select All', style: getTextStyle('small', color: Colors.white)),
        Checkbox(
          checkColor: const Color.fromARGB(255, 11, 11, 11),
          activeColor: lightSecondary,
          side: const BorderSide(color: lightPrimary, width: 2),
          value: selectAll,
          onChanged: (value) => toggleSelectAll(value!),
        ),
      ],
    );
  }
}

class AwaitingChequesList extends StatelessWidget {
  final List<Cheque> cheques;
  final List<Cheque> selectedCheques;
  final ValueChanged<Cheque> onSelectCheque;

  const AwaitingChequesList({
    required this.cheques,
    required this.selectedCheques,
    required this.onSelectCheque,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cheques.length,
      itemBuilder: (context, index) {
        final cheque = cheques[index];
        final difference =
            DateTime.parse(cheque.dueDate).difference(DateTime.now()).inDays;
        return Card(
          color: Colors.transparent,
          child: ListTile(
            onTap: () => onSelectCheque(cheque),
            leading: const CircleAvatar(
              backgroundColor: lightSecondary,
              child: Icon(Icons.receipt_rounded, color: Colors.white),
            ),
            trailing: Icon(
              selectedCheques.contains(cheque)
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank,
              color: selectedCheques.contains(cheque)
                  ? lightSecondary
                  : lightPrimary,
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Cheque Number: ${cheque.chequeNo}',
                  style: getTextStyle("smallBold", color: lightSecondary)),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Text("QR ${cheque.amount.toStringAsFixed(2)}",
                      style: getTextStyle("largeBold", color: Colors.white)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("${cheque.drawer}",
                      style: getTextStyle("smallBold", color: Colors.white)),
                  Text("${cheque.bankName}",
                      style: getTextStyle("small", color: Colors.white)),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("Due Date: ${cheque.dueDate} ($difference)",
                      style: differenceStyle(difference)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreateDepositButton extends StatelessWidget {
  final bool isFilled;
  final VoidCallback onPressed;

  const CreateDepositButton(
      {super.key, required this.isFilled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFilled
            ? onPressed
            : () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Incomplete Fields"),
                      content: const Text(
                          "An account and a deposit must be selected."),
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
                ),
        style: isFilled ? purpleButtonStyle : greyButtonStyle,
        child: Text(
          'Create Deposit',
          style: getTextStyle('small', color: Colors.white),
        ),
      ),
    );
  }
}

TextStyle differenceStyle(int difference) {
  return getTextStyle('small',
      color: difference < 0 ? Colors.red : Colors.green);
}
