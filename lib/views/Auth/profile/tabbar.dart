import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:bicrypto/views/Auth/profile/changepassword_screen.dart';
import 'package:bicrypto/views/Auth/profile/congratulations_screen.dart';
import 'package:bicrypto/views/Auth/profile/kyc_screen.dart';
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
  bool isTwoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchProfile();
  }

  void fetchProfile() async {
    ProfileService profileService = ProfileService(ApiService());
    var profileData = await profileService.getProfile();
    if (profileData != null && profileData['status'] == 'success') {
      // Add a null check for twofactor before trying to access its keys
      var twoFactorData = profileData['data']['result']['twofactor'];
      setState(() {
        isTwoFactorEnabled =
            twoFactorData != null ? twoFactorData['enabled'] : false;
      });
    } else {
      // Handle the case when the profile data is not fetched successfully
      setState(() {
        isTwoFactorEnabled = false;
      });
    }
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
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Enable horizontal scrolling
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Change Password'),
            Tab(text: 'Two-Step Verification'),
            Tab(text: 'KYC Verification'), // New tab for KYC
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swipe navigation

        children: [
          ProfileView(),
          ChangePasswordScreen(),
          isTwoFactorEnabled
              ? CongratulationsScreen()
              : TwoStepVerificationScreen(),
          KYCScreen(), // Add the KYC screen here
        ],
      ),
    );
  }
}
