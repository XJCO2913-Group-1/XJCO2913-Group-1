import 'package:easy_scooter/components/page_title.dart';
import 'package:flutter/material.dart';
import '../../../services/feedback_service.dart';
import 'dart:io';
import 'dart:convert'; // Added for base64 encoding
import 'dart:math'; // Added for random number generation
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Added for image compression
import '../../../components/faq/faq_components.dart';
import '../../../components/image/image_picker_component.dart';
import '../../../components/form/section_title.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({Key? key}) : super(key: key);
  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedQuestionType;
  List<String> _questionTypes = [
    'Scooter Issue',
    'App Issue',
    'Rental Issue',
    'Payment Issue',
    'Other'
  ];

  File? _imageFile;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: "Feedback"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Frequently Asked Questions'),
                FAQCard(faqs: FAQData.getCommonFAQs()),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Problem Description'),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Question Type'),
                _buildQuestionTypeSelector(),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Problem Image'),
                ImagePickerComponent(
                  onImageSelected: (file) {
                    setState(() {
                      _imageFile = file;
                    });
                  },
                  initialImage: _imageFile,
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter something about your problem',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: const Text('Select question type'),
            value: _selectedQuestionType,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? newValue) {
              setState(() {
                _selectedQuestionType = newValue;
              });
            },
            items: _questionTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedQuestionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a question type')),
      );
      return false;
    }

    return true;
  }

  Future<XFile?> _compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path.replaceAll('.jpg', '_compressed.jpg'),
      quality: 50,
    );
    return compressedFile;
  }

  Future<void> _submitFeedback() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!mounted) return;

      // Convert image to base64 if available
      String base64Image = '';
      if (_imageFile != null) {
        final compressedImage = await _compressImage(_imageFile!);
        if (compressedImage != null) {
          List<int> imageBytes = await compressedImage.readAsBytes();
          base64Image = base64Encode(imageBytes);
        }
      }

      // Randomly select a priority from the three options
      final List<String> priorityOptions = ['low', 'medium', 'high'];
      final Random random = Random();
      final String randomPriority =
          priorityOptions[random.nextInt(priorityOptions.length)];

      await _feedbackService.sendFeedback(
        feedBackType: _selectedQuestionType!.toLowerCase().replaceAll(' ', '_'),
        feedBackDetail: _descriptionController.text,
        priority: randomPriority,
        image: base64Image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
