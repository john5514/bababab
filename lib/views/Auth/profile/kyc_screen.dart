import 'package:bicrypto/Controllers/Auth/profile/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class KYCScreen extends StatelessWidget {
  final KYCController kycController = Get.find<KYCController>();
  final _formKey = GlobalKey<FormState>();

  KYCScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper function to create a custom text field
    CustomTextField buildCustomTextField({
      required String label,
      required String hint,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      bool isRequired = false,
    }) {
      return CustomTextField(
        label: label,
        hint: hint,
        controller: controller,
        keyboardType: keyboardType,
        isRequired: isRequired,
      );
    }

    // This function will be called when the 'Submit' button is pressed
    void onFormSubmit() {
      if (_formKey.currentState!.validate()) {
        kycController.submitKYCData();
        // After submission, you might want to clear the fields or navigate the user
        // depending on your application's flow
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dynamically create text fields using the custom widget
              buildCustomTextField(
                label: 'First Name',
                hint: 'Enter your First Name',
                controller: kycController.firstNameController,
                isRequired: true,
              ),
              const SizedBox(height: 10),
              // Add other fields in the same way...
              buildCustomTextField(
                label: 'Last Name',
                hint: 'Enter your Last Name',
                controller: kycController.lastNameController,
                isRequired: true,
              ),
              const SizedBox(height: 10),
              buildCustomTextField(
                label: 'Email',
                hint: 'Enter your Email',
                controller: kycController.emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
              ),
              const SizedBox(height: 10),

              buildCustomTextField(
                label: 'Phone',
                hint: 'Enter your Phone',
                controller: kycController.phoneController,
                keyboardType: TextInputType.phone,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//Adress
              buildCustomTextField(
                label: 'Address',
                hint: 'Enter your Address',
                controller: kycController.addressController,
                keyboardType: TextInputType.streetAddress,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//City
              buildCustomTextField(
                label: 'City',
                hint: 'Enter your City',
                controller: kycController.cityController,
                keyboardType: TextInputType.streetAddress,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//State

              buildCustomTextField(
                label: 'State',
                hint: 'Enter your State',
                controller: kycController.stateController,
                keyboardType: TextInputType.streetAddress,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//Country
              buildCustomTextField(
                label: 'Country',
                hint: 'Enter your Country',
                controller: kycController.countryController,
                keyboardType: TextInputType.streetAddress,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//Zip
              buildCustomTextField(
                label: 'ZIP',
                hint: 'Enter your Zip Code',
                controller: kycController.zipController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//DOB
              DateInputField(
                label: 'Date of Birth',
                hint: 'mm/dd/yyyy',
                controller: kycController.dobController,
                isRequired: true,
              ),
              const SizedBox(height: 10),
//Extra Info
              Extrainfo(),

              // The 'Submit' button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onFormSubmit,
                child: const Text('Submit KYC'),
              ),
              // You can use an Obx() or GetX() here to show loading and status messages
            ],
          ),
        ),
      ),
    );
  }

  Column Extrainfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extra Information for your account verification process',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'To verify your identity, we ask you to fill in the following information.',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: kycController.extraInfoController,
              decoration: const InputDecoration(
                labelText: 'test',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Enter your test',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isRequired;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value?.trim().isEmpty ?? true)) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}

class DateInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isRequired;

  const DateInputField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true, // Prevent keyboard from appearing
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
          controller.text = formattedDate; // Use formatted date
        }
      },
      validator: (value) {
        if (isRequired && (value?.trim().isEmpty ?? true)) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}
