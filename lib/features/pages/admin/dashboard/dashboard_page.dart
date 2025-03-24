// Path: lib/features/page/admin/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../widgets/dialog_info_row.dart';
import '/app/paths.dart';
import '/core/extensions/string_extensions.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/utils/parse_utils.dart';
import '/core/widgets/space.dart';
import '/features/blocs/statistics/statistics_cubit.dart';
import '/features/entities/aggregated_statistics_entity.dart';
import '/features/entities/statistics_entity.dart';
import '/injection_container.dart';
import '../widgets/admin_appbar.dart';
import '../widgets/admin_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late StatisticsCubit _todayCubit;
  late StatisticsCubit _weeklyCubit;
  late StatisticsCubit _monthlyCubit;

  int filledMonth = 0;
  int filledWeek = 0;

  @override
  void initState() {
    _todayCubit = sl<StatisticsCubit>()..getTodayStatistics();
    _weeklyCubit = sl<StatisticsCubit>()..getThisWeekStatistics();
    _monthlyCubit = sl<StatisticsCubit>()..getAllAggregatedStatistics();
    super.initState();
  }

  @override
  void dispose() {
    _todayCubit.close();
    _weeklyCubit.close();
    _monthlyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filledMonth = 0;
    filledWeek = 0;
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(_scaffoldKey, "Dashboard"),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<StatisticsCubit>(create: (context) => _todayCubit),
              BlocProvider<StatisticsCubit>(create: (context) => _weeklyCubit),
              BlocProvider<StatisticsCubit>(create: (context) => _monthlyCubit),
            ],
            child: Column(
              children: [
                _buildTodaySection(),
                sbH4,
                _buildWeeklyChart(),
                sbH4,
                _buildMonthlyChart(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      bloc: _todayCubit,
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StatisticsError && state.failure.message != 'Not Found') {
          return Center(child: Text("Error: ${state.failure.message}"));
        } else if (state is DailyStatisticsLoaded) {
          final todayStats = state.statistic;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_metricCards(todayStats), sbH4, _bestSellings(todayStats)],
          );
        }
        return const Center(child: Text("No data available for today."));
      },
    );
  }

  Widget _buildWeeklyChart() {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      bloc: _weeklyCubit,
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const SizedBox.shrink();
        } else if (state is StatisticsError) {
          return Center(child: Text("Weekly Error: ${state.failure.message}"));
        } else if (state is WeeklyStatisticsLoaded) {
          return _weeklyChart(state.statistics);
        }
        return const Center(child: Text("No weekly data available."));
      },
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    return BlocBuilder<StatisticsCubit, StatisticsState>(
      bloc: _monthlyCubit,
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const SizedBox.shrink();
        } else if (state is StatisticsError) {
          return Center(child: Text("Monthly Error: ${state.failure.message}"));
        } else if (state is AggregatedStatisticsLoaded) {
          return _monthlyChart(context, state.statistics);
        }
        return const Center(child: Text("No monthly data available."));
      },
    );
  }

  Widget _metricCards(StatisticsEntity todayStats) {
    final totalRevenue = todayStats.totalRevenue;
    final totalOrders = todayStats.totalOrders;
    final totalFeedbacks = todayStats.totalFeedbacks;
    int selledItems = 0;
    if (todayStats.soldItems.isNotEmpty) {
      selledItems = todayStats.soldItems.values.reduce((sum, value) => sum + value);
    }

    return GridView.count(
      crossAxisCount: context.isMobile ? 2 : 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard(context, 'Revenue', '\$${totalRevenue.shortMoneyString}', Icons.paid),
        _metricCard(
          context,
          'Orders',
          '$totalOrders',
          Icons.assignment,
          onTap: () => context.push(Paths.orderHistory),
        ),
        _metricCard(context, 'Selled', '$selledItems', Icons.sell),
        _metricCard(context, 'Feedback', '$totalFeedbacks', Icons.reviews),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: 6.borderRadius,
        onTap: onTap,
        child: Padding(
          padding: eiAll3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 32),
                  sbW2,
                  Flexible(child: Text(title, style: context.titleMediumBold)),
                ],
              ),
              Text(value, style: context.titleLargeBold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bestSellings(StatisticsEntity todayStats) {
    final bestSells = Map.fromEntries(
      todayStats.soldItems.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    final top5BestSells = bestSells.entries.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: eiAll2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(child: Text('Today Best Selling Items', style: context.titleMediumBold)),
              ],
            ),
            if (top5BestSells.isEmpty)
              Padding(padding: eiAll2, child: const Text("Selling data is empty"))
            else
              ...top5BestSells.map(
                (entry) => ListTile(
                  leading: Text(
                    '-${top5BestSells.indexOf(entry) + 1}-',
                    style: context.bodyLargeBold,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: context.bodyLargeBold.copyWith(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      sbW2,
                      Text('${entry.value}', style: context.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _weeklyChart(List<StatisticsEntity> weeklyStats) {
    return _chartCard(
      'Weekly Revenue',
      SfCartesianChart(
        primaryXAxis: DateTimeAxis(interval: 1, dateFormat: DateFormat.d()),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0),
        ),
        series: <ColumnSeries<_DateChartData, DateTime>>[
          ColumnSeries<_DateChartData, DateTime>(
            onPointTap: (pointInteractionDetails) {
              if (pointInteractionDetails.pointIndex != null) {
                _showChartDialog(
                  context,
                  weeklyStats[pointInteractionDetails.pointIndex! - filledWeek],
                );
              }
            },
            dataSource: _getWeeklyRevenueChartData(weeklyStats),
            xValueMapper: (_DateChartData data, _) => data.x,
            yValueMapper: (_DateChartData data, _) => data.y,
            dataLabelSettings: _dataLabelSettings(),
            borderRadius: BorderRadius.only(topLeft: 6.radius, topRight: 6.radius),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _monthlyChart(BuildContext context, List<AggregatedStatisticsEntity> monthlyStats) {
    return _chartCard(
      'Monthly Revenue',
      SfCartesianChart(
        key: UniqueKey(),
        zoomPanBehavior: ZoomPanBehavior(enablePanning: true),
        primaryXAxis: CategoryAxis(
          autoScrollingDelta: 6,
          interval: 1,
          autoScrollingMode: AutoScrollingMode.end,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0),
        ),
        series: <ColumnSeries<_StringChartData, String>>[
          ColumnSeries<_StringChartData, String>(
            onPointTap: (pointInteractionDetails) {
              if (pointInteractionDetails.pointIndex != null) {
                final selectMonth = monthlyStats[pointInteractionDetails.pointIndex! - filledMonth];
                _showChartDialog(context, selectMonth);
              }
            },
            dataSource: _getMonthlyRevenueChartData(monthlyStats),
            xValueMapper: (_StringChartData data, int index) => data.x,
            yValueMapper: (_StringChartData data, int index) => data.y,
            borderRadius: BorderRadius.only(topLeft: 6.radius, topRight: 6.radius),
            dataLabelSettings: _dataLabelSettings(),
          ),
        ],
      ),
    );
  }

  DataLabelSettings _dataLabelSettings() {
    return DataLabelSettings(
      isVisible: true,
      textStyle: TextStyle(fontSize: 10),
      labelPosition: ChartDataLabelPosition.outside,
      alignment: ChartAlignment.near,
      offset: Offset(0, 20),
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        return data.y != 0 ? Text(dataFormat(data)) : SizedBox.shrink();
      },
    );
  }

  String dataFormat(dynamic data) {
    final double value = doubleParse(data.y);
    return context.isMobile ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  Widget _chartCard(String title, Widget chart) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.titleMediumBold),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  void _showChartDialog(BuildContext context, dynamic stats) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(stats is StatisticsEntity ? 'Daily Statistic' : 'Monthly Statistic'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (stats is StatisticsEntity) ...[
                  infoRow(context, 'Date:', stats.date.toFormatDate),
                  infoRow(context, 'Total Orders:', stats.totalOrders),
                  infoRow(context, 'Total Revenue:', stats.totalRevenue.shortMoneyString),
                  infoRow(context, 'Total Comments:', stats.totalFeedbacks),
                  infoRow(context, 'Average Rating:', stats.averageRating),
                  sbH2,
                  Text(
                    'Payment Method:',
                    style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ...stats.paymentMethodSummary.entries.map(
                    (entry) => infoRow(
                      context,
                      '${entry.key.capitalize}:',
                      '${entry.value.count} - (\$${entry.value.totalAmount.shortMoneyString})',
                    ),
                  ),
                ],
                if (stats is AggregatedStatisticsEntity) ...[
                  Text('Date: ${stats.month} - ${stats.year}'),
                  infoRow(context, 'Date:', '${stats.month}-${stats.year}'),
                  infoRow(context, 'Total Orders:', stats.totalOrders),
                  infoRow(context, 'Total Revenue:', stats.totalRevenue.shortMoneyString),
                  infoRow(context, 'Total Comments:', stats.totalFeedbacks),
                  infoRow(context, 'Average Rating:', stats.averageRating),
                  ...stats.paymentMethodSummary.entries.map(
                    (entry) => infoRow(
                      context,
                      '${entry.key.capitalize}:',
                      '${entry.value.count} - (\$${entry.value.totalAmount.shortMoneyString})',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(Paths.statistics, extra: stats);
              },
              child: const Text('Detail'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }

  List<_DateChartData> _getWeeklyRevenueChartData(List<StatisticsEntity> weeklyStats) {
    final data = weeklyStats.map((stat) => _DateChartData(stat.date, stat.totalRevenue)).toList();
    while (data.length < 7) {
      final insertDay = dateParse(data[0].x).subtract(Duration(days: 1));
      data.insert(0, _DateChartData(insertDay, 0));
      filledWeek++;
    }
    return data;
  }

  List<_StringChartData> _getMonthlyRevenueChartData(
    List<AggregatedStatisticsEntity> monthlyStats,
  ) {
    monthlyStats.sort((a, b) {
      if (a.year != b.year) {
        return a.year.compareTo(b.year);
      } else {
        return a.month.compareTo(b.month);
      }
    });

    List<_StringChartData> chartData =
        monthlyStats
            .map((stat) => _StringChartData("${stat.month}-${stat.year}", stat.totalRevenue))
            .toList();

    if (chartData.length < 12) {
      String earliest = chartData.first.x;
      int earliestMonth = int.parse(earliest.split('-')[0]);
      int earliestYear = int.parse(earliest.split('-')[1]);

      while (chartData.length < 6) {
        earliestMonth -= 1;
        if (earliestMonth == 0) {
          earliestMonth = 12;
          earliestYear -= 1;
        }
        chartData.insert(0, _StringChartData("$earliestMonth-$earliestYear", 0));
        filledMonth++;
      }
    }

    return chartData;
  }
}

class _StringChartData {
  _StringChartData(this.x, this.y);

  final String x;
  final double y;
}

class _DateChartData {
  _DateChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
