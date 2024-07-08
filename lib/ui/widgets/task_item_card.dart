import 'package:flutter/material.dart';
import 'package:task_manager_app/data/models/task_model.dart';
import 'package:task_manager_app/data/models/task_status_list_model.dart';
import 'package:task_manager_app/ui/widgets/custom_progress_indicator.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import '../../data/models/network_response.dart';
import '../../data/network_caller/network_caller.dart';
import '../../data/utilities/api_urls.dart';
import '../utility/colors.dart';

class TaskItemCard extends StatefulWidget {
  const TaskItemCard({
    super.key, required this.taskModel, required this.onUpdateTask,
  });

  final TaskModel taskModel;
  final VoidCallback onUpdateTask;

  @override
  State<TaskItemCard> createState() => _TaskItemCardState();
}

class _TaskItemCardState extends State<TaskItemCard> {
  bool _deleteInProgress = false;
  bool _editInProgress = false;
  TaskStatusListModel? dropdownValue;
  List<TaskStatusListModel> statusList = [
    TaskStatusListModel(status: 'New', color: Colors.blue),
    TaskStatusListModel(status: 'Completed', color: AppColors.themeColor),
    TaskStatusListModel(status: 'Canceled', color: AppColors.redColor),
    TaskStatusListModel(status: 'InProgress', color: Colors.pink),
  ];


  @override
  void initState() {
    super.initState();
    dropdownValue = statusList.firstWhere((statusInfo) => statusInfo.status == widget.taskModel.status);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.whiteColor,
      child: ListTile(
        title: Text(widget.taskModel.title ?? '', style: const TextStyle(fontSize: 20),),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.taskModel.description ?? '', style: const TextStyle(fontSize: 16)),
            Text(
              'Date: ${widget.taskModel.createdDate}',
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                  ),
                  label: Text(dropdownValue?.status ?? '' , style: const TextStyle(color: AppColors.whiteColor),),
                  backgroundColor: dropdownValue?.color,
                ),
                ButtonBar(
                  children: [
                    Visibility(
                      visible: _editInProgress == false,
                      replacement: const CustomProgressIndicator(),
                      child: PopupMenuButton<TaskStatusListModel>(
                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.themeColor,),
                        onSelected: (TaskStatusListModel selectedValue) {
                          _updateTaskStatus(selectedValue);
                        },
                        itemBuilder: (BuildContext context) {
                          return statusList.map((TaskStatusListModel taskStatus) {
                            return PopupMenuItem<TaskStatusListModel>(
                              value: taskStatus,
                              child: ListTile(
                                title: Text(taskStatus.status),
                                trailing: dropdownValue?.status == taskStatus.status
                                    ? const Icon(Icons.done)
                                    : null,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteConfirmationDialog,
                      icon: const Icon(Icons.delete, color: AppColors.redColor),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _deleteConfirmationDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Visibility(
          visible: _deleteInProgress == false,
          replacement: const CustomProgressIndicator(),
          child: AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
              'Are you sure for Delete',
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Text('NO')),
              IconButton(
                  onPressed: () {
                    _deleteTask();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  icon: const Text('YES')),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    _deleteInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
    await NetworkCaller.getRequest(ApiUrls.deleteTask(widget.taskModel.sId!));

    if (response.isSuccess) {
      widget.onUpdateTask();
      if (mounted) {
        showSnackBarMessage(
          context,
          'Task Deleted Successfully',
        );
      }
    } else {
      if (mounted) {
        showSnackBarMessage(
          context,
          response.errorMessage ?? 'Failed to delete task! Try again',
        );
      }
    }
    _deleteInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateTaskStatus(TaskStatusListModel taskStatus) async {
    _editInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response = await NetworkCaller.getRequest(ApiUrls.updateTaskStatus(widget.taskModel.sId!, taskStatus.status));

    if (response.isSuccess) {
      dropdownValue = taskStatus;
      widget.taskModel.status = taskStatus.status; // Update the taskModel's status
      widget.onUpdateTask();
      if (mounted) {
        showSnackBarMessage(
          context,
          'Task status updated successfully',
        );
      }
    } else {
      if (mounted) {
        showSnackBarMessage(
          context,
          response.errorMessage ?? 'Failed to update task status! Try again',
        );
      }
    }
    _editInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }
}