import '../../../blocs/feedback/feedback_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/extensions/build_content_extensions.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/widgets/space.dart';
import '/core/widgets/dialog.dart';
import '/injection_container.dart';
import '../../../entities/feedback_entity.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/date_range_button.dart';
import '../widgets/select_button.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedRating;
  late final FeedbackCubit _feedbackCubit;

  @override
  void initState() {
    super.initState();
    _feedbackCubit = sl<FeedbackCubit>();
    _feedbackCubit.getAllFeedback();
  }

  @override
  void dispose() {
    _feedbackCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(_scaffoldKey, 'Feedback'),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _filterRow(context),
            Expanded(
              child: BlocBuilder<FeedbackCubit, FeedbackState>(
                bloc: _feedbackCubit,
                builder: (context, state) {
                  if (state is FeedbackLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FeedbackError) {
                    return Center(child: Text('Error: ${state.failure.message}'));
                  } else if (state is FeedbackLoaded || state is FeedbackLoadingMore) {
                    final feedbacks = state.feedbacks;
                    final hasMore = state.hasMore;
                    return _feedbackList(feedbacks: feedbacks, hasMore: hasMore);
                  }
                  return const Center(child: Text("No feedback available."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackList({required List<FeedbackEntity> feedbacks, required bool hasMore}) {
    return ListView.builder(
      itemCount: feedbacks.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < feedbacks.length) {
          final feedback = feedbacks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Padding(
              padding: eiAll2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          sbW1,
                          Text("${feedback.rating}", style: context.bodyMediumBold),
                        ],
                      ),
                      Text(
                        feedback.timestamp.toFormatTime,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  sbH1,
                  Text(feedback.comment, style: context.bodyLargeBold),
                ],
              ),
            ),
          );
        } else {
          //Load more
          if (!hasMore) return const SizedBox.shrink();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _feedbackCubit.getAllFeedback(
              isLoadMore: true,
              rating: _selectedRating,
              startDate: _startDate,
              endDate: _endDate,
            );
          });

          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _filterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: context.isMobile ? 8 : 24,
        runSpacing: 8,
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateRangeButtonWidget(
                endDaySelected: _endDate,
                startDaySelected: _startDate,
                onPick: (picked) {
                  if (picked != null) {
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                      _feedbackCubit.getAllFeedback(startDate: _startDate, endDate: _endDate);
                    });
                  }
                },
              ),
              sbW2,
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _feedbackCubit.getAllFeedback(startDate: _startDate, endDate: _endDate);
                  });
                },
              ),
            ],
          ),
          selectButton(
            onPressed: () => _showRatingFilterDialog(context),
            text: _selectedRating == null ? "Select rating" : '$_selectedRating Stars',
            minWidth: 220,
          ),
        ],
      ),
    );
  }

  void _showRatingFilterDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      title: 'Select Rating',
      showAction: false,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(6, (index) {
            final rating = index == 0 ? null : index;
            final displayString = index == 0 ? "All Ratings" : "$index Stars";

            return ListTile(
              title: Text(displayString),
              onTap: () {
                setState(() {
                  _selectedRating = rating;
                  _feedbackCubit.getAllFeedback(
                    rating: _selectedRating,
                    startDate: _startDate,
                    endDate: _endDate,
                  );
                });
                Navigator.of(context).pop();
              },
              trailing: _selectedRating == rating ? const Icon(Icons.check) : null,
            );
          }),
        ),
      ),
    );
  }
}
