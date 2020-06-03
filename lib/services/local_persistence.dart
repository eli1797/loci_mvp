
import 'package:mvp/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPersistence {

  // check if the device has been shown the onboarding screen, default to false
  Future<bool> checkDeviceOnBoarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarded') ?? false;
}

  // set device hasOnBoarded
  void setDeviceOnBoarded(bool hasOnboarded) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('onboarded', hasOnboarded);
  }

}