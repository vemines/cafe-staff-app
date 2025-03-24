import 'dart:async';

import 'package:flutter/material.dart';

import '/core/constants/enum.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';
import '../../../entities/table_entity.dart';

final _infoStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);
final _timerStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black);
final _borderColor = Colors.grey;

Color? tableColor(TableStatus status) {
  switch (status) {
    case TableStatus.pending:
      return Colors.yellow[100];
    case TableStatus.served:
      return Colors.green[100];
    case TableStatus.completed:
      return Colors.blue[100];
  }
}

class TableWidget extends StatefulWidget {
  final TableEntity table;

  const TableWidget({super.key, required this.table});

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  String mergeTable = '';

  @override
  void initState() {
    final mergeTableNumber = widget.table.mergedTable;
    if (mergeTableNumber > 1) mergeTable = ' ($mergeTableNumber)';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 110,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _chairWidget(),
          Container(
            width: 110,
            height: 110,
            padding: eiAll2,
            decoration: BoxDecoration(
              color: tableColor(widget.table.status),
              borderRadius: 10.borderRadius,
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.table.name, style: _infoStyle),
                if (widget.table.order != null) ...[
                  sbH1,
                  Text(
                    '${widget.table.order!.totalPrice.shortMoneyString} \$$mergeTable',
                    softWrap: true,
                    style: _infoStyle,
                  ),
                  sbH1,
                  TimerWidget(createdAt: widget.table.order!.createdAt!),
                ],
              ],
            ),
          ),
          _chairWidget(),
        ],
      ),
    );
  }

  Container _chairWidget() {
    return Container(
      width: 15,
      height: 80,
      decoration: BoxDecoration(
        color: tableColor(widget.table.status),
        border: Border.all(color: _borderColor),
        borderRadius: 15.borderRadius,
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final DateTime createdAt;

  const TimerWidget({super.key, required this.createdAt});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = DateTime.now().difference(widget.createdAt);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.createdAt != oldWidget.createdAt) {
      _duration = DateTime.now().difference(widget.createdAt);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _duration += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatDuration(_duration), style: _timerStyle);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }
}
