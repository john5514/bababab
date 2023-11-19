import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  Widget buildTextField(String label, RxString field, ThemeData theme,
      {bool fullRow = false}) {
    Widget textField = TextFormField(
      initialValue: field.value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.hintColor),
      ),
      onChanged: (value) => field(value),
    );

    // If fullRow is true, the TextField takes the full width
    return fullRow ? textField : Expanded(child: textField);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Profile Picture
              Center(
                child: GestureDetector(
                  onTap: controller.pickAndUpdateAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: controller.avatarUrl.value.isNotEmpty
                        ? NetworkImage(controller.avatarUrl.value)
                        : null,
                    child: controller.avatarUrl.value.isEmpty
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  buildTextField('First Name', controller.firstName, theme),
                  const SizedBox(width: 16),
                  buildTextField('Last Name', controller.lastName, theme),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  buildTextField('Address', controller.address, theme),
                  const SizedBox(width: 16),
                  buildTextField('City', controller.city, theme),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  buildTextField('Country', controller.country, theme),
                  const SizedBox(width: 16),
                  buildTextField('ZIP Code', controller.zip, theme),
                ],
              ),
              const SizedBox(height: 16),

              // Role and Bio each in its own row
              buildTextField('Job Title', controller.role, theme,
                  fullRow: true),
              const SizedBox(height: 16),
              buildTextField('Bio', controller.bio, theme, fullRow: true),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.hintColor,
                ),
                onPressed:
                    controller.updateProfileData, // Call the method directly
                child: Text('Update Profile',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
