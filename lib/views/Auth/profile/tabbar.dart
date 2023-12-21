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
  bool isKYCEnabled = false;
  bool _isTabControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    await fetchSettings();
  }

  Future<void> fetchProfile() async {
    try {
      ProfileService profileService = ProfileService(ApiService());
      var profileData = await profileService.getProfile();
      if (mounted &&
          profileData != null &&
          profileData['status'] == 'success') {
        var twoFactorData = profileData['data']['result']['twofactor'];
        isTwoFactorEnabled = twoFactorData != null && twoFactorData['enabled'];
      }
    } catch (e) {
      // Handle any errors here
      isTwoFactorEnabled = false;
    }
  }

  Future<void> fetchSettings() async {
    try {
      ApiService apiService = ApiService();
      var settingsResponse = await apiService.fetchSettings();
      var settingsData = settingsResponse['data']['result'] as List<dynamic>;

      if (mounted) {
        // Loop through all settings and update the flags
        for (var setting in settingsData) {
          if (setting['key'] == 'kyc_status') {
            isKYCEnabled = setting['value'] == 'Enabled';
          }
          if (setting['key'] == 'two_factor') {
            isTwoFactorEnabled = setting['value'] == 'Enabled';
          }
        }
      }
    } catch (e) {
      // Handle any errors here
      isKYCEnabled = false;
      isTwoFactorEnabled = false;
    } finally {
      if (mounted) {
        int tabLength = 2; // Start with the default two tabs.
        if (isKYCEnabled) tabLength++;
        if (isTwoFactorEnabled) tabLength++;

        // Reinitialize the TabController with the updated length
        _tabController = TabController(length: tabLength, vsync: this);

        setState(() {
          _isTabControllerInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _tabController is initialized before building the Scaffold
    if (!_isTabControllerInitialized) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // or some loading indicator
      );
    }

    List<Tab> tabs = [
      const Tab(text: 'Profile'),
      const Tab(text: 'Change Password'),
    ];
    List<Widget> tabViews = [
      ProfileView(),
      ChangePasswordScreen(),
    ];

    if (isTwoFactorEnabled) {
      tabs.add(const Tab(text: 'Two-Step Verify'));
      tabViews.add(TwoStepVerificationScreen());
    }

    if (isKYCEnabled) {
      tabs.add(const Tab(text: 'KYC Verify'));
      tabViews.add(KYCScreen());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable:
              true, // Set this to true for a horizontally scrollable TabBar
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,

        physics:
            NeverScrollableScrollPhysics(), // Prevent swipe navigation between tabs
        children: tabViews,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
