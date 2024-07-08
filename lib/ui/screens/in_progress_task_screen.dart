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

class InProgressTaskScreen extends StatefulWidget {
  const InProgressTaskScreen({super.key});

  @override
  State<InProgressTaskScreen> createState() => _InProgressTaskScreenState();
}

class _InProgressTaskScreenState extends State<InProgressTaskScreen> {
  List<TaskModel> inProgressTaskList = [];
  bool _inProgressTaskInProgress = true;
  @override
  void initState() {
    super.initState();
    _getInProgressTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: RefreshIndicator(
          onRefresh: _getInProgressTask,
          child: Visibility(
            visible: _inProgressTaskInProgress == false,
            replacement: const CustomProgressIndicator(),
            child: inProgressTaskList.isEmpty
                ? Center(
                    child: Text('No New Task Available',
                        style: Theme.of(context).textTheme.titleMedium))
                : ListView.builder(
                    itemCount: inProgressTaskList.length,
                    itemBuilder: (context, index) {
                      return TaskItemCard(
                        taskModel: inProgressTaskList[index],
                        onUpdateTask: () {
                          _getInProgressTask();
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _getInProgressTask() async {
    _inProgressTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
        await NetworkCaller.getRequest(ApiUrls.inProgressTask);
    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
          TaskListWrapperModel.fromJson(response.responseData);
      inProgressTaskList = taskListWrapperModel.taskList ?? [];
    } else {
      if (mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Get in progress task failed! Try again');
      }
    }
    _inProgressTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }
}
