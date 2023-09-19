import 'package:bicrypto/services/api_service.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;
  final ApiService apiService = ApiService();

  Future<void> sendResetLink(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final result = await apiService.resetPassword(email);

      if (result) {
        successMessage.value = 'Reset link sent to your email';
      } else {
        errorMessage.value = 'Failed to send reset link';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
