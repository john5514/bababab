import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/views/Auth/profile/changepassword_screen.dart';
import 'package:bicrypto/views/Auth/profile/profile_view.dart';
import 'package:bicrypto/views/Auth/profile/two_step_verification_screen.dart';
import 'package:flutter/material.dart';

class MainSettingsScreen extends StatefulWidget {
  @override
  _MainSettingsScreenState createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Profile'),
            Tab(text: 'Change Password'),
            Tab(text: 'Two-Step Verification'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProfileView(), // Your ProfileView here
          ChangePasswordScreen(), // Your ChangePasswordScreen here
          TwoStepVerificationScreen(), // Your TwoStepVerificationScreen here
        ],
      ),
    );
  }
}
