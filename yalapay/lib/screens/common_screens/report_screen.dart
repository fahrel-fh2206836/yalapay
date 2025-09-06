import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/styling/background.dart';
import 'package:yalapay/providers/invoice_provider.dart';
import 'package:yalapay/providers/cheque_provider.dart';
import 'package:yalapay/widget/cheque_list.dart';
import 'package:yalapay/widget/details_row.dart';
import 'package:yalapay/widget/filter_dropdown.dart';
import 'package:yalapay/widget/icon_yalapay.dart';
import 'package:yalapay/widget/invoice_list.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool showSummary = false;
  List<Invoice> filteredInvoices = [];
  List<Cheque> filteredCheques = [];
  String selectedInvoiceStatus = "All";
  String selectedChequeStatus = "All";
  String? fromInvoiceDate;
  String? toInvoiceDate;
  String? fromChequeDate;
  String? toChequeDate;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    ref.read(invoiceStatusProvider);
    ref.read(chequeStatusProvider);
    Future.microtask(() {
      initializeInvoices();
      initializeCheques();
    });
  }

  void initializeInvoices() {
    ref.read(invoiceNotifierProvider).when(
          data: (invoices) {
            setState(() {
              filteredInvoices = invoices;
            });
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        );
  }

  void initializeCheques() {
    ref.read(chequeNotifierProvider).when(
          data: (cheques) {
            setState(() {
              filteredCheques = cheques;
            });
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        );
  }

  void applyFilters(String status, String? fromDate, String? toDate) {
    ref.watch(invoiceNotifierProvider).when(
          data: (invoices) {
            if (tabController.index == 0) {
              setState(() {
                selectedInvoiceStatus = status;
                fromInvoiceDate = fromDate;
                toInvoiceDate = toDate;
                filteredInvoices = invoices.where((invoice) {
                  bool matchesStatus =
                      (status == "All" || invoice.status == status);
                  bool matchesDate = true;
                  if (fromDate != null && toDate != null) {
                    DateTime from = DateTime.parse(fromDate);
                    DateTime to = DateTime.parse(toDate);
                    DateTime invoiceDate = DateTime.parse(invoice.dueDate);
                    matchesDate =
                        invoiceDate.isAfter(from) && invoiceDate.isBefore(to);
                  }
                  return matchesStatus && matchesDate;
                }).toList();
              });
            } else {
              ref.watch(chequeNotifierProvider).when(
                    data: (cheques) {
                      setState(() {
                        selectedChequeStatus = status;
                        fromChequeDate = fromDate;
                        toChequeDate = toDate;
                        filteredCheques = cheques.where((cheque) {
                          bool matchesStatus =
                              (status == "All" || cheque.status == status);
                          bool matchesDate = true;
                          if (fromDate != null && toDate != null) {
                            DateTime from = DateTime.parse(fromDate);
                            DateTime to = DateTime.parse(toDate);
                            DateTime chequeDate =
                                DateTime.parse(cheque.dueDate);
                            matchesDate = chequeDate.isAfter(from) &&
                                chequeDate.isBefore(to);
                          }
                          return matchesStatus && matchesDate;
                        }).toList();
                      });
                    },
                    error: (err, stack) => Text('Error: $err'),
                    loading: () => const CircularProgressIndicator(),
                  );
            }
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const CircularProgressIndicator(),
        );
  }

  void showFiltersBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: darkPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ReportsFilters(
          statusProvider: ref.watch(
            tabController.index == 0
                ? invoiceStatusProvider
                : chequeStatusProvider,
          ),
          initialStatus: tabController.index == 0
              ? selectedInvoiceStatus
              : selectedChequeStatus,
          initialFromDate:
              tabController.index == 0 ? fromInvoiceDate : fromChequeDate,
          initialToDate:
              tabController.index == 0 ? toInvoiceDate : toChequeDate,
          onConfirmFilters:
              (String selectedStatus, String? fromDate, String? toDate) {
            applyFilters(selectedStatus, fromDate, toDate);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BackgroundGradient(
        colors: const [
          Color.fromARGB(255, 43, 9, 98),
          lightPrimary,
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
                  'Reports',
                  style: getTextStyle('xlargeBold', color: Colors.white),
                ),
              ],
            ),
            actions: const [YalapayIcon(), SizedBox(width: 16)],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      controller: tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: darkPrimary,
                      unselectedLabelColor: Colors.white,
                      tabs: const [
                        Tab(text: 'Invoices'),
                        Tab(text: 'Cheques'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              InvoicesTab(
                showFilters: () => showFiltersBottomSheet(context, ref),
                toggleSummary: () {
                  setState(() {
                    showSummary = !showSummary;
                  });
                },
                showSummary: showSummary,
                filteredInvoices: filteredInvoices,
                selectedStatus: selectedInvoiceStatus,
              ),
              ChequesTab(
                showFilters: () => showFiltersBottomSheet(context, ref),
                toggleSummary: () {
                  setState(() {
                    showSummary = !showSummary;
                  });
                },
                showSummary: showSummary,
                filteredCheques: filteredCheques,
                selectedStatus: selectedChequeStatus,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showFiltersBottomSheet(context, ref),
                    style: purpleButtonStyle,
                    child: Text(
                      "Toggle Filters",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSummary = !showSummary;
                      });
                    },
                    style: purpleButtonStyle,
                    child: Text(
                      "Show Summary",
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsTab extends StatelessWidget {
  final FutureProvider<List<String>> statusProvider;
  final VoidCallback showFilters;
  final VoidCallback toggleSummary;
  final bool showSummary;
  final List<Invoice>? filteredInvoices;
  final List<Cheque>? filteredCheques;
  final bool isInvoiceTab;
  final String selectedStatus;

  const ReportsTab({
    required this.statusProvider,
    required this.showFilters,
    required this.toggleSummary,
    required this.showSummary,
    this.filteredInvoices,
    this.filteredCheques,
    required this.isInvoiceTab,
    required this.selectedStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSummary)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: darkTertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assessment_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${isInvoiceTab ? 'Invoices' : 'Cheques'} Report Summary",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  if (selectedStatus == "All")
                    ...isInvoiceTab
                        ? calculateInvoiceSummary()
                        : calculateChequeSummary(),
                  if (selectedStatus != "All")
                    DetailsRow(
                      label: "$selectedStatus Count",
                      value:
                          "${(isInvoiceTab ? filteredInvoices : filteredCheques)!.length} items",
                      special: true,
                      divider: false,
                    ),
                  DetailsRow(
                    label: "Total Amount",
                    value:
                        "QR ${calculateTotalAmount(isInvoiceTab ? filteredInvoices : filteredCheques).toStringAsFixed(2)}",
                    special: true,
                    divider: false,
                    count: selectedStatus == 'All'
                        ? "Count: ${isInvoiceTab ? filteredInvoices!.length : filteredCheques!.length}"
                        : "",
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: isInvoiceTab
                ? InvoiceList(invoices: filteredInvoices ?? [])
                : ChequeList(cheques: filteredCheques ?? []),
          ),
        ],
      ),
    );
  }

  List<Widget> calculateInvoiceSummary() {
    final items = filteredInvoices;
    if (items == null || items.isEmpty) return [];

    final Map<String, double> totalByStatus = {};
    final Map<String, int> countByStatus = {};

    for (var item in items) {
      totalByStatus[item.status] =
          (totalByStatus[item.status] ?? 0) + item.amount;
      countByStatus[item.status] = (countByStatus[item.status] ?? 0) + 1;
    }

    return totalByStatus.entries.map((entry) {
      final status = entry.key;
      final totalAmount = entry.value;
      final count = countByStatus[status] ?? 0;
      return DetailsRow(
        label: status,
        value: "QR ${totalAmount.toStringAsFixed(2)}",
        special: true,
        count: "Count: $count",
      );
    }).toList();
  }

  List<Widget> calculateChequeSummary() {
    final items = filteredCheques;
    if (items == null || items.isEmpty) return [];

    final Map<String, double> totalByStatus = {};
    final Map<String, int> countByStatus = {};

    for (var item in items) {
      totalByStatus[item.status] =
          (totalByStatus[item.status] ?? 0) + item.amount;
      countByStatus[item.status] = (countByStatus[item.status] ?? 0) + 1;
    }

    return totalByStatus.entries.map((entry) {
      final status = entry.key;
      final totalAmount = entry.value;
      final count = countByStatus[status] ?? 0;
      return DetailsRow(
        label: status,
        value: "QR ${totalAmount.toStringAsFixed(2)}",
        special: true,
        count: "Count: $count",
      );
    }).toList();
  }

  double calculateTotalAmount(List<dynamic>? items) {
    if (items == null) return 0.0;
    return items.fold(0.0, (total, item) => total + item.amount);
  }
}

class InvoicesTab extends StatelessWidget {
  final VoidCallback showFilters;
  final VoidCallback toggleSummary;
  final bool showSummary;
  final List<Invoice> filteredInvoices;
  final String selectedStatus;

  const InvoicesTab({
    required this.showFilters,
    required this.toggleSummary,
    required this.showSummary,
    required this.filteredInvoices,
    required this.selectedStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ReportsTab(
      statusProvider: invoiceStatusProvider,
      showFilters: showFilters,
      toggleSummary: toggleSummary,
      showSummary: showSummary,
      filteredInvoices: filteredInvoices,
      isInvoiceTab: true,
      selectedStatus: selectedStatus,
    );
  }
}

class ChequesTab extends StatelessWidget {
  final VoidCallback showFilters;
  final VoidCallback toggleSummary;
  final bool showSummary;
  final List<Cheque> filteredCheques;
  final String selectedStatus;

  const ChequesTab({
    required this.showFilters,
    required this.toggleSummary,
    required this.showSummary,
    required this.filteredCheques,
    required this.selectedStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ReportsTab(
      statusProvider: chequeStatusProvider,
      showFilters: showFilters,
      toggleSummary: toggleSummary,
      showSummary: showSummary,
      filteredCheques: filteredCheques,
      isInvoiceTab: false,
      selectedStatus: selectedStatus,
    );
  }
}

class ReportsFilters extends ConsumerStatefulWidget {
  final AsyncValue<List<String>> statusProvider;
  final Function(String, String?, String?) onConfirmFilters;
  final String initialStatus;
  final String? initialFromDate;
  final String? initialToDate;

  const ReportsFilters({
    required this.statusProvider,
    required this.onConfirmFilters,
    required this.initialStatus,
    required this.initialFromDate,
    required this.initialToDate,
    super.key,
  });

  @override
  ReportsFiltersState createState() => ReportsFiltersState();
}

class ReportsFiltersState extends ConsumerState<ReportsFilters> {
  late String selectedStatus;
  String? fromDate;
  String? toDate;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        final formattedDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        if (isFromDate) {
          fromDate = formattedDate;
        } else {
          toDate = formattedDate;
        }
        if (fromDate != null &&
            toDate != null &&
            fromDate!.compareTo(toDate!) > 0) {
          fromDate = toDate;
        }
      });
    }
  }

  void clearFilters() {
    setState(() {
      selectedStatus = "All";
      fromDate = null;
      toDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text("Filters",
                  style: getTextStyle('mediumBold', color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => selectDate(context, true),
                  child: DateField(label: fromDate ?? 'From Date'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => selectDate(context, false),
                  child: DateField(label: toDate ?? 'To Date'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          widget.statusProvider.when(
            data: (statuses) {
              final statusOptions = ["All", ...statuses];
              return SizedBox(
                width: double.infinity,
                child: FilterDropdown(
                  selectedFilter: selectedStatus,
                  options: statusOptions,
                  onSelected: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err",
                style: getTextStyle('medium', color: lightSecondary)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onConfirmFilters(selectedStatus, fromDate, toDate);
                  },
                  style: purpleButtonStyle,
                  child: Text("Confirm Filters",
                      style: getTextStyle('small', color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: clearFilters,
                  style: purpleButtonStyle,
                  child: Text("Clear Filters",
                      style: getTextStyle('small', color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DateField extends StatelessWidget {
  final String label;
  final Color color;

  const DateField(
      {super.key, required this.label, this.color = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: lightPrimary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: getTextStyle('small', color: Colors.white),
      ),
    );
  }
}
