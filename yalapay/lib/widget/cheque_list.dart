import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/model/cheque.dart';
import 'package:yalapay/widget/empty_screen.dart';
import 'package:yalapay/widget/icon_container.dart';
import 'package:yalapay/widget/special_text.dart';

class ChequeList extends StatelessWidget {
  final List<Cheque> cheques;
  final void Function(Cheque)? onDelete;
  final void Function(Cheque)? onView;

  const ChequeList({
    required this.cheques,
    this.onDelete,
    this.onView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return cheques.isEmpty
        ? const EmptyScreen()
        : ListView.builder(
            itemCount: cheques.length,
            itemBuilder: (context, index) {
              final cheque = cheques[index];

              return Card(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                specialText(cheque.status),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: InstaImageViewer(
                                      child: Image.asset(
                                        '$baseDirectory${cheques[index].chequeImageUri}',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: getChequeStatusColor(cheque.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Cheque No: ${cheque.chequeNo}",
                                  style: getTextStyle("smallBold",
                                      color:
                                          getChequeStatusColor(cheque.status)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "QR ${cheque.amount.toStringAsFixed(2)}",
                              style: getTextStyle("largeBold",
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              cheque.drawer,
                              style: getTextStyle("smallBold",
                                  color: Colors.white),
                            ),
                            Text(
                              cheque.bankName,
                              style: getTextStyle("smallLight",
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Received on ${cheque.receivedDate}",
                              style: getTextStyle("smallLight",
                                  color: Colors.grey),
                            ),
                            Text(
                              cheque.status == "Deposited"
                                  ? "Deposited on ${cheque.dueDate}"
                                  : "Due on ${cheque.dueDate}",
                              style: getTextStyle("smallLight",
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (onView != null)
                        IconButton(
                          onPressed: () => onView?.call(cheque),
                          icon: iconContainer(Icons.remove_red_eye_rounded),
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: () => onDelete?.call(cheque),
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
