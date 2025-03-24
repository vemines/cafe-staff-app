import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/num_extensions.dart';

class DateRangeButtonWidget extends StatelessWidget {
  const DateRangeButtonWidget({
    super.key,
    required this.onPick,
    required this.startDaySelected,
    required this.endDaySelected,
  });

  final Function(DateTimeRange?) onPick;
  final DateTime? startDaySelected;
  final DateTime? endDaySelected;

  @override
  Widget build(BuildContext context) {
    return context.isMobile ? Expanded(child: _button(context)) : _button(context);
  }

  SizedBox _button(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 40,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: 8.borderRadius, side: BorderSide.none),
        ),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2300),
          );
          if (picked != null) onPick(picked);
        },
        child: Text(
          startDaySelected == null || endDaySelected == null
              ? 'Select Date Range'
              : '${startDaySelected!.toFormatDate} - ${endDaySelected!.toFormatDate}',
        ),
      ),
    );
  }
}
