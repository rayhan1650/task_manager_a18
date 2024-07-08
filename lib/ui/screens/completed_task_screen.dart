import 'package:flutter/material.dart';

import '../../data/models/network_response.dart';
import '../../data/models/task_model.dart';
import '../../data/models/tasklist_wrapper_model.dart';
import '../../data/network_caller/network_caller.dart';
import '../../data/utilities/api_urls.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/snack_bar_message.dart';
import '../widgets/task_item_card.dart';
import '../widgets/title_large_text_widget.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({super.key});

  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  List<TaskModel> completeTaskList = [];
  bool _getCompletedTaskInProgress = false;

  @override
  void initState() {
    super.initState();
    _getCompletedTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: RefreshIndicator(
          onRefresh: _getCompletedTask,
          child: Visibility(
            visible: _getCompletedTaskInProgress == false,
            replacement: const CustomProgressIndicator(),
            child: completeTaskList.isEmpty
                ? Center(
                    child: Text('No Completed Task Available',
                        style: Theme.of(context).textTheme.titleMedium),
                  )
                : ListView.builder(
                    itemCount: completeTaskList.length,
                    itemBuilder: (context, index) {
                      return TaskItemCard(
                        taskModel: completeTaskList[index],
                        onUpdateTask: () {
                          _getCompletedTask();
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCompletedTask() async {
    _getCompletedTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
        await NetworkCaller.getRequest(ApiUrls.completedTask);
    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
          TaskListWrapperModel.fromJson(response.responseData);
      completeTaskList = taskListWrapperModel.taskList ?? [];
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Get new task failed! Try again');
      }
    }
    _getCompletedTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }
}
