import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: theme.primaryColorDark,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Profile Picture
              Center(
                child: GestureDetector(
                  onTap: controller
                      .pickAndUpdateAvatar, // Use the controller method directly
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: controller.avatarUrl.value.isNotEmpty
                        ? NetworkImage(controller.avatarUrl.value)
                        : null,
                    child: controller.avatarUrl.value.isEmpty
                        ? Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                initialValue: controller.firstName.value,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.hintColor),
                ),
                onChanged: (value) => controller.firstName(value),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: controller.lastName.value,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: theme.hintColor),
                ),
                onChanged: (value) => controller.lastName(value),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: theme.hintColor,
                ),
                onPressed: () {
                  controller.updateProfileData(
                    controller.firstName.value,
                    controller.lastName.value,
                  );
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
