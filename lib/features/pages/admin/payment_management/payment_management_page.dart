import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/widgets/dialog.dart';
import '/features/blocs/payment/payment_cubit.dart';
import '/features/entities/payment_entity.dart';
import '/features/pages/admin/widgets/action_icon.dart';
import '/features/pages/admin/widgets/active_checkbox.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/features/pages/admin/widgets/header_row_with_create_button.dart';
import '/injection_container.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  State<PaymentManagementPage> createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = sl<PaymentCubit>()..getAllPayments();
  }

  @override
  void dispose() {
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(_scaffoldKey, "Payment Management"),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: BlocProvider.value(
          value: _paymentCubit,
          child: Column(
            children: [
              headerRowWithCreateButton(
                title: "Payment",
                onPressed: () => _showCreateOrEditPaymentDialog(context, null),
                buttonText: "Create Payment",
              ),
              Expanded(
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PaymentError) {
                      return Center(child: Text("Error: ${state.failure.message}"));
                    } else if (state is PaymentLoaded) {
                      final payments = state.payments;
                      return ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          return _paymentListTile(payment, context);
                        },
                      );
                    }
                    return const Center(child: Text('No payments found'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _paymentListTile(PaymentEntity payment, BuildContext context) {
    return ListTile(
      title: Text(payment.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit Payment",
            onPressed: () => _showCreateOrEditPaymentDialog(context, payment),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Payment",
            onPressed: () => _showDeletePaymentDialog(context, payment),
          ),
          activeCheckbox(
            isActive: payment.isActive,
            textColor: payment.isActive ? Colors.green : Colors.grey,
            onChanged: (value) => _updatePaymentStatus(payment, value),
          ),
        ],
      ),
    );
  }

  void _showCreateOrEditPaymentDialog(BuildContext context, PaymentEntity? payment) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: payment?.name);
    bool isCreate = payment == null;
    final title = isCreate ? 'Create Payment' : 'Edit Payment';

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
            ],
          ),
        ),
      ),
      onAction: () {
        if (formKey.currentState?.validate() ?? false) {
          if (isCreate) {
            _paymentCubit.createPayment(name: name.text);
          } else {
            _paymentCubit.updatePayment(
              id: payment.id,
              name: name.text,
              isActive: payment.isActive,
            );
          }
          Navigator.pop(context);
        }
      },
    );
  }

  void _showDeletePaymentDialog(BuildContext context, PaymentEntity payment) {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete Payment',
      actionText: "Delete Payment",
      content: Text('Are you sure you want to delete this payment (${payment.name})?'),
      onAction: () {
        _paymentCubit.deletePayment(id: payment.id).then((value) => _paymentCubit.getAllPayments());
        Navigator.pop(context);
      },
    );
  }

  void _updatePaymentStatus(PaymentEntity payment, bool isActive) {
    _paymentCubit.updatePayment(id: payment.id, name: payment.name, isActive: isActive);
  }
}
