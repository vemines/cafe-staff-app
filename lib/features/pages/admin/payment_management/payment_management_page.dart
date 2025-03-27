import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/locale.dart';
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
      appBar: adminAppBar(_scaffoldKey, context.tr(I18nKeys.paymentManagement)),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: BlocProvider.value(
          value: _paymentCubit,
          child: Column(
            children: [
              headerRowWithCreateButton(
                title: context.tr(I18nKeys.paymentMethod),
                onPressed: () => _showCreateOrEditPaymentDialog(context, null),
                buttonText: context.tr(I18nKeys.createPayment),
              ),
              Expanded(
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PaymentError) {
                      return Center(
                        child: Text(
                          context.tr(I18nKeys.errorWithMessage, {
                            'message': state.failure.message ?? 'Unknown error',
                          }),
                        ),
                      );
                    } else if (state is PaymentLoaded) {
                      final payments = state.payments;
                      return payments.isEmpty
                          ? Center(child: Text(context.tr(I18nKeys.noPaymentsFound)))
                          : ListView.builder(
                            itemCount: payments.length,
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              return _paymentListTile(context, payment);
                            },
                          );
                    }
                    return Center(child: Text(context.tr(I18nKeys.noPaymentsFound)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _paymentListTile(BuildContext context, PaymentEntity payment) {
    return ListTile(
      title: Text(payment.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editPayment),
            onPressed: () => _showCreateOrEditPaymentDialog(context, payment),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deletePayment),
            onPressed: () => _showDeletePaymentDialog(context, payment),
          ),
          activeCheckbox(
            isActive: payment.isActive,
            textColor: payment.isActive ? Colors.green : Colors.grey,
            onChanged: (value) => _updatePaymentStatus(context, payment, value),
          ),
        ],
      ),
    );
  }

  void _showCreateOrEditPaymentDialog(BuildContext context, PaymentEntity? payment) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: payment?.name);
    bool isCreate = payment == null;
    final title = isCreate ? context.tr(I18nKeys.createPayment) : context.tr(I18nKeys.editPayment);

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
                decoration: InputDecoration(labelText: context.tr(I18nKeys.name)),
                validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
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
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deletePayment),
      content: Text(
        context.tr(I18nKeys.confirmDeletePaymentMessage, {'paymentName': payment.name}),
      ),
      onAction: () {
        _paymentCubit.deletePayment(id: payment.id).then((value) => _paymentCubit.getAllPayments());
        Navigator.pop(context);
      },
    );
  }

  void _updatePaymentStatus(BuildContext context, PaymentEntity payment, bool isActive) {
    _paymentCubit.updatePayment(id: payment.id, name: payment.name, isActive: isActive);
  }
}
