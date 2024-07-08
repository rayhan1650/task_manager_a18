import 'package:flutter/material.dart';
import '../../data/models/network_response.dart';
import '../../data/models/task_model.dart';
import '../../data/models/tasklist_wrapper_model.dart';
import '../../data/network_caller/network_caller.dart';
import '../../data/utilities/api_urls.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/snack_bar_message.dart';
import '../widgets/task_item_card.dart';

class CancelledTaskScreen extends StatefulWidget {
  const CancelledTaskScreen({super.key});

  @override
  State<CancelledTaskScreen> createState() => _CancelledTaskScreenState();
}

class _CancelledTaskScreenState extends State<CancelledTaskScreen> {
  List<TaskModel> cancelledTaskList = [];
  bool _getCancelledTaskInProgress = false;
  @override
  void initState() {
    super.initState();
    _getCancelledTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: RefreshIndicator(
    onRefresh: _getCancelledTask,
    child: Visibility(
    visible: _getCancelledTaskInProgress == false,
    replacement: const CustomProgressIndicator(),
          child: cancelledTaskList.isEmpty
              ? Center(
              child: Text('No Cancelled Task Available',
                  style: Theme.of(context).textTheme.titleMedium))
              :  ListView.builder(
            itemCount: cancelledTaskList.length,
            itemBuilder: (context, index) {
              return TaskItemCard(taskModel: cancelledTaskList[index],
                onUpdateTask: () {
                  _getCancelledTask();
                },);
            },
          ),
        ),
      ),),
    );
  }
  Future<void> _getCancelledTask() async {
    _getCancelledTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
    await NetworkCaller.getRequest(ApiUrls.canceledTask);
    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
      TaskListWrapperModel.fromJson(response.responseData);
      cancelledTaskList = taskListWrapperModel.taskList ?? [];
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Get new task failed! Try again');
      }
    }
    _getCancelledTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }
}
