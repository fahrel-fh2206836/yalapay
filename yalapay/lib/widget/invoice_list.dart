import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/invoice.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_container.dart';

class InvoiceList extends StatelessWidget {
  final List<Invoice> invoices;
  final void Function(Invoice)? onDelete;
  final void Function(Invoice)? onView;

  const InvoiceList({
    required this.invoices,
    this.onDelete,
    this.onView,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return invoices.isEmpty
        ? const EmptyScreen()
        : ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];

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
                          color: getInvoiceStatusColor(invoice.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              "Invoice ID: ${invoice.id}",
                              style: getTextStyle("smallBold",
                                  color: getInvoiceStatusColor(invoice.status)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "QR ${invoice.invoiceBalance.toStringAsFixed(2)}",
                              style: getTextStyle("largeBold",
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              invoice.customerName,
                              style: getTextStyle("smallBold",
                                  color: Colors.white),
                            ),
                            if (invoice.status == "Paid")
                              Text(
                                "Paid on ${invoice.dueDate}",
                                style: getTextStyle("smallLight",
                                    color: Colors.grey),
                              )
                            else
                              Text(
                                "Due on ${invoice.dueDate}",
                                style: getTextStyle("smallLight",
                                    color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (onView != null)
                        IconButton(
                          onPressed: () => onView?.call(invoice),
                          icon: iconContainer(Icons.remove_red_eye_rounded),
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: () => onDelete?.call(invoice),
                          icon: iconContainer(Icons.delete),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
