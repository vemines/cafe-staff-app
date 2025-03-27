import 'package:flutter/material.dart';

import '/app/locale.dart';
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
      return Scaffold(body: Center(child: Text(context.tr(I18nKeys.noDataProvided))));
    }

    if (widget.stats is StatisticsEntity || widget.stats is AggregatedStatisticsEntity) {
      return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(context.tr(I18nKeys.statisticsDetail)),
        ),
        body: SafeArea(child: _content(context, widget.stats)),
      );
    }
    return Scaffold(body: Center(child: Text(context.tr(I18nKeys.invalidDataProvided))));
  }

  Widget _content(BuildContext context, dynamic stats) {
    bool isDailyStatistic = stats is StatisticsEntity;

    String dateString() {
      if (isDailyStatistic) return stats.date.toFormatDate;
      return '${stats.month} - ${stats.year}';
    }

    return ListView(
      children: [
        _infoTile(
          context,
          isDailyStatistic ? context.tr(I18nKeys.date) : context.tr(I18nKeys.month),
          dateString(),
        ),
        _infoTile(context, context.tr(I18nKeys.totalOrders), stats.totalOrders.toString()),
        _infoTile(
          context,
          context.tr(I18nKeys.totalRevenue),
          '\$${stats.totalRevenue.toStringAsFixed(0)}',
        ),
        _infoTile(context, context.tr(I18nKeys.totalComments), stats.totalFeedbacks.toString()),
        _infoTile(context, context.tr(I18nKeys.averageRating), stats.averageRating.toString()),
        const Divider(),
        _paymentMethodsTable(context, stats.paymentMethodSummary),
        const Divider(),
        if (stats is StatisticsEntity) ...[
          _ordersByHourTable(context, stats.ordersByHour),
          const Divider(),
        ],
        _bestSellingItemsTable(context, stats.soldItems),
      ],
    );
  }

  Widget _infoTile(BuildContext context, String title, String value) {
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

  Widget _bestSellingItemsTable(BuildContext context, Map<String, int> soldItems) {
    final sortedEntries = soldItems.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return _tableDetail(
      context,
      context.tr(I18nKeys.bestSellingItems),
      DataTable(
        columns: _dataColumn(
          context,
          context.tr(I18nKeys.items),
          context.tr(I18nKeys.quantitySold),
        ),
        rows:
            sortedEntries
                .map((entry) => DataRow(cells: _dataCell(context, entry.key, "${entry.value}")))
                .toList(),
      ),
    );
  }

  Widget _ordersByHourTable(BuildContext context, Map<int, int> ordersByHour) {
    return _tableDetail(
      context,
      context.tr(I18nKeys.ordersByHour),
      DataTable(
        columns: _dataColumn(
          context,
          context.tr(I18nKeys.hour),
          context.tr(I18nKeys.numberOfOrders),
        ),
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

  Widget _paymentMethodsTable(BuildContext context, Map<String, dynamic> paymentMethodSummary) {
    return _tableDetail(
      context,
      context.tr(I18nKeys.paymentMethodsSummary),
      DataTable(
        columns: _dataColumn(
          context,
          context.tr(I18nKeys.paymentMethod),
          context.tr(I18nKeys.quantitySold),
        ),
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
