import 'package:go_router/go_router.dart';
import 'package:yalapay/screens/cheque_screens/cheque_deposit_details_screen.dart';
import 'package:yalapay/screens/cheque_screens/cheque_deposit_update_screen.dart';
import 'package:yalapay/screens/cheque_screens/cheque_deposits_screen.dart';
import 'package:yalapay/screens/common_screens/register_screen.dart';
import 'package:yalapay/screens/payment_screens/add_payment_screen.dart';
import 'package:yalapay/screens/payment_screens/payment_details_screen.dart';
import 'package:yalapay/screens/payment_screens/payments_screen.dart';
import 'package:yalapay/screens/cheque_screens/cheque_screen.dart';
import 'package:yalapay/screens/customer_screens/add_customer_screen.dart';
import 'package:yalapay/screens/customer_screens/customer_details_screen.dart';
import 'package:yalapay/screens/customer_screens/customer_screen.dart';
import 'package:yalapay/screens/common_screens/dashboard.dart';
import 'package:yalapay/screens/invoice_screens/add_invoice_screen.dart';
import 'package:yalapay/screens/invoice_screens/invoice_details_screen.dart';
import 'package:yalapay/screens/invoice_screens/invoice_screen.dart';
import 'package:yalapay/screens/common_screens/login_screen.dart';
import 'package:yalapay/screens/common_screens/report_screen.dart';
import 'package:yalapay/screens/common_screens/shell_screen.dart';

class AppRouter {
  static const login = (name: 'login', path: '/');
  static const register = (name: 'register', path: '/register');
  static const dashboard = (name: 'dashboard', path: '/dashboard');
  static const customer = (name: "customer", path: "/customer");
  static const report = (name: "report", path: "/report");
  static const invoice = (name: "invoice", path: "/invoice");
  static const cheque = (name: "cheque", path: "/cheque");
  static const addCustomer =
      (name: 'addCustomer', path: '/customer/addCustomer');
  static const customerDetails =
      (name: "customerDetails", path: "/customer/customerDetails:customerId");
  static const addInvoice = (name: 'addInvoice', path: '/invoice/addInvoice');
  static const invoiceDetails =
      (name: 'invoiceDetails', path: '/invoice/invoiceDetails');
  static const payments =
      (name: 'payments', path: '/invoice/invoiceDetails/payments');
  static const addPayment =
      (name: 'addPayment', path: '/invoice/invoiceDetails/addPayment');
  static const chequeDetails = (
    name: 'chequeDetails',
    path: '/invoice/invoiceDetails/payments/chequeDetails:paymentId'
  );
  static const chequeDeposits =
      (name: 'chequeDeposits', path: '/cheque/chequeDeposits');
  static const chequeDepositDetails = (
    name: 'chequeDepositDetails',
    path: '/cheque/chequeDeposits/chequeDepositDetails:chequeDepositId'
  );
  static const chequeDepositUpdate = (
    name: 'chequeDepositUpdate',
    path: '/cheque/chequeDeposits/chequeDepositUpdate:chequeDepositId'
  );

  static final router = GoRouter(
    initialLocation: login.path,
    routes: [
      GoRoute(
          path: login.path,
          name: login.name,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register.path,
        name: register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: dashboard.path,
            name: dashboard.name,
            builder: (context, state) => const Dashboard(),
          ),
          GoRoute(
            path: customer.path,
            name: customer.name,
            builder: (context, state) => const CustomerScreen(),
            routes: [
              GoRoute(
                path: customerDetails.path,
                name: customerDetails.name,
                builder: (context, state) {
                  final customerId = state.pathParameters["customerId"];
                  return CustomerDetailsScreen(customerId: customerId!);
                },
              ),
              GoRoute(
                path: addCustomer.path,
                name: addCustomer.name,
                builder: (context, state) => const AddCustomerScreen(),
              ),
            ],
          ),
          GoRoute(
              path: invoice.path,
              name: invoice.name,
              builder: (context, state) => const InvoiceScreen(),
              routes: [
                GoRoute(
                  path: invoiceDetails.path,
                  name: invoiceDetails.name,
                  builder: (context, state) => const InvoiceDetailScreen(),
                  routes: [
                    GoRoute(
                        path: payments.path,
                        name: payments.name,
                        builder: (context, state) => const PaymentsScreen(),
                        routes: [
                          GoRoute(
                            path: chequeDetails.path,
                            name: chequeDetails.name,
                            builder: (context, state) {
                              final paymentId =
                                  state.pathParameters['paymentId'];
                              return PaymentDetailsScreen(
                                paymentId: paymentId!,
                              );
                            },
                          )
                        ]),
                    GoRoute(
                      path: addPayment.path,
                      name: addPayment.name,
                      builder: (context, state) => const AddPaymentScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: addInvoice.path,
                  name: addInvoice.name,
                  builder: (context, state) => const AddInvoiceScreen(),
                )
              ]),
          GoRoute(
            path: cheque.path,
            name: cheque.name,
            builder: (context, state) => const ChequeScreen(),
            routes: [
              GoRoute(
                path: chequeDeposits.path,
                name: chequeDeposits.name,
                builder: (context, state) => const ChequeDepositsScreen(),
                routes: [
                  GoRoute(
                    path: chequeDepositDetails.path,
                    name: chequeDepositDetails.name,
                    builder: (context, state) {
                      final chequeDepositId =
                          state.pathParameters['chequeDepositId'];
                      return ChequeDepositDetailsScreen(
                          chequeDepositId: chequeDepositId!);
                    },
                  ),
                  GoRoute(
                    path: chequeDepositUpdate.path,
                    name: chequeDepositUpdate.name,
                    builder: (context, state) {
                      final chequeDepositId =
                          state.pathParameters['chequeDepositId'];
                      return ChequeDepositUpdateScreen(
                          chequeDepositId: chequeDepositId!);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: report.path,
            name: report.name,
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
  );
}
