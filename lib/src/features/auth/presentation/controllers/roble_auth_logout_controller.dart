import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/roble_auth_logout_datasource.dart';

class RobleAuthLogoutController extends GetxController {
  final RobleAuthLogoutDatasource logoutDatasource =
      RobleAuthLogoutDatasource();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Realiza logout en el backend y limpia los tokens locales
  Future<void> logout() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    try {
      await logoutDatasource.logout(accessToken: token);
    } catch (e) {
      errorMessage.value = 'Error en logout: $e';
      print('Error en logout: $e');
    } finally {
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }
}
