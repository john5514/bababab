import 'package:bicrypto/models/user_model.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  var userModel = UserModel.empty().obs; // Initialize with empty UserModel
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final ApiService apiService = ApiService();

  Future<void> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print("Attempting to register user"); // Debugging line

      print(
          "Password: $password, Confirm Password: $confirmPassword"); // Debugging line

      if (password != confirmPassword) {
        errorMessage.value = 'Passwords do not match';
        print("Passwords do not match"); // Debugging line
        return;
      }

      final success =
          await apiService.register(email, password, firstName, lastName);

      if (success) {
        print("User registered successfully"); // Debugging line
        Get.offNamed('/'); // Navigate to Login screen
      } else {
        errorMessage.value = 'Registration failed';
        print("Registration failed"); // Debugging line
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("An error occurred: ${e.toString()}"); // Debugging line
    } finally {
      isLoading.value = false;
    }
  }
}
