import 'package:flutter/material.dart';
import 'package:task_manager_app/data/models/network_response.dart';
import 'package:task_manager_app/data/network_caller/network_caller.dart';
import 'package:task_manager_app/data/utilities/api_urls.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import '../utility/strings.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_progress_indicator.dart';
import '../widgets/custom_textformfield.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/title_large_text_widget.dart';

class AddNewTaskScreen extends StatefulWidget {
  const AddNewTaskScreen({super.key, required this.onTaskAdded});
  final VoidCallback onTaskAdded;

  @override
  State<AddNewTaskScreen> createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends State<AddNewTaskScreen> {
  final TextEditingController _subjectTEController = TextEditingController();
  final TextEditingController _descriptionTEController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _addNewTaskInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: profileAppBar(context),
      body: BackgroundWidget(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  const TitleLargeText(titleLarge: addNewTaskScreenTitle),
                  const SizedBox(height: 12),
                  CustomTextFormField(
                    controller: _subjectTEController,
                    hintText: 'Subject',
                    validatorErrorText: 'Please Enter Your Subject',
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: _descriptionTEController,
                    hintText: 'Description',
                    maxLines: 5,
                    validatorErrorText: 'Please Enter Your Description',
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _addNewTaskInProgress == false,
                    replacement: const CustomProgressIndicator(),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addNewTask();
                        }
                      },
                      child: const Icon(
                        Icons.arrow_circle_right_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addNewTask() async {
    _addNewTaskInProgress = true;
    if (mounted) {
      setState(() {});
    }
    Map<String, dynamic> requestTaskData = {
      "title": _subjectTEController.text.trim(),
      "description": _descriptionTEController.text.trim(),
      "status": "New",
    };

    NetworkResponse response = await NetworkCaller.postRequest(
        ApiUrls.createTask,
        body: requestTaskData);
    _addNewTaskInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
      _clearTextField();
      if (mounted) {
        showSnackBarMessage(context, 'New Task Added');
        Navigator.pop(context, true);
        widget.onTaskAdded();
      }
    } else {
      if (mounted) {
        showSnackBarMessage(context, 'Failed to add new task! Try again', true);
      }
    }
  }

  void _clearTextField() {
    _subjectTEController.clear();
    _descriptionTEController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _subjectTEController.dispose();
    _descriptionTEController.dispose();
  }
}