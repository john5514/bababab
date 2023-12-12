import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();
  final LoginController loginController = Get.find<LoginController>();

  Widget buildTextField(String label, RxString field, ThemeData theme,
      {bool fullRow = false}) {
    Widget textField = TextFormField(
      initialValue: field.value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.primaryColor),
      ),
      onChanged: (value) => field(value),
    );

    return fullRow ? textField : Expanded(child: textField);
  }

  Future<void> _onRefresh() async {
    controller.fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: controller.updateProfileData,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.update, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Update Profile',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Spacing between the buttons
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          loginController.logout();
                          Get.offAllNamed('/login');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.exit_to_app, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Logout',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
