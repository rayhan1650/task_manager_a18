import 'package:flutter/material.dart';
import 'package:task_manager_app/data/models/network_response.dart';
import 'package:task_manager_app/data/models/task_count_by_status_model.dart';
import 'package:task_manager_app/data/models/tasklist_wrapper_model.dart';
import 'package:task_manager_app/data/network_caller/network_caller.dart';
import 'package:task_manager_app/data/utilities/api_urls.dart';
import 'package:task_manager_app/ui/screens/add_new_task_screen.dart';
import 'package:task_manager_app/ui/utility/colors.dart';
import 'package:task_manager_app/ui/widgets/custom_progress_indicator.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import 'package:task_manager_app/ui/widgets/title_large_text_widget.dart';
import '../../data/models/task_count_by_status_wrapper_model.dart';
import '../../data/models/task_model.dart';
import '../widgets/task_item_card.dart';
import '../widgets/task_summary_card.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  bool _getNewTaskInProgress = false;
  bool _getTaskCountByStatusInProgress = false;
  List<TaskModel> newTaskList = [];
  List<TaskCountByStatusModel> taskCountByStatusList = [];

  @override
  void initState() {
    super.initState();
    _refreshScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshScreen,
        child: Visibility(
          visible: _getNewTaskInProgress == false,
          replacement: const CustomProgressIndicator(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildSummarySection(),
                const SizedBox(height: 8),
                Expanded(
                  child: newTaskList.isEmpty
                      ? Center(
                          child: Text('No New Task Available',
                              style: Theme.of(context).textTheme.titleMedium))
                      : ListView.builder(
                          itemCount: newTaskList.length,
                          itemBuilder: (context, index) {
                            return TaskItemCard(
                              taskModel: newTaskList[index],
                              onUpdateTask: () {
                                _refreshScreen();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddNewButton,
        tooltip: 'Add New Task',
        backgroundColor: AppColors.themeColor,
        foregroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildSummarySection() {
    return Visibility(
      visible: _getTaskCountByStatusInProgress == false,
      replacement:
          const SizedBox(height: 100, child: CustomProgressIndicator()),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: taskCountByStatusList.map((e) {
            return TaskSummaryCard(
              title: (e.sId ?? 'Unknown').toUpperCase(),
              count: e.sum.toString(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _getNewTask() async {
    _getNewTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response = await NetworkCaller.getRequest(ApiUrls.newTask);
    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
          TaskListWrapperModel.fromJson(response.responseData);
      newTaskList = taskListWrapperModel.taskList ?? [];
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Get new task failed! Try again');
      }
    }
    _getNewTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getTaskCountByStatus() async {
    _getNewTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
        await NetworkCaller.getRequest(ApiUrls.taskStatusCount);
    if (response.isSuccess) {
      TaskCountByStatusWrapperModel taskCountByStatusWrapperModel =
          TaskCountByStatusWrapperModel.fromJson(response.responseData);
      taskCountByStatusList =
          taskCountByStatusWrapperModel.taskCountByStatusList ?? [];
    } else {
      if (mounted) {
        showSnackBarMessage(
            context,
            response.errorMessage ??
                'Get task Count by status failed! Try again');
      }
    }
    _getNewTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onTapAddNewButton() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNewTaskScreen(
                  onTaskAdded: () {
                    _refreshScreen();
                  },
                )));
  }

  Future<void> _refreshScreen() async {
    await _getTaskCountByStatus();
    await _getNewTask();
  }
}
