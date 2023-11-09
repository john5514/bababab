import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GENERAL INFO', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black, // Adjust to match your dark theme
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              // Implement cancel functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              controller.updateProfileData();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[850], // Dark theme background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[700],
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
            // Profile Info
            TextField(
              controller:
                  TextEditingController(text: controller.firstName.value),
              decoration: InputDecoration(labelText: 'First Name'),
              onChanged: (value) => controller.firstName.value = value,
            ),
            TextField(
              controller:
                  TextEditingController(text: controller.lastName.value),
              decoration: InputDecoration(labelText: 'Last Name'),
              onChanged: (value) => controller.lastName.value = value,
            ),
            // ... Repeat for each field
            // Professional Info
            DropdownButtonFormField<String>(
              value: controller.experience.value.isNotEmpty &&
                      ['<1 year', '1-3 years', '3+ years']
                          .contains(controller.experience.value)
                  ? controller.experience.value
                  : null,
              items: ['<1 year', '1-3 years', '3+ years']
                  .map((experience) => DropdownMenuItem<String>(
                        value: experience,
                        child: Text(experience),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.experience(
                      newValue); // Assuming experience is an RxString, this is how you update it.
                }
              },
              decoration: InputDecoration(labelText: 'Experience'),
            ),

            // ... Repeat for other dropdowns and toggles
            // Social Profiles
            TextField(
              controller:
                  TextEditingController(text: controller.facebookUrl.value),
              decoration: InputDecoration(labelText: 'Facebook URL'),
              onChanged: (value) => controller.facebookUrl.value = value,
            ),
            // ... Repeat for other social links
          ],
        ),
      ),
    );
  }
}
