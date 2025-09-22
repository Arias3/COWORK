import 'package:get/get.dart';
import '../../domain/use_case/roble_auth_register_usecase.dart';

class RobleAuthRegisterController extends GetxController {
  final RobleAuthRegisterUseCase useCase;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final success = false.obs;

  RobleAuthRegisterController(this.useCase);

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      success.value = false;
      final result = await useCase.call(
        email: email,
        password: password,
        name: name,
      );
      success.value = result;
      return result;
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
