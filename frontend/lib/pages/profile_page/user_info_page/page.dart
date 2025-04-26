import 'package:easy_scooter/components/page_title.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/services/user_service.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final UserProvider _userProvider = UserProvider();

  @override
  Widget build(BuildContext context) {
    final user = _userProvider.user;
    UserProvider().fetchUser();
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: 'User Info'),
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You need to log in first',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login page
                      // Navigator.of(context).pushNamed('/login');
                    },
                    child: Text('Log In'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // User Information List
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(
                            icon: Icons.badge,
                            title: 'User ID',
                            value: user.id.toString(),
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            icon: Icons.person,
                            title: 'Name',
                            value: user.name,
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            icon: Icons.email,
                            title: 'Email',
                            value: user.email,
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            icon: Icons.cake,
                            title: 'Age',
                            value: user.age?.toString() ?? "Not provided",
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            icon: Icons.school,
                            title: 'School',
                            value: user.school ?? "Not provided",
                          ),
                          _buildDivider(),
                          _buildInfoItem(
                            icon: Icons.person_outline,
                            title: 'Identity',
                            value: user.age != null && user.age! > 60
                                ? "Senior"
                                : (user.school != null ? "Student" : "normal"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: (user.age != null && user.school != null)
                        ? null // Button disabled if both age and school exist
                        : () => _showVerificationDialog(context, user),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Complete Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void _showVerificationDialog(BuildContext context, user) {
    // Create controllers only for the fields that need to be filled
    final TextEditingController ageController =
        TextEditingController(text: user.age?.toString() ?? '');
    final TextEditingController schoolController =
        TextEditingController(text: user.school ?? '');

    // Track which fields need verification
    final bool needsAge = user.age == null;
    final bool needsSchool = user.school == null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Identity Verification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Please provide the following information to complete verification:'),
              const SizedBox(height: 16),
              if (needsAge)
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter your age',
                  ),
                  keyboardType: TextInputType.number,
                ),
              if (needsAge && needsSchool) const SizedBox(height: 16),
              if (needsSchool)
                TextField(
                  controller: schoolController,
                  decoration: const InputDecoration(
                    labelText: 'School',
                    hintText: 'Enter your school name',
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Validate age input if needed
              int? age = user.age;
              if (needsAge && ageController.text.isNotEmpty) {
                try {
                  age = int.parse(ageController.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid age')),
                  );
                  return;
                }
              }

              // Get school input if needed
              String? school = user.school;
              if (needsSchool && schoolController.text.isNotEmpty) {
                school = schoolController.text;
              }

              // Validate that all required fields are filled
              if ((needsAge && age == null) ||
                  (needsSchool && (school == null || school.isEmpty))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all required fields')),
                );
                return;
              }

              await UserService().updateUser(
                id: user.id,
                age: age,
                school: school,
              );
              UserProvider().fetchUser();
              // For now, just close the dialog and show a message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Verification information submitted')),
              );

              // Force UI to update
              setState(() {});
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5);
  }
}
