import 'package:app/util/pref_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

///A utility class that perform operations related to the device.
class DeviceUtils {

  ///A utility function that retrieves the unique device ID.
  static Future<String?> getInstallationID() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(PreferenceUtils.keyDeviceID);
  }

  static generateInstallationID() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey(PreferenceUtils.keyDeviceID)) {
      var uuid = const Uuid();
      String deviceID = uuid.v4();
      sharedPreferences.setString(PreferenceUtils.keyDeviceID, deviceID);
    }
  }

  static Future<String> resetInstallationID() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var uuid = const Uuid();
    String deviceID = uuid.v4();
    sharedPreferences.setString(PreferenceUtils.keyDeviceID, deviceID);
    return deviceID;
  }
}