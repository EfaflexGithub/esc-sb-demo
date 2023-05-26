import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_and_feedback_controller.dart';

class HelpAndFeedbackPage extends GetView<HelpAndFeedbackController> {
  const HelpAndFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help and Feedback'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: null,
      ),
    );
  }
}
