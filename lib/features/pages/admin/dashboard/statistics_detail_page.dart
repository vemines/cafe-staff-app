import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/string_extensions.dart';
import '/core/widgets/space.dart';
import '/features/entities/aggregated_statistics_entity.dart';
import '/features/entities/statistics_entity.dart';

class StatisticsDetailPage extends StatefulWidget {
  const StatisticsDetailPage({super.key, this.stats});

  final Object? stats;

  @override
  State<StatisticsDetailPage> createState() => _StatisticsDetailPageState();
}

class _StatisticsDetailPageState extends State<StatisticsDetailPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.stats == null) {
      return const Scaffold(body: Center(child: Text("No data provided.")));
    }

    if (widget.stats is StatisticsEntity || widget.stats is AggregatedStatisticsEntity) {
      return Scaffold(
        appBar: AppBar(forceMaterialTransparency: true, title: const Text('Statistics Detail')),
        body: SafeArea(child: _content(widget.stats, context)),
      );
    }
    return const Scaffold(body: Center(child: Text("Invalid data provided.")));
  }

  Widget _content(dynamic stats, BuildContext context) {
    bool isDailyStatistic = stats is StatisticsEntity;

    String dateString() {
      if (isDailyStatistic) return stats.date.toFormatDate;
      return '${stats.month} - ${stats.year}';
    }

    // stats as StatisticsEntity;
    return ListView(
      children: [
        _infoTile(isDailyStatistic ? "Date" : "Month", dateString()),
        _infoTile("Total Orders", stats.totalOrders.toString()),
        _infoTile("Total Revenue", '\$${stats.totalRevenue.toStringAsFixed(0)}'),
        _infoTile("Total Feedbacks", stats.totalFeedbacks.toString()),
        _infoTile("Average Rating", stats.averageRating.toString()),
        const Divider(),
        _paymentMethodsTable(stats.paymentMethodSummary),
        const Divider(),
        if (stats is StatisticsEntity) ...[_ordersByHourTable(stats.ordersByHour), const Divider()],
        _bestSellingItemsTable(stats.soldItems),
      ],
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.titleMedium),
          Text(value, style: context.textTheme.bodyLarge),
        ],
      ),
    );
  }

  List<DataCell> _dataCell(BuildContext context, String text1, String text2) => [
    DataCell(Text(text1, style: context.bodyMediumBold)),
    DataCell(
      Align(alignment: Alignment.center, child: Text(text2, style: context.textTheme.bodyLarge)),
    ),
  ];

  List<DataColumn> _dataColumn(BuildContext context, String text1, String text2) => [
    DataColumn(label: SizedBox(width: 200, child: Text(text1, style: context.bodyLargeBold))),
    DataColumn(
      label: Expanded(
        child: Text(
          text2,
          style: context.bodyLargeBold,
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ];

  Widget _bestSellingItemsTable(Map<String, int> soldItems) {
    final sortedEntries = soldItems.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return _tableDetail(
      context,
      'Best Selling Items',
      DataTable(
        columns: _dataColumn(context, 'Items', 'Quantity Sold'),
        rows:
            sortedEntries
                .map((entry) => DataRow(cells: _dataCell(context, entry.key, "${entry.value}")))
                .toList(),
      ),
    );
  }

  Widget _ordersByHourTable(Map<int, int> ordersByHour) {
    return _tableDetail(
      context,
      'Orders by Hour',
      DataTable(
        columns: _dataColumn(context, 'Hour', 'Number of Orders'),
        rows:
            ordersByHour.entries
                .where((e) => e.value != 0)
                .map(
                  (entry) => DataRow(
                    cells: _dataCell(context, _hourToString(entry.key), "${entry.value}"),
                  ),
                )
                .toList(),
      ),
    );
  }

  String _hourToString(int hour) => "${hour.toString().padLeft(2, '0')}:00";

  Widget _paymentMethodsTable(Map<String, dynamic> paymentMethodSummary) {
    return _tableDetail(
      context,
      'Payment Methods Summary',
      DataTable(
        columns: _dataColumn(context, 'Payment Method', 'Count'),
        rows:
            paymentMethodSummary.entries
                .map(
                  (entry) => DataRow(
                    cells: _dataCell(context, entry.key.capitalize, "${entry.value.count}"),
                  ),
                )
                .toList(),
      ),
    );
  }
}

Widget _tableDetail(BuildContext context, String title, DataTable table) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [Padding(padding: eiAll2, child: Text(title, style: context.titleLargeBold)), table],
);
